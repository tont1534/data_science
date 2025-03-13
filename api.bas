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
    
    ' Создаем новый файл Excel
    Set wbNew = Workbooks.Add
    
    ' Добавляем листы для данных
    Set wsUnit = wbNew.Sheets.Add
    wsUnit.Name = "Юнит"
    
    Set wsRealization = wbNew.Sheets.Add
    wsRealization.Name = "Реализация"
    
    Set wsPlan = wbNew.Sheets.Add
    wsPlan.Name = "План поставок"
    
    Set wsCHFR = wbNew.Sheets.Add
    wsCHFR.Name = "Калькулятор ЧФР"
    
    ' Копируем данные из файлов в соответствующие листы
    CopyDataToSheet "/Users/dariapoliakova/Downloads/Юнит.xlsx", wsUnit
    CopyDataToSheet "/Users/dariapoliakova/Downloads/реализация 12-01.xlsx", wsRealization
    CopyDataToSheet "/Users/dariapoliakova/Downloads/План поставок по артикулу (3).xlsx", wsPlan
    CopyDataToSheet "/Users/dariapoliakova/Downloads/Калькулятор ЧФР..xlsx", wsCHFR
    
    ' Определение последних строк в таблицах
    lastRowUnit = wsUnit.Cells(wsUnit.Rows.Count, "A").End(xlUp).Row
    lastRowRealization = wsRealization.Cells(wsRealization.Rows.Count, "A").End(xlUp).Row
    lastRowPlan = wsPlan.Cells(wsPlan.Rows.Count, "A").End(xlUp).Row
    
    totalRevenue = 0
    totalCosts = 0
    totalMargin = 0
    
    ' Запись заголовков в новый лист
    wsCHFR.Cells(1, 1).Value = "Артикул WB"
    wsCHFR.Cells(1, 2).Value = "Финансовый результат"
    wsCHFR.Cells(1, 3).Value = "Остатки"
    wsCHFR.Cells(1, 4).Value = "Маржинальность (%)"
    wsCHFR.Cells(1, 5).Value = "Продажи по API"
    wsCHFR.Cells(1, 6).Value = "Остатки по API"
    
    Dim outputRow As Long
    outputRow = 2
    
    ' Цикл по данным реализации
    For i = 2 To lastRowRealization
        articleWB = wsRealization.Cells(i, 1).Value
        revenue = wsRealization.Cells(i, 8).Value
        commission = wsRealization.Cells(i, 10).Value
        logistics = wsRealization.Cells(i, 12).Value
        
        ' Поиск себестоимости в файле Юнит
        For j = 2 To lastRowUnit
            If wsUnit.Cells(j, 1).Value = articleWB Then
                costPrice = wsUnit.Cells(j, 7).Value * wsRealization.Cells(i, 9).Value
                Exit For
            End If
        Next j
        
        ' Суммирование общих значений
        totalRevenue = totalRevenue + revenue
        totalCosts = totalCosts + commission + logistics + costPrice
        totalMargin = totalMargin + (revenue - (commission + logistics + costPrice))
        
        ' Заполнение столбца себестоимости в плане поставок
        For j = 2 To lastRowPlan
            If wsPlan.Cells(j, 1).Value = articleWB Then
                ' Проверяем, что значение в ячейке не равно 0 и не пустое
                If IsNumeric(wsRealization.Cells(i, 9).Value) And wsRealization.Cells(i, 9).Value <> 0 Then
                    wsPlan.Cells(j, 5).Value = costPrice / wsRealization.Cells(i, 9).Value
                Else
                    wsPlan.Cells(j, 5).Value = 0
                End If
                
                wsPlan.Cells(j, 6).Value = wsPlan.Cells(j, 4).Value * wsPlan.Cells(j, 5).Value
                
                ' Запись данных в новый лист
                wsCHFR.Cells(outputRow, 1).Value = articleWB
                wsCHFR.Cells(outputRow, 2).Value = revenue - (commission + logistics + costPrice)
                wsCHFR.Cells(outputRow, 3).Value = wsPlan.Cells(j, 4).Value
                
                ' Проверяем, что revenue не равно 0
                If revenue <> 0 Then
                    ' Умножаем на 100 и форматируем как процент
                    wsCHFR.Cells(outputRow, 4).Value = Format((revenue - (commission + logistics + costPrice)) / revenue * 100, "0.00") & "%"
                Else
                    wsCHFR.Cells(outputRow, 4).Value = "0%"
                End If
                
                ' Получение данных через API Wildberries
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
    
    ' Вывод итоговых результатов в новый лист
    wsCHFR.Cells(outputRow, 1).Value = "Итого:"
    wsCHFR.Cells(outputRow, 2).Value = totalMargin
    wsCHFR.Cells(outputRow, 3).Value = "См. выше"
    
    ' Проверяем, что totalRevenue не равно 0
    If totalRevenue <> 0 Then
        ' Умножаем на 100 и форматируем как процент
        wsCHFR.Cells(outputRow, 4).Value = Format(totalMargin / totalRevenue * 100, "0.00") & "%"
    Else
        wsCHFR.Cells(outputRow, 4).Value = "0%"
    End If
    
    MsgBox "Обработка завершена!"
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
        MsgBox "Не удалось открыть файл: " & filePath
    End If
End Sub

Function GetWBAPI(ByVal apiUrl As String, ByVal article As String) As String
    Dim http As Object
    Dim apiKey As String
    Dim response As String
    
    ' Укажите ваш API-ключ Wildberries
    apiKey = "YOUR_API_KEY_HERE"
    
    ' Создаем объект для HTTP-запроса
    Set http = CreateObject("MSXML2.XMLHTTP")
    
    ' Формируем URL с параметрами
    Dim url As String
    url = apiUrl & "?dateFrom=2024-01-01&article=" & article
    
    ' Выполняем GET-запрос
    On Error Resume Next
    http.Open "GET", url, False
    http.setRequestHeader "Authorization", apiKey
    http.Send
    
    ' Получаем ответ
    If http.Status = 200 Then
        response = http.responseText
    Else
        response = "Ошибка: " & http.Status & " " & http.statusText
    End If
    
    On Error GoTo 0
    
    ' Возвращаем результат
    GetWBAPI = response
End Function
