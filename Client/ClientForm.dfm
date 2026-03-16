object ClientPage: TClientPage
  Left = 0
  Top = 0
  Caption = 'Client Form'
  ClientHeight = 683
  ClientWidth = 1094
  Color = clBtnFace
  Constraints.MinHeight = 250
  Constraints.MinWidth = 500
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnClose = FormClose
  OnCreate = FormCreate
  TextHeight = 15
  object PnlTop: TPanel
    Left = 0
    Top = 0
    Width = 1094
    Height = 49
    Align = alTop
    Caption = 'PnlTop'
    ShowCaption = False
    TabOrder = 0
    DesignSize = (
      1094
      49)
    object BtnError: TButton
      Left = 880
      Top = 11
      Width = 75
      Height = 25
      Caption = 'Error'
      TabOrder = 0
      Visible = False
      OnClick = BtnErrorClick
    end
    object BtnOpenFile: TButton
      Left = 1007
      Top = 10
      Width = 75
      Height = 25
      Action = OpenBugInfoAction
      Anchors = [akTop, akRight]
      Caption = 'Open'
      TabOrder = 1
      ExplicitLeft = 1001
    end
    object BtnRefresh: TButton
      Left = 666
      Top = 10
      Width = 75
      Height = 23
      Anchors = [akTop, akRight]
      Caption = 'Refresh'
      TabOrder = 2
      OnClick = BtnRefreshClick
      ExplicitLeft = 660
    end
    object EdtSearch: TEdit
      Left = 8
      Top = 10
      Width = 121
      Height = 23
      TabOrder = 3
      TextHint = 'Search'
      OnKeyPress = EdtSearchKeyPress
    end
    object DtpFrom: TDateTimePicker
      Left = 304
      Top = 10
      Width = 89
      Height = 23
      Date = 46080.000000000000000000
      Time = 0.658798599535657600
      TabOrder = 4
    end
    object DtpTo: TDateTimePicker
      Left = 399
      Top = 10
      Width = 89
      Height = 23
      Date = 46080.000000000000000000
      Time = 0.659527245370554700
      TabOrder = 5
    end
    object BtnSearch: TButton
      Left = 504
      Top = 10
      Width = 75
      Height = 23
      Caption = 'Search'
      TabOrder = 6
      OnClick = BtnSearchClick
    end
    object BtnClear: TButton
      Left = 585
      Top = 10
      Width = 75
      Height = 23
      Caption = 'Clear'
      TabOrder = 7
      OnClick = BtnClearClick
    end
    object CbbTypes: TComboBox
      Left = 143
      Top = 10
      Width = 146
      Height = 23
      Style = csDropDownList
      TabOrder = 8
      Items.Strings = (
        'Exception Message'
        'Exception Class'
        'Machine Name')
    end
  end
  object PnlClient: TPanel
    Left = 0
    Top = 49
    Width = 1094
    Height = 593
    Align = alClient
    Caption = 'PnlClient'
    ShowCaption = False
    TabOrder = 1
    ExplicitTop = 81
    ExplicitWidth = 1088
    ExplicitHeight = 544
    object DBGridBugs: TDBGrid
      Left = 1
      Top = 1
      Width = 1092
      Height = 591
      Align = alClient
      DataSource = DSBugs
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -12
      TitleFont.Name = 'Segoe UI'
      TitleFont.Style = []
      Columns = <
        item
          Expanded = False
          FieldName = 'BUGREPORTIDX'
          Visible = False
        end
        item
          Expanded = False
          FieldName = 'EXCEPTIONMESSAGE'
          Title.Caption = 'Exception message'
          Width = 542
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'EXCEPTIONCLASS'
          Title.Caption = 'Exception Class'
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'MACHINENAME'
          Title.Caption = 'Machine Name'
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'VERSIONNUMBER'
          Title.Caption = 'Version Number'
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'DATECREATED'
          Title.Caption = 'Date Created'
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'PRIORITY'
          Title.Caption = 'Priority'
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'LINENUMBER'
          Title.Caption = 'Line Number'
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'METHODNAME'
          Title.Caption = 'Method Name'
          Visible = True
        end>
    end
  end
  object PnlBottom: TPanel
    Left = 0
    Top = 642
    Width = 1094
    Height = 41
    Align = alBottom
    Caption = 'PnlBottom'
    ShowCaption = False
    TabOrder = 2
    ExplicitTop = 625
    ExplicitWidth = 1088
    DesignSize = (
      1094
      41)
    object LblBugCount: TLabel
      Left = 721
      Top = 13
      Width = 50
      Height = 15
      Anchors = [akRight, akBottom]
      Caption = 'Page Info'
      Constraints.MaxWidth = 250
      ExplicitLeft = 517
    end
    object BtnPrevious: TButton
      Left = 905
      Top = 6
      Width = 75
      Height = 25
      Action = PreviousPageAction
      Anchors = [akRight, akBottom]
      TabOrder = 0
      ExplicitLeft = 899
    end
    object BtnNext: TButton
      Left = 1006
      Top = 6
      Width = 75
      Height = 25
      Action = NextPageAction
      Anchors = [akRight, akBottom]
      TabOrder = 1
      ExplicitLeft = 1000
    end
  end
  object AliClient: TActionList
    Left = 24
    Top = 520
    object OpenBugInfoAction: TAction
      Caption = 'OpenFile'
      OnExecute = OpenBugInfoActionExecute
      OnUpdate = OpenBugInfoActionUpdate
    end
    object NextPageAction: TAction
      Caption = 'Next'
      OnExecute = BtnNextClick
      OnUpdate = NextPageActionUpdate
    end
    object PreviousPageAction: TAction
      Caption = 'Previous'
      OnExecute = BtnPreviousClick
      OnUpdate = PreviousPageActionUpdate
    end
  end
  object DSBugs: TDataSource
    DataSet = QryGetBugReports
    Left = 224
    Top = 448
  end
  object QryGetBugReports: TFDQuery
    Connection = ConBugReports
    SQL.Strings = (
      'Select * '
      'From BugReports'
      'Order By BugReportIDX')
    Left = 124
    Top = 194
    object QryGetBugReportsBUGREPORTIDX: TIntegerField
      FieldName = 'BUGREPORTIDX'
      Origin = 'BUGREPORTIDX'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
      Required = True
    end
    object QryGetBugReportsEXCEPTIONMESSAGE: TStringField
      FieldName = 'EXCEPTIONMESSAGE'
      Origin = 'EXCEPTIONMESSAGE'
      Size = 2000
    end
    object QryGetBugReportsEXCEPTIONCLASS: TStringField
      FieldName = 'EXCEPTIONCLASS'
      Origin = 'EXCEPTIONCLASS'
      Size = 2000
    end
    object QryGetBugReportsMACHINENAME: TStringField
      FieldName = 'MACHINENAME'
      Origin = 'MACHINENAME'
      Size = 50
    end
    object QryGetBugReportsVERSIONNUMBER: TStringField
      FieldName = 'VERSIONNUMBER'
      Origin = 'VERSIONNUMBER'
      Size = 50
    end
    object QryGetBugReportsDATECREATED: TSQLTimeStampField
      FieldName = 'DATECREATED'
      Origin = 'DATECREATED'
    end
    object QryGetBugReportsPRIORITY: TIntegerField
      FieldName = 'PRIORITY'
      Origin = 'PRIORITY'
    end
    object QryGetBugReportsLINENUMBER: TIntegerField
      FieldName = 'LINENUMBER'
      Origin = 'LINENUMBER'
    end
    object QryGetBugReportsMETHODNAME: TStringField
      FieldName = 'METHODNAME'
      Origin = 'METHODNAME'
      Size = 100
    end
  end
  object ConBugReports: TFDConnection
    Params.Strings = (
      'User_Name=sysdba'
      'Password=masterkey'
      
        'Database=C:\Users\Jason\OneDrive\Documents\Embarcadero\Studio\Pr' +
        'ojects\BugTracker\Database\BUGREPORTS.FDB'
      'DriverID=FB'
      'Pooled=False')
    Connected = True
    LoginPrompt = False
    Left = 266
    Top = 166
  end
  object QryBugReportsCount: TFDQuery
    Connection = ConBugReports
    Left = 440
    Top = 408
  end
end
