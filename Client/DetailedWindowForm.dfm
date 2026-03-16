object DetailedWindow: TDetailedWindow
  Left = 0
  Top = 0
  Caption = 'Detailed Window'
  ClientHeight = 247
  ClientWidth = 534
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnClose = FormClose
  OnShow = FormShow
  DesignSize = (
    534
    247)
  TextHeight = 15
  object PnlTop: TPanel
    Left = 0
    Top = 0
    Width = 534
    Height = 60
    Align = alTop
    Caption = 'PnlTop'
    ShowCaption = False
    TabOrder = 0
    ExplicitWidth = 524
    DesignSize = (
      534
      60)
    object LblExceptionMessage: TLabel
      Left = 1
      Top = 21
      Width = 297
      Height = 30
      AutoSize = False
      Caption = 'Exception Message:'
      WordWrap = True
    end
    object BtnOpenFile: TButton
      Left = 451
      Top = 11
      Width = 65
      Height = 35
      Anchors = [akTop, akRight]
      Caption = 'Open File'
      TabOrder = 0
      OnClick = BtnOpenFileClick
      ExplicitLeft = 441
    end
  end
  object PnlClient: TPanel
    Left = 0
    Top = 60
    Width = 534
    Height = 187
    Align = alClient
    Caption = 'PnlClient'
    ShowCaption = False
    TabOrder = 1
    ExplicitWidth = 524
    ExplicitHeight = 155
    object LblDateCreated: TLabel
      Left = 8
      Top = 99
      Width = 33
      Height = 15
      Caption = 'Time: '
    end
    object LblExceptionClass: TLabel
      Left = 8
      Top = 32
      Width = 87
      Height = 15
      Caption = 'Exception Class: '
    end
    object LblMachineName: TLabel
      Left = 256
      Top = 32
      Width = 87
      Height = 15
      Caption = 'Machine Name: '
    end
    object LblVersionNumber: TLabel
      Left = 256
      Top = 99
      Width = 91
      Height = 15
      Caption = 'Version Number: '
    end
    object LblLineNumber: TLabel
      Left = 256
      Top = 63
      Width = 72
      Height = 15
      Caption = 'LineNumber: '
    end
    object LblMethodName: TLabel
      Left = 8
      Top = 63
      Width = 42
      Height = 15
      Caption = 'Method'
    end
    object ComBoxPriority: TComboBox
      Left = 8
      Top = 152
      Width = 145
      Height = 23
      TabOrder = 0
      Text = 'ComBoxPriority'
      Items.Strings = (
        '0 - Unassigned'
        '1 - Low'
        '2 - Medium'
        '3 - High'
        '4 - Critical'
        ''
        ''
        ''
        '')
    end
  end
  object BtnDeleteBug: TButton
    Left = 451
    Top = 214
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Delete'
    TabOrder = 2
    OnClick = BtnDeleteBugClick
    ExplicitLeft = 441
    ExplicitTop = 182
  end
end
