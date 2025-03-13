Attribute VB_Name = "Module1"
Sub ConsolidateDataAndAddAPI()
    Dim wsUnit As Worksheet, wsRealization As Worksheet, wsPlan As Worksheet, wsCHFR As Worksheet
    Dim wbNew As Workbook
    Dim lastRowUnit As Long, lastRowRealization As Long, lastRowPlan As Long
    Dim i As Long, j As Long
    Dim articleWB As String
    Dim costPrice As Double
    Dim revenue As Double
    Dim commission As Double
    Dim logistics As Double
    Dim totalRevenue As Double
    Dim totalCosts As Double
    Dim totalMargin As Double
    
    ' ������� ����� ���� Excel
    Set wbNew = Workbooks.Add
    
    ' ��������� ����� ��� ������
    Set wsUnit = wbNew.Sheets.Add
    wsUnit.Name = "����"
    
    Set wsRealization = wbNew.Sheets.Add
    wsRealization.Name = "����������"
    
    Set wsPlan = wbNew.Sheets.Add
    wsPlan.Name = "���� ��������"
    
    Set wsCHFR = wbNew.Sheets.Add
    wsCHFR.Name = "����������� ���"
    
    ' �������� ������ �� ������ � ��������������� �����
    CopyDataToSheet "/Users/dariapoliakova/Downloads/����.xlsx", wsUnit
    CopyDataToSheet "/Users/dariapoliakova/Downloads/���������� 12-01.xlsx", wsRealization
    CopyDataToSheet "/Users/dariapoliakova/Downloads/���� �������� �� �������� (3).xlsx", wsPlan
    CopyDataToSheet "/Users/dariapoliakova/Downloads/����������� ���..xlsx", wsCHFR
    
    ' ����������� ��������� ����� � ��������
    lastRowUnit = wsUnit.Cells(wsUnit.Rows.Count, "A").End(xlUp).Row
    lastRowRealization = wsRealization.Cells(wsRealization.Rows.Count, "A").End(xlUp).Row
    lastRowPlan = wsPlan.Cells(wsPlan.Rows.Count, "A").End(xlUp).Row
    
    totalRevenue = 0
    totalCosts = 0
    totalMargin = 0
    
    ' ������ ���������� � ����� ����
    wsCHFR.Cells(1, 1).Value = "������� WB"
    wsCHFR.Cells(1, 2).Value = "���������� ���������"
    wsCHFR.Cells(1, 3).Value = "�������"
    wsCHFR.Cells(1, 4).Value = "�������������� (%)"
    wsCHFR.Cells(1, 5).Value = "������� �� API"
    wsCHFR.Cells(1, 6).Value = "������� �� API"
    
    Dim outputRow As Long
    outputRow = 2
    
    ' ���� �� ������ ����������
    For i = 2 To lastRowRealization
        articleWB = wsRealization.Cells(i, 1).Value
        revenue = wsRealization.Cells(i, 8).Value
        commission = wsRealization.Cells(i, 10).Value
        logistics = wsRealization.Cells(i, 12).Value
        
        ' ����� ������������� � ����� ����
        For j = 2 To lastRowUnit
            If wsUnit.Cells(j, 1).Value = articleWB Then
                costPrice = wsUnit.Cells(j, 7).Value * wsRealization.Cells(i, 9).Value
                Exit For
            End If
        Next j
        
        ' ������������ ����� ��������
        totalRevenue = totalRevenue + revenue
        totalCosts = totalCosts + commission + logistics + costPrice
        totalMargin = totalMargin + (revenue - (commission + logistics + costPrice))
        
        ' ���������� ������� ������������� � ����� ��������
        For j = 2 To lastRowPlan
            If wsPlan.Cells(j, 1).Value = articleWB Then
                ' ���������, ��� �������� � ������ �� ����� 0 � �� ������
                If IsNumeric(wsRealization.Cells(i, 9).Value) And wsRealization.Cells(i, 9).Value <> 0 Then
                    wsPlan.Cells(j, 5).Value = costPrice / wsRealization.Cells(i, 9).Value
                Else
                    wsPlan.Cells(j, 5).Value = 0
                End If
                
                wsPlan.Cells(j, 6).Value = wsPlan.Cells(j, 4).Value * wsPlan.Cells(j, 5).Value
                
                ' ������ ������ � ����� ����
                wsCHFR.Cells(outputRow, 1).Value = articleWB
                wsCHFR.Cells(outputRow, 2).Value = revenue - (commission + logistics + costPrice)
                wsCHFR.Cells(outputRow, 3).Value = wsPlan.Cells(j, 4).Value
                
                ' ���������, ��� revenue �� ����� 0
                If revenue <> 0 Then
                    ' �������� �� 100 � ����������� ��� �������
                    wsCHFR.Cells(outputRow, 4).Value = Format((revenue - (commission + logistics + costPrice)) / revenue * 100, "0.00") & "%"
                Else
                    wsCHFR.Cells(outputRow, 4).Value = "0%"
                End If
                
                ' ��������� ������ ����� API Wildberries
                Dim apiSales As String
                Dim apiStocks As String
                apiSales = GetWBAPI("https://statistics-api.wildberries.ru/api/v1/supplier/sales", articleWB)
                apiStocks = GetWBAPI("https://statistics-api.wildberries.ru/api/v1/supplier/stocks", articleWB)
                
                wsCHFR.Cells(outputRow, 5).Value = apiSales
                wsCHFR.Cells(outputRow, 6).Value = apiStocks
                
                outputRow = outputRow + 1
                
                Exit For
            End If
        Next j
    Next i
    
    ' ����� �������� ����������� � ����� ����
    wsCHFR.Cells(outputRow, 1).Value = "�����:"
    wsCHFR.Cells(outputRow, 2).Value = totalMargin
    wsCHFR.Cells(outputRow, 3).Value = "��. ����"
    
    ' ���������, ��� totalRevenue �� ����� 0
    If totalRevenue <> 0 Then
        ' �������� �� 100 � ����������� ��� �������
        wsCHFR.Cells(outputRow, 4).Value = Format(totalMargin / totalRevenue * 100, "0.00") & "%"
    Else
        wsCHFR.Cells(outputRow, 4).Value = "0%"
    End If
    
    MsgBox "��������� ���������!"
End Sub

Sub CopyDataToSheet(filePath As String, ws As Worksheet)
    Dim wbSource As Workbook
    On Error Resume Next
    Set wbSource = Workbooks.Open(filePath)
    On Error GoTo 0
    
    If Not wbSource Is Nothing Then
        wbSource.Sheets(1).Cells.Copy Destination:=ws.Cells(1, 1)
        wbSource.Close SaveChanges:=False
    Else
        MsgBox "�� ������� ������� ����: " & filePath
    End If
End Sub

Function GetWBAPI(ByVal apiUrl As String, ByVal article As String) As String
    Dim http As Object
    Dim apiKey As String
    Dim response As String
    
    ' ������� ��� API-���� Wildberries
    apiKey = "YOUR_API_KEY_HERE"
    
    ' ������� ������ ��� HTTP-�������
    Set http = CreateObject("MSXML2.XMLHTTP")
    
    ' ��������� URL � �����������
    Dim url As String
    url = apiUrl & "?dateFrom=2024-01-01&article=" & article
    
    ' ��������� GET-������
    On Error Resume Next
    http.Open "GET", url, False
    http.setRequestHeader "Authorization", apiKey
    http.Send
    
    ' �������� �����
    If http.Status = 200 Then
        response = http.responseText
    Else
        response = "������: " & http.Status & " " & http.statusText
    End If
    
    On Error GoTo 0
    
    ' ���������� ���������
    GetWBAPI = response
End Function
