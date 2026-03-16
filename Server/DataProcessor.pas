unit DataProcessor;

interface

uses IdCustomHTTPServer, System.SysUtils, FireDAC.Stan.Param, Data.DB,
  System.Classes, System.IOUtils, System.IniFiles, Winapi.Windows, Vcl.Dialogs;

type
  TBugInfo = class
    FileContents : string;
  public
    procedure ProcessBugInfo(ARequestInfo: TIdHTTPRequestInfo);
  private
    MethodName : string;
    LineNumber : Integer;
    procedure CreateFile(Path : string; Data : TBytes; StartPos, EndPos : integer);
    function ReduceStack(StackContent : string) : string;
    function GetLine(Line : string) : string;
    function ParseDate(DateLine : string) : TDateTime;
    function SaveToDatabase : integer;
    function RetrieveFilterWords : TStringList;
  end;
    function CheckAuthorisation : boolean;
    function GetBugReportFolder: string;
    function GetBugServerIniPath: string;
    //const Path : string = '\Software\Tawhai\BugTracker';

implementation

uses
  BugReportsDataModule,
  //DbugIntf,
  System.DateUtils;

procedure TBugInfo.ProcessBugInfo(ARequestInfo: TIdHTTPRequestInfo);
var
  Boundary, ContentType, FilePath, ReducedStack: string;
  BoundaryStartIndex, StartPos, EndPos, HeaderEnd, LastHeader, ID : integer;
  StackStartIndex : integer;
  FileMessageStream : TStream;
  RawData, NewData : TBytes;
  //From Jason
  FolderPath: string;
begin
  // Find boundary
  ContentType := ARequestInfo.ContentType;
  BoundaryStartIndex := Pos('boundary=', ContentType);
  if BoundaryStartIndex > 0 then
  begin
     Boundary := '--' + Copy(ContentType, BoundaryStartIndex + 9, MaxInt);
  end;

  // Load data
  FileMessageStream := ARequestInfo.PostStream;
  FileMessageStream.Position := 0;
  SetLength(RawData, FileMessageStream.Size);
  FileMessageStream.ReadBuffer(RawData[0], Length(RawData));
  FileContents := TEncoding.ANSI.GetString(RawData);

  // Find the end of the last header
  LastHeader := FileContents.IndexOf('filename="bugreport.txt"', 0);
  HeaderEnd := FileContents.IndexOf(sLineBreak + sLineBreak, LastHeader);
  if HeaderEnd < 0 then Exit;

  // Find start of content
  StartPos := HeaderEnd + 4;

  // Find End of file boundary
  EndPos := FileContents.IndexOf(string(Boundary) + '--') - 2;
  if EndPos < 0 then Exit;

  StackStartIndex := FileContents.IndexOf('main thread') + 23;

  ReducedStack := ReduceStack(Copy(FileContents, StackStartIndex, EndPos - 1 - StackStartIndex));
  FileContents := Copy(FileContents, 0, StackStartIndex - 1) + ReducedStack
                  + sLineBreak + sLineBreak + 'Original Stack: '+ sLineBreak
                  + Copy(FileContents, StackStartIndex, EndPos - 1 - StackStartIndex);

  ID := SaveToDatabase;
  NewData := TEncoding.ANSI.GetBytes(FileContents);
  if ID > 0 then
  begin
    //From Jason
    FolderPath := GetBugReportFolder;
    ShowMessage('Folder Path = ' + FolderPath);

    if FolderPath = '' then
      raise Exception.Create('Bug report folder not configured in INI file.');

    if not DirectoryExists(FolderPath) then
      ForceDirectories(FolderPath);

    FilePath := IncludeTrailingPathDelimiter(FolderPath) +
                IntToStr(ID) + '.txt';

    CreateFile(FilePath, NewData, StartPos, EndPos);
  end;
end;

function TBugInfo.ReduceStack(StackContent : string) : string;
var
  LineStartPos, LineEndPos, CopyStartPos, CopyEndPos, StackSize, WordStartPos,
  WordEndPos, FileNameStartPos, FileNameEndPos : integer;
  CurrentLine, NewStackContent, ComparisonWord, ComparisonFile : string;
  FilterWords : TStringList;
  HasRetrievedMethod : boolean;
begin
  CopyStartPos := -1;
  CopyEndPos := -1;
  LineStartPos := 1;
  FileNameStartPos := 15;
  WordStartPos := -1;
  StackSize := StackContent.Length;
  FilterWords := RetrieveFilterWords;
  HasRetrievedMethod := False;

  try
    while LineStartPos < StackSize do
    begin
      LineEndPos := StackContent.IndexOf(sLineBreak, LineStartPos) + 2;
      CurrentLine := Copy(StackContent, LineStartPos, LineEndPos - LineStartPos);

      // Retrieve 3rd word for filename
      FileNameEndPos := CurrentLine.IndexOf(' ', FileNameStartPos) + 1;
      ComparisonFile := Copy(CurrentLine, FileNameStartPos, FileNameEndPos - FileNameStartPos);

      // Start position of Class name will be the same (Start of the word will always be the same
      // index, so only need to set on the first time)
      if WordStartPos = -1 then
      begin
        WordStartPos := CurrentLine.IndexOf(' ', FileNameEndPos);

        while CurrentLine[WordStartPos + 1] = ' ' do
          inc(WordStartPos);
      end;

      WordEndPos := CurrentLine.IndexOf(' ', WordStartPos + 1);
      ComparisonWord := Copy(CurrentLine, WordStartPos + 1, WordEndPos - WordStartPos);

      if FilterWords.Contains(ComparisonWord) or FilterWords.Contains(ComparisonFile) then
      begin
        if CopyStartPos <> -1 then
        begin
          NewStackContent := NewStackContent + Copy(StackContent, CopyStartPos, CopyEndPos - CopyStartPos);
          CopyStartPos := -1;
          CopyEndPos := -1;
        end;
      end
      else
      begin
        if CopyStartPos = -1 then
        begin
          CopyStartPos := LineStartPos;
          if not HasRetrievedMethod then
          begin
            // Retrieve 5th word in line which corresponds to the line number
            WordStartPos := CurrentLine.IndexOf(' ', WordEndPos);
            while CurrentLine[WordStartPos + 1] = ' ' do
              inc(WordStartPos);
            WordEndPos := CurrentLine.IndexOf(' ', WordStartPos + 1);
            LineNumber := StrToInt(Copy(CurrentLine, WordStartPos + 1, WordEndPos - WordStartPos));

            // Retrieve 7th word in line which is the method name

            WordStartPos := CurrentLine.IndexOf(' ', WordEndPos);
            while CurrentLine[WordStartPos + 1] = ' ' do
              inc(WordStartPos);
            WordEndPos := CurrentLine.IndexOf(' ', WordStartPos + 1);

            MethodName := Copy(CurrentLine, WordEndPos + 1);

            HasRetrievedMethod := True;
            WordStartPos := -1;
           end;
        end;
        CopyEndPos := LineEndPos;
      end;

      LineStartPos := LineEndPos + 1;
    end;
  finally
    FilterWords.Free;
  end;

  if CopyStartPos <> -1 then
    NewStackContent := NewStackContent + Copy(StackContent, CopyStartPos, CopyEndPos - CopyStartPos);

  Result := NewStackContent;
end;

function TBugInfo.RetrieveFilterWords: TStringList;
var
  WordList : TStringList;
begin
  WordList := TStringList.Create;
  DataModuleBugReports.QryGetFilterWords.Open;
  try
    while not DataModuleBugReports.QryGetFilterWords.Eof do
    begin
      WordList.Add(DataModuleBugReports.QryGetFilterWords.FieldByName('Word').AsString);
      DataModuleBugReports.QryGetFilterWords.Next;
    end;
  finally
    DataModuleBugReports.QryGetFilterWords.Close;
  end;

  Result := WordList;
end;

function TBugInfo.GetLine(Line : string) : string;
var
  StartPos, EndPos : integer;
begin
  StartPos := FileContents.IndexOf(Line) + 22;
  EndPos := FileContents.IndexOf(sLineBreak, StartPos) + 1;

  Result := Copy(FileContents, StartPos, EndPos - StartPos);
end;

function TBugInfo.ParseDate(DateLine : string) : TDateTime;
var
  Date, Time, TimeLine : string;
  DateFormatSettings : TFormatSettings;
begin
  Date := Copy(DateLine, 1, Pos(',', DateLine) - 1);
  TimeLine := Copy(DateLine, Pos(',', DateLine) + 1, MaxInt);
  Time := Copy(TimeLine, 2, Pos(',', TimeLine) - 2);

  DateFormatSettings := TFormatSettings.Create;
  DateFormatSettings.DateSeparator := '-';
  DateFormatSettings.TimeSeparator := ':';
  DateFormatSettings.ShortDateFormat := 'yyyy-mm-dd';
  DateFormatSettings.ShortTimeFormat := 'hh:nn:ss';

  Result := StrToDateTime(Date + ' ' + Time, DateFormatSettings);
end;

procedure TBugInfo.CreateFile(Path : string; Data : TBytes; StartPos, EndPos : integer);
var
  OutStream : TFileStream;
begin
  OutStream := TFileStream.Create(Path, fmCreate);
  try
    OutStream.WriteBuffer(Data[StartPos], EndPos - StartPos);
  finally
    OutStream.Free;
  end;
end;

function TBugInfo.SaveToDatabase : Integer;
var
  DateLine : string;
begin
  DataModuleBugReports.QrySaveBugReport.ParamByName('ExceptionMessage').AsString := GetLine('exception message');
  DataModuleBugReports.QrySaveBugReport.ParamByName('ExceptionClass').AsString := GetLine('exception class');
  DataModuleBugReports.QrySaveBugReport.ParamByName('MachineName').AsString := GetLine('computer name');
  DataModuleBugReports.QrySaveBugReport.ParamByName('VersionNumber').AsString := GetLine('version');
  DataModuleBugReports.QrySaveBugReport.ParamByName('LineNumber').AsInteger := LineNumber;
  DataModuleBugReports.QrySaveBugReport.ParamByName('MethodName').AsString := MethodName;

  //SendDebug('Got bug report from ' + DataModuleBugReports.QrySaveBugReport.ParamByName('MachineName').AsString);

  DateLine := GetLine('date/time');
  DataModuleBugReports.QrySaveBugReport.ParamByName('DateCreated').AsDateTime := ParseDate(DateLine);

  DataModuleBugReports.QrySaveBugReport.Open;
  try
    if DataModuleBugReports.QrySaveBugReport.IsEmpty <> True then
      Result := DataModuleBugReports.QrySaveBugReport.FieldByName('BugReportIDX').AsInteger
    else
      Result := -1;
  finally
    DataModuleBugReports.QrySaveBugReport.Close;
  end;
end;

// Update to actual check authorisation
function CheckAuthorisation : boolean;
begin
  Result := True;
end;

//From Jason
function GetBugReportFolder: string;
var
  Ini: TIniFile;
  IniPath: string;
begin
  IniPath := GetBugServerIniPath;

  if not FileExists(IniPath) then
    raise Exception.Create('BugServer.ini not found at ' + IniPath);

  Ini := TIniFile.Create(IniPath);
  try
    Result := Ini.ReadString('General', 'BugReportPath', '');

    if Result = '' then
      raise Exception.Create('BugReportPath not configured in BugServer.ini');
  finally
    Ini.Free;
  end;
end;

function GetBugServerIniPath: string;
begin
  Result := 'C:\TawhaiServices\BugServer\BugServer.ini';
end;

procedure EnsureBugServerFolderExists;
var
  Folder: string;
begin
  Folder := 'C:\TawhaiServices\BugServer';
  if not TDirectory.Exists(Folder) then
    TDirectory.CreateDirectory(Folder);
end;

//procedure TestBugFolder;
//var
//  FolderPath, TestFile: string;
//  SL: TStringList;
//begin
//  FolderPath := GetBugReportFolder;
//
//  if FolderPath = '' then
//  begin
//    ShowMessage('Registry not configured.');
//    Exit;
//  end;
//
//  if not DirectoryExists(FolderPath) then
//    ForceDirectories(FolderPath);
//
//  TestFile := IncludeTrailingPathDelimiter(FolderPath) + 'test.txt';
//
//  SL := TStringList.Create;
//  try
//    SL.Text := 'Registry test successful!';
//    SL.SaveToFile(TestFile);
//  finally
//    SL.Free;
//  end;
//
//  ShowMessage('Test file created at: ' + TestFile);
//end;

end.
