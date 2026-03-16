unit BugInfo;

interface

uses
  System.Generics.Collections;

type
  TBugInfo = class(TObject)
    public
      ID : integer;
      ExceptionMessage : string;
      ExceptionClass : string;
      MachineName : string;
      VersionNumber : string;
      DateCreated : TDateTime;
      Priority : integer;
      LineNumber : integer;
      MethodName : string;
  end;

  TBugs = class
    private
      BugList : TList<TBugInfo>;
      BugDictionary : TDictionary<Integer, TBugInfo>;
    public
      constructor Create;
      destructor Destroy; override;
      procedure RetrieveBugs;
      procedure SetBugsList(NewBugsList : TList<TBugInfo>);
      function Count : integer;
      function GetBug(index : integer) : TBugInfo;
      function GetBugByID(ID : integer) : TBugInfo;
  end;
implementation

{ TBugs }

uses BugAndFilterDataModule;

function TBugs.Count: integer;
begin
  Result := BugList.Count;
end;

constructor TBugs.Create;
begin
  BugList := TObjectList<TBugInfo>.Create;
  BugDictionary := TDictionary<Integer, TBugInfo>.Create;
  RetrieveBugs;
end;

destructor TBugs.Destroy;
begin
  BugList.Free;
  BugDictionary.Free;
  inherited;
end;

function TBugs.GetBug(index : integer): TBugInfo;
begin
  Result := BugList.Items[index];
end;

function TBugs.GetBugByID(ID: integer): TBugInfo;
var
  FoundBug : TBugInfo;
begin
  if BugDictionary.TryGetValue(ID, FoundBug) then
    Result := FoundBug
  else
    Result := nil;
end;

procedure TBugs.RetrieveBugs;
var
  BugInfo : TBugInfo;
begin
  DataModuleBugAndFilter.QryGetBugReports.Open;
  try
    while not DataModuleBugAndFilter.QryGetBugReports.Eof do
    begin
      BugInfo := TBugInfo.Create;
      BugInfo.ID := DataModuleBugAndFilter.QryGetBugReports.FieldByName('BugReportIDX').AsInteger;
      BugInfo.ExceptionMessage := DataModuleBugAndFilter.QryGetBugReports.FieldByName('ExceptionMessage').AsString;
      BugInfo.ExceptionClass := DataModuleBugAndFilter.QryGetBugReports.FieldByName('ExceptionClass').AsString;
      BugInfo.MachineName := DataModuleBugAndFilter.QryGetBugReports.FieldByName('MachineName').AsString;
      Buginfo.VersionNumber := DataModuleBugAndFilter.QryGetBugReports.FieldByName('VersionNumber').AsString;
      BugInfo.DateCreated := DataModuleBugAndFilter.QryGetBugReports.FieldByName('DateCreated').AsDateTime;
      BugInfo.Priority := DataModuleBugAndFilter.QryGetBugReports.FieldByName('Priority').AsInteger;
      BugInfo.LineNumber := DataModuleBugAndFilter.QryGetBugReports.FieldByName('LineNumber').AsInteger;
      Buginfo.MethodName := DataModuleBugAndFilter.QryGetBugReports.FieldByName('MethodName').AsString;

      BugList.Add(BugInfo);
      BugDictionary.Add(BugInfo.ID, BugInfo);
      DataModuleBugAndFilter.QryGetBugReports.Next;
    end;
  finally
    DataModuleBugAndFilter.QryGetBugReports.Close;
  end;
end;
procedure TBugs.SetBugsList(NewBugsList: TList<TBugInfo>);
begin
  //BugList := NewBugsList;
  BugList.Free;
  BugList := TObjectList<TBugInfo>(NewBugsList);
end;

end.
