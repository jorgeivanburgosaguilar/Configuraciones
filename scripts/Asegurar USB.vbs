' Asegurar Medios Extraibles
' Ultima Modificacion: 24/02/2011
Option Explicit

Dim oShell, LetraUnidad, fSysObj, archivo, archivoW, carpeta
Set oShell = WScript.CreateObject("WScript.Shell")
Set fSysObj = WScript.CreateObject("Scripting.FileSystemObject")

LetraUnidad = PedirLetraUnidad()
If LetraUnidad = "" Then
  WScript.Echo "La letra seleccionada es incorrecta"
Else
  fSysObj.CreateFolder( LetraUnidad & ":\autorun.inf" )
  Set archivoW = fSysObj.CreateTextFile( "\\.\" & LetraUnidad & ":\autorun.inf\lpt1", True )
  Set archivo = fSysObj.GetFile( "\\.\" & LetraUnidad & ":\autorun.inf\lpt1" )
  archivoW.Close
  archivo.attributes = 7
  Set archivoW = fSysObj.CreateTextFile( "\\.\" & LetraUnidad & ":\autorun.inf\com1", True )
  Set archivo = fSysObj.GetFile( "\\.\" & LetraUnidad & ":\autorun.inf\com1" )
  archivoW.Close
  archivo.attributes = 7
  Set carpeta = fSysObj.GetFolder( LetraUnidad & ":\autorun.inf" )
  carpeta.attributes = 7
  WScript.Echo "Unidad " & LetraUnidad & " Asegurada"
End If

function PedirLetraUnidad()
  Dim LetraUnidad

  LetraUnidad = InputBox("Indique la letra de la unidad:")

  If Len(LetraUnidad) > 1 Then
    LetraUnidad = Left( LetraUnidad, 1 )
  End If

  If LetraUnidad = "" Then
    PedirLetraUnidad = ""
  Else
    PedirLetraUnidad = LetraUnidad
  End If
End Function