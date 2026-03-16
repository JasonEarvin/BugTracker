unit AdvancedSearchForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, BugInfo, Generics.Collections,
  FireDAC.Stan.Param;

type
  TAdvancedSearchPage = class(TForm)
    ComBoxPriority: TComboBox;
    LblPriority: TLabel;
    BtnSearch: TButton;
    DTPToDate: TDateTimePicker;
    DTPFromDate: TDateTimePicker;
    LblFromDate: TLabel;
    LblToDate: TLabel;
    EdtMachine: TEdit;
    EdtExceptionClass: TEdit;
    EdtExceptionMessage: TEdit;
    EdtVersionNumber: TEdit;
    //From Jason
    procedure BtnSearchClick(Sender: TObject);
  private
    { Private declarations }
    //From Jason
    function GetMachineName: string;
    function GetDateFrom: TDateTime;
    function GetDateTo: TDateTime;
  public
    //FilteredBugsList : TList<TBugInfo>;
    //From Jason
    property MachineName: string read GetMachineName;
    property DateFrom: TDateTime read GetDateFrom;
    property DateTo: TDateTime read GetDateTo;
  end;

var
  AdvancedSearchPage: TAdvancedSearchPage;

implementation

{$R *.dfm}

uses BugAndFilterDataModule;

//procedure TAdvancedSearchPage.BtnSearchClick(Sender: TObject);
//var
//  FromDate, ToDate : TDateTime;
//  QueryString, ExceptionMessage, ExceptionClass, Machine, Version : String;
//  BugInfo : TBugInfo;
//  Priority : integer;
//begin
//  ExceptionMessage := EdtExceptionMessage.Text;
//  ExceptionClass := EdtExceptionClass.Text;
//  Machine := EdtMachine.Text;
//  Version := EdtVersionNumber.Text;
//  FromDate := 0;
//  ToDate := 0;
//  Priority := ComBoxPriority.ItemIndex;
//
//  QueryString := 'SELECT * FROM BugReports WHERE 1 = 1';
//
//  if ExceptionMessage <> '' then
//    QueryString := QueryString + ' AND ExceptionMessage LIKE :ExceptionMessage';
//
//  if ExceptionClass <> '' then
//    QueryString := QueryString + ' AND ExceptionClass LIKE :ExceptionClass';
//
//  if Machine <> '' then
//    QueryString := QueryString + ' AND MachineName LIKE :Machine';
//
//  if Version <> '' then
//    QueryString := QueryString + ' AND VersionNumber LIKE :Version';
//
//  if Priority <> -1 then
//    QueryString := QueryString + ' AND Priority = :Priority';
//
//
//  if DTPFromDate.Checked and DTPToDate.Checked then
//  begin
//    FromDate := DTPFromDate.Date + EncodeTime(0, 0, 0, 0);
//    ToDate := DTPToDate.Date + EncodeTime(23, 59, 59, 999);
//    QueryString := QueryString + ' AND DateCreated BETWEEN :FromDate AND :ToDate';
//  end
//  else if DTPFromDate.Checked then
//  begin
//    FromDate := DTPFromDate.Date + EncodeTime(0, 0, 0, 0);
//    QueryString := QueryString + ' AND DateCreated > :FromDate';
//  end
//  else if DTPToDate.Checked then
//  begin
//    ToDate := DTPToDate.Date + EncodeTime(23, 59, 59, 999);
//    QueryString := QueryString + ' AND DateCreated < :ToDate';
//  end;
//
//  QueryString := QueryString + ' Order By BugReportIDX';
//
//  // Move this somewhere else
//  DataModuleBugAndFilter.QryAdvancedSearch.SQL.Clear;
//  DataModuleBugAndFilter.QryAdvancedSearch.SQL.Add(QueryString);
//
//  if ExceptionMessage <> '' then
//    DataModuleBugAndFilter.QryAdvancedSearch.ParamByName('ExceptionMessage').AsString := ExceptionMessage + '%';
//
//  if ExceptionClass <> '' then
//    DataModuleBugAndFilter.QryAdvancedSearch.ParamByName('ExceptionClass').AsString := ExceptionClass + '%';
//
//  if Machine <> '' then
//    DataModuleBugAndFilter.QryAdvancedSearch.ParamByName('Machine').AsString := Machine + '%';
//
//  if Version <> '' then
//    DataModuleBugAndFilter.QryAdvancedSearch.ParamByName('Version').AsString := Version + '%';
//
//  if FromDate <> 0 then
//    DataModuleBugAndFilter.QryAdvancedSearch.ParamByName('FromDate').AsDateTime := FromDate;
//
//  if ToDate <> 0 then
//    DataModuleBugAndFilter.QryAdvancedSearch.ParamByName('ToDate').AsDateTime := ToDate;
//
//  if Priority <> -1 then
//    DataModuleBugAndFilter.QryAdvancedSearch.ParamByName('Priority').AsInteger := Priority;
//
//  //This code is almost identical to TBugs.RetrieveBugs in the Buginfo.pas form
//  DataModuleBugAndFilter.QryAdvancedSearch.Open;
//  try
//    FilteredBugsList := TObjectList<TBugInfo>.Create;
//    while not DataModuleBugAndFilter.QryAdvancedSearch.Eof do
//    begin
//      BugInfo := TBugInfo.Create;
//      BugInfo.ID := DataModuleBugAndFilter.QryAdvancedSearch.FieldByName('BugReportIDX').AsInteger;
//      BugInfo.ExceptionMessage := DataModuleBugAndFilter.QryAdvancedSearch.FieldByName('ExceptionMessage').AsString;
//      BugInfo.ExceptionClass := DataModuleBugAndFilter.QryAdvancedSearch.FieldByName('ExceptionClass').AsString;
//      BugInfo.MachineName := DataModuleBugAndFilter.QryAdvancedSearch.FieldByName('MachineName').AsString;
//      Buginfo.VersionNumber := DataModuleBugAndFilter.QryAdvancedSearch.FieldByName('VersionNumber').AsString;
//      BugInfo.DateCreated := DataModuleBugAndFilter.QryAdvancedSearch.FieldByName('DateCreated').AsDateTime;
//      BugInfo.Priority := DataModuleBugAndFilter.QryAdvancedSearch.FieldByName('Priority').AsInteger;
//
//      FilteredBugsList.Add(BugInfo);
//      DataModuleBugAndFilter.QryAdvancedSearch.Next;
//    end;
//    ModalResult := mrOK;
//  finally
//    DataModuleBugAndFilter.QryAdvancedSearch.Close;
//  end;
//
//end;

procedure TAdvancedSearchPage.BtnSearchClick(Sender: TObject);
begin
  ModalResult := mrOK;
end;

function TAdvancedSearchPage.GetMachineName: string;
begin
  Result := EdtMachine.Text;
end;

function TAdvancedSearchPage.GetDateFrom: TDateTime;
begin
  Result := DTPFromDate.Date;
end;

function TAdvancedSearchPage.GetDateTo: TDateTime;
begin
  Result := DTPToDate.Date;
end;

end.
