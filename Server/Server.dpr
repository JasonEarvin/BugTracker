program Server;

uses
  madExcept,
  Vcl.Forms,
  ServerForm in 'ServerForm.pas' {ServerWindow},
  ErrorForm in 'ErrorForm.pas' {ErrorWindow},
  DataProcessor in 'DataProcessor.pas',
  BugReportsDataModule in 'BugReportsDataModule.pas' {DataModuleBugReports: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TServerWindow, ServerWindow);
  Application.CreateForm(TErrorWindow, ErrorWindow);
  Application.CreateForm(TDataModuleBugReports, DataModuleBugReports);
  Application.Run;
end.
