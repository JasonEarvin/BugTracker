object ErrorWindow: TErrorWindow
  Left = 0
  Top = 0
  Caption = 'Error Window'
  ClientHeight = 89
  ClientWidth = 229
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 15
  object lblErrMessage: TLabel
    Left = 8
    Top = 16
    Width = 195
    Height = 15
    Caption = 'An error occurred in the application.'
  end
  object BtnRestart: TButton
    Left = 8
    Top = 47
    Width = 75
    Height = 25
    Caption = 'Restart'
    TabOrder = 0
    OnClick = BtnRestartClick
  end
  object BtnClose: TButton
    Left = 128
    Top = 47
    Width = 75
    Height = 25
    Caption = 'Close'
    TabOrder = 1
    OnClick = BtnCloseClick
  end
end
