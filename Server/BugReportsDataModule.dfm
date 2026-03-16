object DataModuleBugReports: TDataModuleBugReports
  Height = 900
  Width = 1200
  PixelsPerInch = 144
  object ConBugReports: TFDConnection
    Params.Strings = (
      'User_Name=sysdba'
      'Password=masterkey'
      
        'Database=C:\Users\Jason\OneDrive\Documents\Embarcadero\Studio\Pr' +
        'ojects\BugTracker\Database\BUGREPORTS.FDB'
      'DriverID=FB')
    Left = 48
    Top = 59
  end
  object QrySaveBugReport: TFDQuery
    Connection = ConBugReports
    SQL.Strings = (
      'INSERT INTO BUGREPORTS (EXCEPTIONMESSAGE, '
      '  EXCEPTIONCLASS, MACHINENAME, '
      '  VERSIONNUMBER, DATECREATED, Priority, '
      '  LINENUMBER, METHODNAME)'
      'Values (:ExceptionMessage, '
      '  :ExceptionClass,:MachineName, '
      '  :VersionNumber, :DateCreated, 0,'
      '  :LineNumber, :MethodName)'
      'Returning BugReportIDX')
    Left = 240
    Top = 59
    ParamData = <
      item
        Name = 'EXCEPTIONMESSAGE'
        ParamType = ptInput
      end
      item
        Name = 'EXCEPTIONCLASS'
        ParamType = ptInput
      end
      item
        Name = 'MACHINENAME'
        ParamType = ptInput
      end
      item
        Name = 'VERSIONNUMBER'
        ParamType = ptInput
      end
      item
        Name = 'DATECREATED'
        ParamType = ptInput
      end
      item
        Name = 'LINENUMBER'
        ParamType = ptInput
      end
      item
        Name = 'METHODNAME'
        ParamType = ptInput
      end>
  end
  object QryGetFilterWords: TFDQuery
    Connection = ConBugReports
    SQL.Strings = (
      'Select Word from filteredWords')
    Left = 231
    Top = 183
  end
end
