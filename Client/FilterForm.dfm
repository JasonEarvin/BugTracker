object FilterPage: TFilterPage
  Left = 0
  Top = 0
  Caption = 'Filter'
  ClientHeight = 441
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    624
    441)
  TextHeight = 15
  object PnlTop: TPanel
    Left = 0
    Top = 0
    Width = 624
    Height = 41
    Align = alTop
    Caption = 'PnlTop'
    ShowCaption = False
    TabOrder = 0
    ExplicitWidth = 622
    object BtnAddWord: TButton
      Left = 135
      Top = 10
      Width = 75
      Height = 25
      Action = AddAction
      TabOrder = 0
    end
    object EdtNewWord: TEdit
      Left = 8
      Top = 10
      Width = 121
      Height = 23
      TabOrder = 1
      TextHint = 'Word: '
    end
  end
  object PnlClient: TPanel
    Left = 0
    Top = 41
    Width = 624
    Height = 400
    Align = alClient
    Caption = 'PnlClient'
    ShowCaption = False
    TabOrder = 1
    ExplicitLeft = -8
    ExplicitTop = 33
    DesignSize = (
      624
      400)
    object LivWordList: TListView
      Left = 8
      Top = 16
      Width = 377
      Height = 369
      Anchors = [akLeft, akTop, akBottom]
      Columns = <
        item
          Caption = 'Word'
          Width = 200
        end>
      ReadOnly = True
      TabOrder = 0
      ViewStyle = vsReport
      OnSelectItem = LivWordListSelectItem
    end
    object BtnDeleteWord: TButton
      Left = 541
      Top = 54
      Width = 75
      Height = 25
      Action = DeleteAction
      TabOrder = 1
    end
    object EdtWordEdit: TEdit
      Left = 401
      Top = 17
      Width = 121
      Height = 23
      Anchors = [akTop, akRight]
      TabOrder = 2
      TextHint = 'Select a word'
    end
  end
  object BtnEdit: TButton
    Left = 541
    Top = 57
    Width = 75
    Height = 25
    Action = EditAction
    Anchors = [akTop, akRight]
    TabOrder = 2
  end
  object AliFilter: TActionList
    Left = 40
    Top = 392
    object AddAction: TAction
      Caption = 'Add'
      OnExecute = AddActionExecute
      OnUpdate = AddActionUpdate
    end
    object DeleteAction: TAction
      Caption = 'Delete'
      OnExecute = DeleteActionExecute
      OnUpdate = DeleteActionUpdate
    end
    object EditAction: TAction
      Caption = 'Edit'
      OnExecute = EditActionExecute
      OnUpdate = EditActionUpdate
    end
  end
end
