unit DetailedWindowForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Winapi.ShellAPI,
  Vcl.ExtCtrls, Vcl.CheckLst, BugInfo, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.UI.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Phys, FireDAC.Phys.FB, FireDAC.Phys.FBDef,
  FireDAC.VCLUI.Wait, System.UITypes;

type
  TDetailedWindow = class(TForm)
    LblExceptionMessage: TLabel;
    BtnOpenFile: TButton;
    LblExceptionClass: TLabel;
    LblDateCreated: TLabel;
    PnlTop: TPanel;
    PnlClient: TPanel;
    LblMachineName: TLabel;
    LblVersionNumber: TLabel;
    ComBoxPriority: TComboBox;
    BtnDeleteBug: TButton;
    LblLineNumber: TLabel;
    LblMethodName: TLabel;
    procedure BtnOpenFileClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure BtnDeleteBugClick(Sender: TObject);
  private
    FBugInfo : TBugInfo;
    procedure SaveChanges;
    procedure LoadDetails;
  public
    property BugInfo : TBugInfo read FBugInfo write FBugInfo;
    const path : string = 'C:\Temp\reports';
  end;

var
  DetailedWindow: TDetailedWindow;

implementation

uses
  Vcl.Dialogs, BugAndFilterDataModule;

{$R *.dfm}

procedure TDetailedWindow.BtnDeleteBugClick(Sender: TObject);
begin
  case MessageDlg('Are you sure?', mtConfirmation, [mbOK, mbCancel], 0) of
    mrOk:
      begin
        DataModuleBugAndFilter.QryDeleteBugReport.ParamByName('BugReportID').AsInteger := BugInfo.ID;
        DataModuleBugAndFilter.QryDeleteBugReport.ExecSQL;
        try
          if DataModuleBugAndFilter.QryDeleteBugReport.RowsAffected <> 1 then
            MessageDlg('An error occured whilst deleting', mtError, [mbOK], 0)
          else if not DeleteFile(path + '\' + IntToStr(BugInfo.ID) + '.txt') then
            MessageDlg('Could not delete file with ID: ' + IntToStr(BugInfo.ID), mtError, [mbOK], 0)
        finally
          DataModuleBugAndFilter.QryDeleteFilterWord.Close;
        end;
        ModalResult := mrCancel;
      end;
  end;
end;

procedure TDetailedWindow.BtnOpenFileClick(Sender: TObject);
begin
  ShellExecute(0, 'open', PChar(IntToStr(BugInfo.ID) + '.txt'), nil, PChar(path), SW_NORMAL);
end;

procedure TDetailedWindow.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if ComBoxPriority.ItemIndex <> BugInfo.Priority then
    SaveChanges;
end;

procedure TDetailedWindow.FormShow(Sender: TObject);
begin
  LoadDetails;
end;

procedure TDetailedWindow.LoadDetails;
begin
  LblExceptionMessage.Caption := BugInfo.ExceptionMessage;
  LblExceptionClass.Caption := 'Exception Class: ' + BugInfo.ExceptionClass;
  LblDateCreated.Caption := 'Occurence Date: ' + DateTimeToStr(BugInfo.DateCreated);
  LblMachineName.Caption := 'Machine Name: ' + BugInfo.MachineName;
  LblVersionNumber.Caption := 'Version Number: ' + BugInfo.VersionNumber;
  LblLineNumber.Caption := 'Line: ' + IntToStr(BugInfo.LineNumber);
  LblMethodName.Caption := 'Method: ' + Buginfo.MethodName;
  ComBoxPriority.ItemIndex := BugInfo.Priority;
end;

procedure TDetailedWindow.SaveChanges;
begin
  DataModuleBugAndFilter.QrySaveChanges.ParamByName('Priority').AsInteger := ComBoxPriority.ItemIndex;
  DataModuleBugAndFilter.QrySaveChanges.ParamByName('ID').AsInteger := BugInfo.ID;
  DataModuleBugAndFilter.QrySaveChanges.ExecSQL;
  try
    if DataModuleBugAndFilter.QrySaveChanges.RowsAffected = 0 then
      MessageDlg('Changes Could not be saved', mtError, [mbOK], 0);
  finally
    DataModuleBugAndFilter.QrySaveChanges.Close;
  end;
end;

end.
