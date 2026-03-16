unit ServerForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, IdBaseComponent,
  IdComponent, IdCustomTCPServer, IdCustomHTTPServer, IdHTTPServer, IdContext,
  System.IOUtils, Vcl.ComCtrls;

type
  TServerWindow = class(TForm)
    HTTPBugServer: TIdHTTPServer;
    procedure FormCreate(Sender: TObject);
    procedure HTTPBugServerCommandGet(AContext: TIdContext;
      ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
  public
  end;

var
  ServerWindow: TServerWindow;

implementation

{$R *.dfm}

uses
  ErrorForm,
  //TwConstants,
  DataProcessor;

procedure TServerWindow.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  HTTPBugServer.Active := False;
end;

procedure TServerWindow.FormCreate(Sender: TObject);
begin
  HTTPBugServer.DefaultPort := 43290;
  HTTPBugServer.Active := True;
end;

procedure TServerWindow.HTTPBugServerCommandGet(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  BugInfo : TBugInfo;
begin
  // Authorisation has not been setup so this function always returns true
  if CheckAuthorisation <> True then
  begin
    AResponseInfo.ResponseNo := 401;
    AResponseInfo.ResponseText := 'Unauthorised Access';
    Exit;
  end;

  BugInfo := TBugInfo.Create;
  try
    BugInfo.ProcessBugInfo(ARequestInfo);
  finally
    BugInfo.Free;
  end;
end;

end.
