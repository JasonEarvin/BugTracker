program BugServerClient;

uses
  Vcl.Forms,
  ClientForm in 'ClientForm.pas' {ClientPage},
  ErrorForm in '..\Server\ErrorForm.pas' {ErrorWindow},
  DetailedWindowForm in 'DetailedWindowForm.pas' {DetailedWindow},
  BugInfo in 'BugInfo.pas',
  FilterForm in 'FilterForm.pas' {FilterPage},
  BugAndFilterDataModule in 'BugAndFilterDataModule.pas' {DataModuleBugAndFilter: TDataModule},
  AdvancedSearchForm in 'AdvancedSearchForm.pas' {AdvancedSearchPage};

{$R *.res}

begin
//  RegisterExceptionHandler(TClientPage.ErrorHandler, stTrySyncCallOnSuccess, epMainPhase);
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TDataModuleBugAndFilter, DataModuleBugAndFilter);
  Application.CreateForm(TClientPage, ClientPage);
  Application.CreateForm(TErrorWindow, ErrorWindow);
  Application.CreateForm(TDetailedWindow, DetailedWindow);
  Application.CreateForm(TFilterPage, FilterPage);
  Application.CreateForm(TAdvancedSearchPage, AdvancedSearchPage);
  Application.Run;
end.
