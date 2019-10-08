option explicit

Dim index

Dim fso, stdout, entries, fileCSV, fileXML
Set fso = CreateObject("Scripting.FileSystemObject")
Set stdout = fso.GetStandardStream(1)
Set index = CreateObject("Scripting.Dictionary")
Set entries = CreateObject("System.Collections.ArrayList")
Set fileCSV = fso.OpenTextFile("Common.csv", 1, True)
Set fileXML = fso.CreateTextFile("Common.xml", True)

Do While fileCSV.AtEndOfStream <> True
	Dim row
    row = fileCSV.ReadLine

	Dim rowEntry
	If IsEmpty(rowEntry) Then
		Set rowEntry = (New Entry)(row)
		If (rowEntry.hasFinished) Then
			Call entries.add(rowEntry)
			index.Add rowEntry.id, rowEntry
		End If
	ElseIf (rowEntry.hasFinished) Then
		Set rowEntry = (New Entry)(row)
		If (rowEntry.hasFinished) Then
			Call entries.add(rowEntry)
			index.Add rowEntry.id, rowEntry
		End If
	Else
		rowEntry.addRow row
		If (rowEntry.hasFinished) Then
			Call entries.add(rowEntry)
			index.Add rowEntry.id, rowEntry
		End If
	End If
Loop

Dim rootItems
Set rootItems = CreateObject("System.Collections.ArrayList")

Dim elm
For Each elm In index.Items
	If (elm.pid = 0) Then
		rootItems.add elm
	Else
		If index.exists (elm.pid) Then
			Dim pEntry
			Set pEntry = index.item(elm.pid)
			Call pEntry.addChild(elm)
		End If
	End If
Next

fileXML.WriteLine "<?xml version=""1.0"" encoding=""UTF-8""?>"


Dim i
For i=0 to rootItems.Count-1
	Dim rootItem
	Set rootItem = rootItems.Item(i)
	stdout.WriteLine rootItem.name + ": " + Cstr(rootItem.getChildrenCount())
	
	Call rootItem.serialize(fileXML, 0)
Next


fileCSV.Close
fileXML.Close

Class Entry
	Private m_tokensFinished
	
	Private m_id
	Private m_pid
	Private m_pos
	Private m_type
	Private m_name
	
	Private m_columnsValues
	Private m_rows
	Private m_children
	
	Private m_token
	
	Private Sub parseRow(m_row)
		Dim cursor, char
		For cursor=1 to Len(row)
			char = Mid(row, cursor, 1)
			If (char = """") Then
				m_tokensFinished = Not m_tokensFinished
			
			ElseIf (char = ",") Then
				If (m_tokensFinished) Then
					m_columnsValues.add m_token
					m_token = ""
				Else
					m_token = m_token + char
				End If
			Else
				m_token = m_token + char
			End If
		Next
		
		If (m_tokensFinished) Then
			m_columnsValues.add m_token
			m_token = ""
		Else
			m_token = m_token + Chr(10)
		End If
	End Sub
	
	Public default function init(row)
		m_tokensFinished = True
		Set m_columnsValues = CreateObject("System.Collections.ArrayList")
		Set m_rows = CreateObject("System.Collections.ArrayList")
		Set m_children = CreateObject("System.Collections.ArrayList")
		
		Call addRow(row)
		Set Init = Me
    End function
	
	Public Property Get hasFinished
        hasFinished = m_tokensFinished
    End Property
	
	Public Property Get id
        id = m_columnsValues.Item(0)
    End Property
	
	Public Property Get pid
        pid = m_columnsValues.Item(1)
    End Property
	
	Public Property Get pos
        pos = m_columnsValues.Item(2)
    End Property
	
	Public Property Get eType
        eType = m_columnsValues.Item(3)
    End Property
	
	Public Property Get name
        name = m_columnsValues.Item(4)
    End Property
	
	Public Property Get data
        data = m_columnsValues.Item(5)
    End Property
	
	Public function toString()
		toString = m_name
		stdout.WriteLine "Count: " + Cstr(m_columnsValues.Count)
		Dim i
		For i=0 to m_columnsValues.Count-1
			stdout.WriteLine m_columnsValues.Item(i)
		Next
	End Function
	
	Public Sub addRow(row)
		parseRow(row)
		m_rows.add row
	End Sub
	
	Public Sub addChild(child)
		Call m_children.add(child)
	End Sub
	
	Public function getChildrenCount()
		getChildrenCount = m_children.Count
	End Function
	
	Public Sub serialize(fileXML, level)
		fileXML.WriteLine String(level, " ") + "<entry name=""" + Me.name + """>"
		
		If (Me.eType = 2) Then
			fileXML.WriteLine String((level + 1), " ") + "<![CDATA[" + Me.data + "]]>"
		End If
		
		fileXML.WriteLine String((level + 1), " ") + "<children count=""" + Cstr(m_children.Count) + """>"
		Dim i
		For i=0 to m_children.Count-1
			Dim child
			Set child = m_children.Item(i)
			Call child.serialize(fileXML, (level + 2))
		Next
		fileXML.WriteLine String((level + 1), " ") + "</children>"
		
		fileXML.WriteLine String(level, " ") + "</entry>"
	End Sub
End Class
