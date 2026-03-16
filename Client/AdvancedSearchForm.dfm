object AdvancedSearchPage: TAdvancedSearchPage
  Left = 0
  Top = 0
  Caption = 'AdvancedSearch'
  ClientHeight = 310
  ClientWidth = 513
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 15
  object LblPriority: TLabel
    Left = 8
    Top = 195
    Width = 38
    Height = 15
    Caption = 'Priority'
  end
  object LblFromDate: TLabel
    Left = 8
    Top = 120
    Width = 28
    Height = 15
    Caption = 'From'
  end
  object LblToDate: TLabel
    Left = 288
    Top = 120
    Width = 13
    Height = 15
    Caption = 'To'
  end
  object ComBoxPriority: TComboBox
    Left = 8
    Top = 216
    Width = 186
    Height = 23
    TabOrder = 6
    TextHint = 'Priority'
    Items.Strings = (
      '0 - Unassigned'
      '1 - Low'
      '2 - Medium'
      '3 - High'
      '4 - Critical')
  end
  object BtnSearch: TButton
    Left = 399
    Top = 264
    Width = 75
    Height = 25
    Caption = 'Search'
    TabOrder = 7
    OnClick = BtnSearchClick
  end
  object DTPToDate: TDateTimePicker
    Left = 288
    Top = 152
    Width = 186
    Height = 23
    Date = 45949.000000000000000000
    Time = 0.713423773151589600
    ShowCheckbox = True
    Checked = False
    TabOrder = 5
  end
  object DTPFromDate: TDateTimePicker
    Left = 8
    Top = 152
    Width = 186
    Height = 23
    Date = 45949.000000000000000000
    Time = 0.714062442129943500
    ShowCheckbox = True
    Checked = False
    TabOrder = 4
  end
  object EdtMachine: TEdit
    Left = 8
    Top = 80
    Width = 186
    Height = 23
    TabOrder = 2
    TextHint = 'Machine'
  end
  object EdtExceptionClass: TEdit
    Left = 288
    Top = 24
    Width = 186
    Height = 23
    TabOrder = 1
    TextHint = 'Exception Class'
  end
  object EdtExceptionMessage: TEdit
    Left = 8
    Top = 24
    Width = 186
    Height = 23
    TabOrder = 0
    TextHint = 'Exception Message'
  end
  object EdtVersionNumber: TEdit
    Left = 288
    Top = 80
    Width = 186
    Height = 23
    TabOrder = 3
    TextHint = 'Version'
  end
end
