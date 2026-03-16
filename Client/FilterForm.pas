unit FilterForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.Actions,
  Vcl.ActnList, FireDAC.Stan.Param, System.UITypes, Data.DB, Vcl.ComCtrls,
  Vcl.ExtCtrls;

type
  TFilterPage = class(TForm)
    EdtNewWord: TEdit;
    BtnAddWord: TButton;
    AliFilter: TActionList;
    AddAction: TAction;
    PnlTop: TPanel;
    PnlClient: TPanel;
    LivWordList: TListView;
    BtnDeleteWord: TButton;
    DeleteAction: TAction;
    BtnEdit: TButton;
    EditAction: TAction;
    EdtWordEdit: TEdit;
    procedure AddActionUpdate(Sender: TObject);
    procedure AddActionExecute(Sender: TObject);
    procedure DeleteActionUpdate(Sender: TObject);
    procedure DeleteActionExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure EditActionExecute(Sender: TObject);
    procedure LivWordListSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure EditActionUpdate(Sender: TObject);
  private
    WordList : TStringList;
    SelectedWord : String;
    procedure RetrieveFilterWords;
    procedure LoadListView;
  public
    { Public declarations }
  end;

var
  FilterPage: TFilterPage;

implementation

{$R *.dfm}

uses BugAndFilterDataModule;

procedure TFilterPage.AddActionExecute(Sender: TObject);
var
  NewWord : string;
begin
  NewWord := EdtNewWord.Text;
  DataModuleBugAndFilter.QryAddFilterWord.ParamByName('NewWord').AsString := NewWord;

  if WordList.Contains(NewWord) then
    MessageDlg('Word already exists', mtError, [mbOK], 0)
  else
  begin
    DataModuleBugAndFilter.QryAddFilterWord.ExecSQL;
    try
      if DataModuleBugAndFilter.QryAddFilterWord.RowsAffected = 0 then
        MessageDlg('Word could not be saved', mtError, [mbOK], 0)
      else
        MessageDlg('Successfully saved new word', mtInformation, [mbOk], 0);
        EdtNewWord.Clear;
    finally
      DataModuleBugAndFilter.QryAddFilterWord.Close;
    end;
  end;

end;

procedure TFilterPage.AddActionUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := EdtNewWord.Text <> '';
end;

procedure TFilterPage.DeleteActionExecute(Sender: TObject);
begin
  case MessageDlg('Are you sure?', mtConfirmation, [mbOK, mbCancel], 0) of
    mrOk:
      begin
        DataModuleBugAndFilter.QryDeleteFilterWord.ParamByName('FilterWord').AsString := LivWordList.Selected.Caption;
        DataModuleBugAndFilter.QryDeleteFilterWord.ExecSQL;
        try
          if DataModuleBugAndFilter.QryDeleteFilterWord.RowsAffected <> 1 then
            MessageDlg('An error occured whilst deleting', mtError, [mbOK], 0)
          else
            WordList.Delete(LivWordList.Selected.Index);
        finally
          DataModuleBugAndFilter.QryDeleteFilterWord.Close;
        end;
        LoadListView;
      end;

  end;
end;

procedure TFilterPage.DeleteActionUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := (LivWordList.Selected <> nil);
end;

procedure TFilterPage.EditActionExecute(Sender: TObject);
var
  NewWord : String;
begin
  NewWord := EdtWordEdit.Text;
  DataModuleBugAndFilter.QryUpdateFilterWord.ParamByName('NewWord').AsString := NewWord;
  DataModuleBugAndFilter.QryUpdateFilterWord.ParamByName('OldWord').AsString := SelectedWord;

  DataModuleBugAndFilter.QryUpdateFilterWord.ExecSQL;
  try
    if DataModuleBugAndFilter.QryUpdateFilterWord.RowsAffected <> 1 then
      MessageDlg('An error occured whilst updating word', mtError, [mbOK], 0)
    else
      WordList[LivWordList.Selected.Index] := NewWord;
  finally
    DataModuleBugAndFilter.QryUpdateFilterWord.Close;
  end;

  LivWordList.ClearSelection;
  EdtWordEdit.Text := '';
  LoadListView;
end;

procedure TFilterPage.EditActionUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := EdtWordEdit.Text <> SelectedWord;
end;

procedure TFilterPage.FormCreate(Sender: TObject);
begin
  WordList := TStringList.Create;
  RetrieveFilterWords;
  LoadListView;
end;

procedure TFilterPage.FormDestroy(Sender: TObject);
begin
  WordList.Free;
end;

procedure TFilterPage.LivWordListSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
var
  ItemWord : String;
begin
  ItemWord := Item.Caption;
  EdtWordEdit.Text := ItemWord;
  SelectedWord := ItemWord;
end;

procedure TFilterPage.LoadListView;
var
  ListItem : TListItem;
  WordIndex : integer;
begin
  LivWordList.Items.BeginUpdate;
  try
    LivWordList.Items.Clear;
    for WordIndex := 0 to WordList.Count - 1 do
    begin
      ListItem := LivWordList.Items.Add;
      ListItem.Caption := WordList[WordIndex];
    end;
  finally
    LivWordList.Items.EndUpdate;
  end;
end;

procedure TFilterPage.RetrieveFilterWords;
var
  FilterWord : string;
begin
  DataModuleBugAndFilter.QryGetFilterWord.Open;
  try
    while not DataModuleBugAndFilter.QryGetFilterWord.Eof do
    begin
      FilterWord := DataModuleBugAndFilter.QryGetFilterWord.FieldByName('Word').AsString;
      WordList.Add(FilterWord);
      DataModuleBugAndFilter.QryGetFilterWord.Next;
    end;
  finally
    DataModuleBugAndFilter.QryGetFilterWord.Close;
  end;
end;

end.
