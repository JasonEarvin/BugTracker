unit UnitService;

interface

uses
  Winapi.Windows,
  System.SysUtils,
  System.Classes,
  System.IniFiles,
  System.JSON,
  System.IOUtils,
  Vcl.SvcMgr,
  FireDAC.Comp.Client,
  FireDAC.Stan.Def,
  FireDAC.Stan.Async,
  FireDAC.Stan.Param,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.DatS,
  FireDAC.Phys,
  FireDAC.Phys.FB,
  FireDAC.Phys.FBDef,
  FireDAC.UI.Intf,
  FireDAC.VCLUI.Wait,
  FireDAC.DApt,
  FireDAC.Comp.Script,
  FireDAC.Phys.Intf,
  Data.DB,
  IdHTTPServer,
  IdContext,
  IdCustomHTTPServer;

type
  TTawhaiBugServer = class(TService)
    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure ServiceStop(Sender: TService; var Stopped: Boolean);
    procedure ServiceExecute(Sender: TService);
  private
    FHTTP: TIdHTTPServer;
    FConn: TFDConnection;
    FIni: TIniFile;
    FPort: Integer;
    FLogFolder: string;

    FLogLock: TObject;

    procedure LoadConfig;
    procedure StartHTTP;
    procedure StopHTTP;
    procedure ConnectDatabase;
    procedure DisconnectDatabase;
    procedure HandlePost(AContext: TIdContext;
      ARequestInfo: TIdHTTPRequestInfo;
      AResponseInfo: TIdHTTPResponseInfo);
    procedure SaveBugToDatabase(const JSONText: string);
    procedure CreateBugDatabase;
    procedure Log(const Msg: string);
  public
    function GetServiceController: TServiceController; override;
  end;

var
  TawhaiBugServer: TTawhaiBugServer;

implementation

{$R *.dfm}

//Required callback that routes Windows SCM control codes to the service instance
procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  TawhaiBugServer.Controller(CtrlCode);
end;

//Returns the service controller procedure pointer required by the VCL service framework
function TTawhaiBugServer.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

//Start the HTTP server and connects the database
procedure TTawhaiBugServer.ServiceStart(Sender: TService; var Started: Boolean);
begin
  FLogLock := TObject.Create;

  try
    LoadConfig;
    ConnectDatabase;
    StartHTTP;
    Log('Service started.');
    Started := True;
  except
    on E: Exception do
    begin
      Log('Startup error: ' + E.Message);
      Started := False;
    end;
  end;
end;

//Shuts down the HTTP server and disconnect the server
procedure TTawhaiBugServer.ServiceStop(Sender: TService; var Stopped: Boolean);
begin
  StopHTTP;
  DisconnectDatabase;
  Log('Service stopped.');
  FreeAndNil(FLogLock);
  Stopped := True;
end;

//Keeps the service going
procedure TTawhaiBugServer.ServiceExecute(Sender: TService);
begin
  while not Terminated do
  begin
    ServiceThread.ProcessRequests(False);
    Sleep(1000);
  end;
end;

//Reads port, log folder, and database settings from the INI file path
procedure TTawhaiBugServer.LoadConfig;
var
  IniPath: string;
begin
  IniPath := 'C:\TawhaiServices\BugServer\BugServer.ini';

  FIni := TIniFile.Create(IniPath);

  FPort := FIni.ReadInteger('Server', 'Port', 8080);
  FLogFolder := FIni.ReadString('Logging', 'LogFolder',
    'C:\TawhaiServices\BugServer\Logs');

  ForceDirectories(FLogFolder);
end;

//Open database and connect
procedure TTawhaiBugServer.ConnectDatabase;
begin
  FConn := TFDConnection.Create(nil);

  FConn.DriverName := 'FB';

  FConn.Params.Values['Server'] :=
    FIni.ReadString('Database', 'Server', '');

  FConn.Params.Values['Database'] :=
    FIni.ReadString('Database', 'Database', '');

  FConn.Params.Values['User_Name'] :=
    FIni.ReadString('Database', 'User', '');

  FConn.Params.Values['Password'] :=
    FIni.ReadString('Database', 'Password', '');

  FConn.LoginPrompt := False;
  CreateBugDatabase;
  FConn.Connected := True;

  Log('Database connected.');
end;

//Close database and free the connection
procedure TTawhaiBugServer.DisconnectDatabase;
begin
  if Assigned(FConn) then
  begin
    try
      if FConn.Connected then
        FConn.Connected := False;

      Log('Database disconnected.');
    finally
      FreeAndNil(FConn);
    end;
  end;

  FreeAndNil(FIni);
end;

//Creates the Indy HTTP server
procedure TTawhaiBugServer.StartHTTP;
begin
  FHTTP := TIdHTTPServer.Create(nil);
  FHTTP.DefaultPort := FPort;
  FHTTP.OnCommandGet := HandlePost;
  FHTTP.Active := True;

  Log('HTTP Server started on port ' + FPort.ToString);
end;

//Deactivates and free the HTTP server
procedure TTawhaiBugServer.StopHTTP;
begin
  if Assigned(FHTTP) then
  begin
    FHTTP.Active := False;
    FreeAndNil(FHTTP);
  end;
end;

//Accept incoming HTTP requests and read the POST body
procedure TTawhaiBugServer.HandlePost(
  AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo;
  AResponseInfo: TIdHTTPResponseInfo);
var
  JSONText: string;
  SS: TStringStream;
begin
  try
    if ARequestInfo.Command = 'POST' then
    begin
      if Assigned(ARequestInfo.PostStream) then
      begin
        SS := TStringStream.Create('', TEncoding.UTF8);
        try
          ARequestInfo.PostStream.Position := 0;
          SS.CopyFrom(ARequestInfo.PostStream, ARequestInfo.PostStream.Size);
          JSONText := SS.DataString;
        finally
          SS.Free;
        end;

        SaveBugToDatabase(JSONText);

        AResponseInfo.ResponseNo := 200;
        AResponseInfo.ContentText := 'OK';
      end
      else
      begin
        AResponseInfo.ResponseNo := 400;
        AResponseInfo.ContentText := 'No POST data';
      end;
    end
    else
    begin
      AResponseInfo.ResponseNo := 405;
      AResponseInfo.ContentText := 'Method Not Allowed';
    end;

  except
    on E: Exception do
    begin
      Log('HTTP Error: ' + E.Message);
      AResponseInfo.ResponseNo := 500;
      AResponseInfo.ContentText := 'Server Error';
    end;
  end;
end;

//Insert new bug report data into the BUGREPORTS table
procedure TTawhaiBugServer.SaveBugToDatabase(const JSONText: string);
var
  JSONObj: TJSONObject;
  Q: TFDQuery;
  LocalConn: TFDConnection;
begin
  JSONObj := TJSONObject.ParseJSONValue(JSONText) as TJSONObject;
  if not Assigned(JSONObj) then
    raise Exception.Create('Invalid JSON received.');

  LocalConn := TFDConnection.Create(nil);
  try
    //Configure new connection
    LocalConn.DriverName := 'FB';
    LocalConn.Params.Assign(FConn.Params);
    LocalConn.LoginPrompt := False;
    LocalConn.Connected := True;

    Q := TFDQuery.Create(nil);
    try
      Q.Connection := LocalConn;

      Q.SQL.Text :=
        'INSERT INTO BUGREPORTS ' +
        '(DATECREATED, EXCEPTIONCLASS, EXCEPTIONMESSAGE, LINENUMBER, ' +
        'MACHINENAME, METHODNAME, PRIORITY, VERSIONNUMBER) ' +
        'VALUES (CURRENT_TIMESTAMP, :EC, :EM, :LN, :MN, :MD, :PR, :VN)';

      Q.ParamByName('EC').AsString :=
        JSONObj.GetValue<string>('ExceptionClass');

      Q.ParamByName('EM').AsString :=
        JSONObj.GetValue<string>('ExceptionMessage');

      Q.ParamByName('LN').AsInteger :=
        JSONObj.GetValue<Integer>('LineNumber');

      Q.ParamByName('MN').AsString :=
        JSONObj.GetValue<string>('MachineName');

      Q.ParamByName('MD').AsString :=
        JSONObj.GetValue<string>('MethodName');

      Q.ParamByName('PR').AsInteger :=
        JSONObj.GetValue<Integer>('Priority');

      Q.ParamByName('VN').AsString :=
        JSONObj.GetValue<string>('VersionNumber');

      Q.ExecSQL;

      Log('Bug saved from ' +
        JSONObj.GetValue<string>('MachineName'));

    finally
      Q.Free;
    end;

  finally
    LocalConn.Free;
    JSONObj.Free;
  end;
end;

//Creates the Firebird database file and schema if the database does not yet exist
procedure TTawhaiBugServer.CreateBugDatabase;
var
  DBPath: string;
  FDScript: TFDScript;
  SLScript: TStringList;
  Table: TFDTable;
  DBExists: Boolean;
begin
  DBPath := FIni.ReadString('Database', 'Database', '');

  if DBPath = '' then
    raise Exception.Create('Database path is not configured in the INI file.');

  //Check connection first and if it succeeds, the database already exists
  DBExists := False;
  try
    FConn.Connected := True;
    DBExists := True;
  except
    on E: EFDDBEngineException do
      if E.Message.ToUpper.Contains('UNSUPPORTED ON-DISK STRUCTURE FOR FILE') then
        raise Exception.Create(DBPath + ' is wrong version');
  end;

  if DBExists then
  begin
    Log('Database found: ' + DBPath);
    Exit;
  end;

  Log('Database not found. Creating: ' + DBPath);

  //Create the database file
  FDScript := TFDScript.Create(nil);
  SLScript := TStringList.Create;
  try
    FDScript.Connection := FConn;

    SLScript.Add('SET SQL DIALECT 3;');
    SLScript.Add('SET NAMES UTF8;');
    SLScript.Add('CREATE DATABASE ' + QuotedStr(DBPath));
    SLScript.Add('USER ' + QuotedStr(FIni.ReadString('Database', 'User', '')) +
                 ' PASSWORD ' + QuotedStr(FIni.ReadString('Database', 'Password', '')));
    SLScript.Add('PAGE_SIZE 16384');
    SLScript.Add('DEFAULT CHARACTER SET UTF8;');

    FDScript.ExecuteScript(SLScript);
  finally
    FDScript.Free;
    SLScript.Free;
  end;

  //Create the BUGREPORTS table
  Table := TFDTable.Create(nil);
  try
    Table.Connection := FConn;
    Table.TableName := 'BugReports';
    Table.FieldDefs.Clear;
    Table.FieldDefs.Add('BugReportIdx', ftAutoInc, 0, False);
    Table.FieldDefs.Add('DateCreated', ftDateTime, 0, False);
    Table.FieldDefs.Add('ExceptionClass', ftString, 2000, False);
    Table.FieldDefs.Add('ExceptionMessage', ftString, 2000, False);
    Table.FieldDefs.Add('LineNumber', ftInteger, 0, False);
    Table.FieldDefs.Add('MachineName', ftString, 50, False);
    Table.FieldDefs.Add('MethodName', ftString, 100, False);
    Table.FieldDefs.Add('Priority', ftInteger, 0, False);
    Table.FieldDefs.Add('VersionNumber', ftString, 50, False);
    Table.AddIndex('pkBugReportIdx', 'BugReportIdx', '', [soPrimary]);
    Table.CreateTable(False, [tpTable, tpPrimaryKey, tpGenerators, tpTriggers]);
    Log('Database and schema created successfully.');
  finally
    Table.Free;
  end;
end;

//Add a timestamp message on today's log file in the BugServer folder
procedure TTawhaiBugServer.Log(const Msg: string);
var
  LogFile: string;
  F: TextFile;
begin
  if not Assigned(FLogLock) then
    Exit;

  TMonitor.Enter(FLogLock);
  try
    LogFile := TPath.Combine(FLogFolder,
      FormatDateTime('yyyy-mm-dd', Date) + '.log');

    AssignFile(F, LogFile);
    if FileExists(LogFile) then
      Append(F)
    else
      Rewrite(F);

    try
      Writeln(F, FormatDateTime('hh:nn:ss', Now) + ' - ' + Msg);
    finally
      CloseFile(F);
    end;

  finally
    TMonitor.Exit(FLogLock);
  end;
end;

end.
