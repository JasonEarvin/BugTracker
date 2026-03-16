object DataModuleBugAndFilter: TDataModuleBugAndFilter
  OnDestroy = DataModuleDestroy
  Height = 900
  Width = 1200
  PixelsPerInch = 144
  object ConBugReports: TFDConnection
    Params.Strings = (
      'User_Name=sysdba'
      'Password=masterkey'
      
        'Database=C:\Users\Jason\OneDrive\Documents\Embarcadero\Studio\Pr' +
        'ojects\BugTracker\Database\BUGREPORTS.FDB'
      'DriverID=FB'
      'Pooled=False')
    Left = 58
    Top = 38
  end
  object QrySaveChanges: TFDQuery
    Connection = ConBugReports
    SQL.Strings = (
      'Update BugReports'
      'Set Priority = :Priority'
      'Where BugReportIDX = :ID')
    Left = 374
    Top = 38
    ParamData = <
      item
        Name = 'PRIORITY'
        ParamType = ptInput
      end
      item
        Name = 'ID'
        ParamType = ptInput
      end>
  end
  object QryAddFilterWord: TFDQuery
    Connection = ConBugReports
    SQL.Strings = (
      'Insert into FilteredWords (Word)'
      'Values (:NewWord)')
    Left = 58
    Top = 173
    ParamData = <
      item
        Name = 'NEWWORD'
        ParamType = ptInput
      end>
  end
  object QryGetFilterWord: TFDQuery
    Connection = ConBugReports
    SQL.Strings = (
      'Select Word from FilteredWords'
      'Order By Lower(Word)')
    Left = 230
    Top = 173
  end
  object QryDeleteFilterWord: TFDQuery
    Connection = ConBugReports
    SQL.Strings = (
      'Delete from FilteredWords'
      'Where Word = :FilterWord')
    Left = 394
    Top = 173
    ParamData = <
      item
        Name = 'FILTERWORD'
        ParamType = ptInput
      end>
  end
  object QryUpdateFilterWord: TFDQuery
    Connection = ConBugReports
    SQL.Strings = (
      'Update FilteredWords'
      'Set Word = :NewWord'
      'Where Word = :OldWord')
    Left = 576
    Top = 173
    ParamData = <
      item
        Name = 'NEWWORD'
        ParamType = ptInput
      end
      item
        Name = 'OLDWORD'
        ParamType = ptInput
      end>
  end
  object QryDeleteBugReport: TFDQuery
    Connection = ConBugReports
    SQL.Strings = (
      'Delete from BugReports'
      'Where BugReportIDX = :BugReportID')
    Left = 548
    Top = 38
    ParamData = <
      item
        Name = 'BUGREPORTID'
        ParamType = ptInput
      end>
  end
  object QryAdvancedSearch: TFDQuery
    Connection = ConBugReports
    Left = 58
    Top = 278
  end
  object QryBugReportsCount: TFDQuery
    Connection = ConBugReports
    Left = 232
    Top = 280
  end
  object QryGetBugReports: TFDQuery
    Connection = ConBugReports
    SQL.Strings = (
      'Select * '
      'From BugReports'
      'Order By BugReportIDX')
    Left = 212
    Top = 26
  end
end
