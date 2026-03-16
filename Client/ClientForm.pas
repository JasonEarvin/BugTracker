unit ClientForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.Actions,
  Vcl.ActnList, Vcl.ComCtrls, System.IOUtils, System.RegularExpressions, madExcept,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, FireDAC.UI.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Phys, FireDAC.Phys.FB, FireDAC.Phys.FBDef, FireDAC.VCLUI.Wait, BugInfo,
  Vcl.ExtCtrls, StrUtils, System.Math, Vcl.Grids, Vcl.DBGrids, System.JSON, IdHTTP, IdSSLOpenSSL;

type
  TClientPage = class(TForm)
    BtnError: TButton;
    BtnRefresh: TButton;
    BtnOpenFile: TButton;
    AliClient: TActionList;
    OpenBugInfoAction: TAction;
    PnlTop: TPanel;
    PnlClient: TPanel;
    EdtSearch: TEdit;
    LblBugCount: TLabel;
    PnlBottom: TPanel;
    BtnPrevious: TButton;
    BtnNext: TButton;
    NextPageAction: TAction;
    PreviousPageAction: TAction;
    DBGridBugs: TDBGrid;
    DSBugs: TDataSource;
    DtpFrom: TDateTimePicker;
    DtpTo: TDateTimePicker;
    BtnSearch: TButton;
    BtnClear: TButton;
    CbbTypes: TComboBox;
    QryGetBugReports: TFDQuery;
    QryGetBugReportsBUGREPORTIDX: TIntegerField;
    QryGetBugReportsEXCEPTIONMESSAGE: TStringField;
    QryGetBugReportsEXCEPTIONCLASS: TStringField;
    QryGetBugReportsMACHINENAME: TStringField;
    QryGetBugReportsVERSIONNUMBER: TStringField;
    QryGetBugReportsDATECREATED: TSQLTimeStampField;
    QryGetBugReportsPRIORITY: TIntegerField;
    QryGetBugReportsLINENUMBER: TIntegerField;
    QryGetBugReportsMETHODNAME: TStringField;
    ConBugReports: TFDConnection;
    QryBugReportsCount: TFDQuery;
    procedure BtnErrorClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure LoadPage;
    procedure UpdatePagingLabel;
    procedure UpdateTotalRecords;
    procedure BtnRefreshClick(Sender: TObject);
    procedure OpenBugInfoActionExecute(Sender: TObject);
    procedure OpenBugInfoActionUpdate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnWordFilterClick(Sender: TObject);
    procedure BtnNextClick(Sender: TObject);
    procedure BtnPreviousClick(Sender: TObject);
    procedure NextPageActionUpdate(Sender: TObject);
    procedure PreviousPageActionUpdate(Sender: TObject);
    procedure DBGridBugsDblClick(Sender: TObject);
    procedure EdtSearchKeyPress(Sender: TObject; var Key: Char);
    procedure BtnSearchFilterClick(Sender: TObject);
    procedure BtnSearchClick(Sender: TObject);
    procedure BtnClearClick(Sender: TObject);
  private
    StringList : TStringList;
    FCurrentPage, FItemsPerPage : integer;
    FFilterMachineName: string;
    FFilterDateFrom: TDateTime;
    FFilterDateTo: TDateTime;
    FTotalRecords: Integer;
    FFilterKeyword: string;
    FFilterColumn: string;
    procedure OpenDetails(BugInfo : TBugInfo);
    procedure SendBugReportToServer(E: Exception);
    function GetFieldName: string;
  public
    class procedure ErrorHandler(const exceptIntf: IMEException; var handled : boolean);
  end;

  Const
    ItemsPerPage = 25;

var
  ClientPage: TClientPage;

implementation

{$R *.dfm}

uses ErrorForm, DetailedWindowForm, FilterForm, AdvancedSearchForm,
  BugAndFilterDataModule;

// Functions that allows the creation of custone error windows
class procedure TClientPage.ErrorHandler(const exceptIntf: IMEException; var handled: Boolean);
var
  ErrorForm: TErrorWindow;
begin
  handled := True;

  OutputDebugString('ErrorHandler triggered');

  // Send bug report to server
  exceptIntf.SendBugReport;

  ErrorForm := TErrorWindow.Create(nil);
  try
    ErrorForm.ShowModal;
  finally
    ErrorForm.Free;
  end;
end;

// Remove this method once project is completed
procedure TClientPage.BtnErrorClick(Sender: TObject);
var
  SL: TStringList;
begin
  try
    SL := TStringList.Create;
    try
      SL[0];
    finally
      SL.Free;
    end;

  except
    on E: Exception do
    begin
      SendBugReportToServer(E);
      raise;
    end;
  end;
end;

procedure TClientPage.EdtSearchKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    FFilterMachineName := '';
    FFilterDateFrom := 0;
    FFilterDateTo := 0;

    with QryGetBugReports do
    begin
      Close;
      SQL.Clear;
      SQL.Text :=
        'SELECT FIRST 1 ' +
        'BugReportIDX, MachineName, ExceptionMessage, MethodName, ' +
        'LineNumber, DateCreated, Priority ' +
        'FROM BUGREPORTS ' +
        'WHERE BugReportIDX = :ID';

      ParamByName('ID').AsInteger :=
        StrToIntDef(EdtSearch.Text, 0);

      Open;
    end;

    FTotalRecords := QryGetBugReports.RecordCount;
    UpdatePagingLabel;
  end;
end;

//Next page
procedure TClientPage.BtnNextClick(Sender: TObject);
var
  TotalPages: Integer;
begin
  TotalPages := Ceil(FTotalRecords / FItemsPerPage);

  if FCurrentPage < TotalPages then
  begin
    Inc(FCurrentPage);
    LoadPage;
  end;
end;

//Previous page
procedure TClientPage.BtnPreviousClick(Sender: TObject);
begin
  if FCurrentPage > 1 then
  begin
    Dec(FCurrentPage);
    LoadPage;
  end;
end;

procedure TClientPage.BtnWordFilterClick(Sender: TObject);
var
  FilterForm : TFilterPage;
begin
  FilterForm := TFilterPage.Create(nil);
  try
    FilterForm.ShowModal;
  finally
    FilterForm.Free;
  end;
end;

procedure TClientPage.BtnRefreshClick(Sender: TObject);
begin
  if DtpFrom.Checked then
    FFilterDateFrom := DtpFrom.Date
  else
    FFilterDateFrom := 0;

  if DtpTo.Checked then
    FFilterDateTo := DtpTo.Date + 0.99999
  else
    FFilterDateTo := 0;

  FCurrentPage := 1;

  UpdateTotalRecords;
  LoadPage;
end;

procedure TClientPage.BtnSearchFilterClick(Sender: TObject);
var
  AdvancedSearchForm: TAdvancedSearchPage;
begin
  AdvancedSearchForm := TAdvancedSearchPage.Create(nil);
  try
    if AdvancedSearchForm.ShowModal = mrOk then
    begin
      FFilterMachineName := AdvancedSearchForm.MachineName;
      FFilterDateFrom := AdvancedSearchForm.DateFrom;
      FFilterDateTo := AdvancedSearchForm.DateTo;

      FCurrentPage := 1;

      UpdateTotalRecords;
      LoadPage;
    end;
  finally
    AdvancedSearchForm.Free;
  end;
end;

procedure TClientPage.BtnSearchClick(Sender: TObject);
begin
  if DtpFrom.Checked then
    FFilterDateFrom := DtpFrom.Date
  else
    FFilterDateFrom := 0;

  if DtpTo.Checked then
    FFilterDateTo := DtpTo.Date + 0.99999
  else
    FFilterDateTo := 0;

  FFilterKeyword := Trim(EdtSearch.Text);

  if (FFilterKeyword <> '') and (CbbTypes.ItemIndex = -1) then
  begin
    ShowMessage('Please select a search type first.');
    CbbTypes.SetFocus;
    Exit;
  end;

  FFilterColumn := GetFieldName;

  FCurrentPage := 1;

  UpdateTotalRecords;
  LoadPage;
end;

//From Jason
procedure TClientPage.BtnClearClick(Sender: TObject);
begin
  EdtSearch.Clear;

  CbbTypes.ItemIndex := 0;

  DtpFrom.Date := Date - 2;
  DtpTo.Date := Date;

  DtpFrom.Checked := True;
  DtpTo.Checked := True;

  FFilterMachineName := '';
  FFilterKeyword := '';
  FFilterColumn := '';
  FFilterDateFrom := DtpFrom.Date;
  FFilterDateTo := DtpTo.Date + 0.99999;

  CbbTypes.ItemIndex := -1;

  FCurrentPage := 1;

  UpdateTotalRecords;
  LoadPage;
end;

procedure TClientPage.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  //From Jason
  if ConBugReports.Connected then
      ConBugReports.Close;
end;

procedure TClientPage.FormCreate(Sender: TObject);
begin
//  RegisterExceptionHandler(ErrorHandler, stTrySyncCallAlways);

  FItemsPerPage := 25;
  FCurrentPage := 1;

  DtpFrom.Date := Date - 2;
  DtpTo.Date := Date;

  DtpFrom.Checked := True;
  DtpTo.Checked := True;

  FFilterMachineName := '';
  FFilterDateFrom := DtpFrom.Date;
  FFilterDateTo := DtpTo.Date + 0.99999; //Include full end day

  //EdtSearch.Enabled := False;
  CbbTypes.ItemIndex := -1; //Default selection

  UpdateTotalRecords;
  LoadPage;
end;

//From Jason
procedure TClientPage.LoadPage;
var
  Skip: Integer;
begin
  Skip := (FCurrentPage - 1) * FItemsPerPage;

  with QryGetBugReports do
  begin
    Close;
    SQL.Clear;
    //Params.Clear;
    SQL.Text :=
      'SELECT FIRST :Limit SKIP :Skip ' +
      'BugReportIDX, MachineName, VersionNumber, ExceptionMessage, ExceptionClass, MethodName, ' +
      'LineNumber, DateCreated, Priority ' +
      'FROM BUGREPORTS WHERE 1=1';

    //Optional filters
    if FFilterMachineName <> '' then
      SQL.Add(' AND UPPER(MachineName) LIKE :MachineName');

    if (FFilterKeyword <> '') and (FFilterColumn <> '') then
      SQL.Add(' AND UPPER(' + FFilterColumn + ') LIKE :Keyword');

    if FFilterDateFrom <> 0 then
      SQL.Add(' AND DateCreated >= :DateFrom');

    if FFilterDateTo <> 0 then
      SQL.Add(' AND DateCreated <= :DateTo');

    SQL.Add(' ORDER BY DateCreated DESC');

    //Required paging params
    ParamByName('Limit').AsInteger := FItemsPerPage;
    ParamByName('Skip').AsInteger := Skip;

    //Optional params
    if FFilterMachineName <> '' then
      ParamByName('MachineName').AsString :=
        '%' + UpperCase(FFilterMachineName) + '%';

    if (FFilterKeyword <> '') and (FFilterColumn <> '') then
      ParamByName('Keyword').AsString :=
        '%' + UpperCase(FFilterKeyword) + '%';

    if FFilterDateFrom <> 0 then
      ParamByName('DateFrom').AsDateTime := FFilterDateFrom;

    if FFilterDateTo <> 0 then
      ParamByName('DateTo').AsDateTime := FFilterDateTo;

    Open;
  end;

  UpdatePagingLabel;
end;

procedure TClientPage.UpdatePagingLabel;
var
  TotalPages: Integer;
begin
  if FTotalRecords = 0 then
  begin
    LblBugCount.Caption := 'No records found';
    Exit;
  end;

  TotalPages :=
    Ceil(FTotalRecords / FItemsPerPage);

  LblBugCount.Caption :=
    Format('Page %d of %d (%d records)',
      [FCurrentPage, TotalPages, FTotalRecords]);
end;

procedure TClientPage.UpdateTotalRecords;
begin
  with QryBugReportsCount do
  begin
    Close;
    SQL.Clear;
    //Params.Clear;
    SQL.Text :=
      'SELECT COUNT(*) FROM BUGREPORTS WHERE 1=1';

    //Optional filters
    if FFilterMachineName <> '' then
      SQL.Add(' AND UPPER(MachineName) LIKE :MachineName');

    if (FFilterKeyword <> '') and (FFilterColumn <> '') then
      SQL.Add(' AND UPPER(' + FFilterColumn + ') LIKE :Keyword');

    if FFilterDateFrom <> 0 then
      SQL.Add(' AND DateCreated >= :DateFrom');

    if FFilterDateTo <> 0 then
      SQL.Add(' AND DateCreated <= :DateTo');

    //Assign parameters
    if FFilterMachineName <> '' then
      ParamByName('MachineName').AsString :=
        '%' + UpperCase(FFilterMachineName) + '%';

    if (FFilterKeyword <> '') and (FFilterColumn <> '') then
      ParamByName('Keyword').AsString :=
        '%' + UpperCase(FFilterKeyword) + '%';

    if FFilterDateFrom <> 0 then
      ParamByName('DateFrom').AsDateTime := FFilterDateFrom;

    if FFilterDateTo <> 0 then
      ParamByName('DateTo').AsDateTime := FFilterDateTo;

    Open;
    FTotalRecords := Fields[0].AsInteger;
    Close;
  end;
end;

procedure TClientPage.OpenDetails(BugInfo: TBugInfo);
var
  DetailsForm : TDetailedWindow;
begin
    DetailsForm := TDetailedWindow.Create(nil);
    try
      DetailsForm.BugInfo := BugInfo;
      DetailsForm.ShowModal;
    finally
      DetailsForm.Free;
    end;
end;

procedure TClientPage.OpenBugInfoActionExecute(Sender: TObject);
var
  BugID: Integer;
begin
  if not QryGetBugReports.IsEmpty then
  begin
    BugID := QryGetBugReports.FieldByName('BugReportIDX').AsInteger;
    ShowMessage('Selected Bug ID: ' + IntToStr(BugID));
    //Later you can load full details by ID
  end;
end;

procedure TClientPage.OpenBugInfoActionUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled :=
    not QryGetBugReports.IsEmpty;
end;


procedure TClientPage.NextPageActionUpdate(Sender: TObject);
begin
  (Sender As TAction).Enabled :=
    QryGetBugReports.RecordCount = FItemsPerPage;
end;

procedure TClientPage.PreviousPageActionUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := FCurrentPage > 1;
end;

procedure TClientPage.DBGridBugsDblClick(Sender: TObject);
var
  BugID: Integer;
begin
  BugID :=
    QryGetBugReports
    .FieldByName('BugReportIDX').AsInteger;

  ShowMessage('Selected ID: ' + IntToStr(BugID));
end;

function TClientPage.GetFieldName: string;
begin
  case CbbTypes.ItemIndex of
    0: Result := 'EXCEPTIONMESSAGE';
    1: Result := 'EXCEPTIONCLASS';
    2: Result := 'MACHINENAME';
  else
    Result := '';
  end;
end;

procedure TClientPage.SendBugReportToServer(E: Exception);
var
  HTTP: TIdHTTP;
  JSON: TJSONObject;
  Response: TStringStream;
begin
  HTTP := TIdHTTP.Create(nil);
  JSON := TJSONObject.Create;
  Response := TStringStream.Create;
  try
    JSON.AddPair('ExceptionClass', E.ClassName);
    JSON.AddPair('ExceptionMessage', E.Message);
    JSON.AddPair('LineNumber', TJSONNumber.Create(0));
    JSON.AddPair('MachineName', GetEnvironmentVariable('COMPUTERNAME'));
    JSON.AddPair('MethodName', 'BtnErrorClick');
    JSON.AddPair('Priority', TJSONNumber.Create(1));
    JSON.AddPair('VersionNumber', '1.0');

    HTTP.Request.ContentType := 'application/json';
    HTTP.Post('http://localhost:8080', TStringStream.Create(JSON.ToString), Response);

  finally
    HTTP.Free;
    JSON.Free;
    Response.Free;
  end;
end;

end.
