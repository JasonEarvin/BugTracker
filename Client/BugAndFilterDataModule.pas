unit BugAndFilterDataModule;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.FB,
  FireDAC.Phys.FBDef, FireDAC.VCLUI.Wait, Data.DB, FireDAC.Comp.Client,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Comp.DataSet;

type
  TDataModuleBugAndFilter = class(TDataModule)
    ConBugReports: TFDConnection;
    QrySaveChanges: TFDQuery;
    QryAddFilterWord: TFDQuery;
    QryGetFilterWord: TFDQuery;
    QryDeleteFilterWord: TFDQuery;
    QryUpdateFilterWord: TFDQuery;
    QryDeleteBugReport: TFDQuery;
    QryAdvancedSearch: TFDQuery;
    QryBugReportsCount: TFDQuery;
    QryGetBugReports: TFDQuery;
    procedure DataModuleDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DataModuleBugAndFilter: TDataModuleBugAndFilter;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure TDataModuleBugAndFilter.DataModuleDestroy(Sender: TObject);
begin
  if ConBugReports.Connected then
    ConBugReports.Close;
end;

end.
