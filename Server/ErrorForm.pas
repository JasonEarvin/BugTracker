unit ErrorForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, madExcept;

type
  TErrorWindow = class(TForm)
    BtnRestart: TButton;
    BtnClose: TButton;
    lblErrMessage: TLabel;
    procedure BtnRestartClick(Sender: TObject);
    procedure BtnCloseClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ErrorWindow: TErrorWindow;

implementation

{$R *.dfm}

procedure TErrorWindow.BtnCloseClick(Sender: TObject);
begin
  CloseApplication;
end;

procedure TErrorWindow.BtnRestartClick(Sender: TObject);
begin
  RestartApplication;
end;

end.
