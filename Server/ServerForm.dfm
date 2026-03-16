object ServerWindow: TServerWindow
  Left = 0
  Top = 0
  Caption = 'Bug server'
  ClientHeight = 441
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnClose = FormClose
  OnCreate = FormCreate
  TextHeight = 15
  object HTTPBugServer: TIdHTTPServer
    Bindings = <>
    DefaultPort = 43290
    OnCommandGet = HTTPBugServerCommandGet
    Left = 40
    Top = 352
  end
end
