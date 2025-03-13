VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "ЭтаКнига"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = True
Private Sub Workbook_Open()
    ' Вызов основного макроса при открытии файла
    On Error Resume Next
    Call ConsolidateDataAndAddAPI
    If Err.Number <> 0 Then
        MsgBox "Произошла ошибка при выполнении макроса: " & Err.Description
    End If
    On Error GoTo 0
End Sub
