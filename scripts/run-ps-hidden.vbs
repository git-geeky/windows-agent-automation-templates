Option Explicit

If WScript.Arguments.Count = 0 Then
  WScript.Echo "usage: cscript //nologo run-ps-hidden.vbs <script.ps1> [args...]"
  WScript.Quit 64
End If

Dim shell
Set shell = CreateObject("WScript.Shell")

Dim command
command = "powershell.exe -NoProfile -ExecutionPolicy Bypass -File " & Quote(WScript.Arguments(0))

Dim i
For i = 1 To WScript.Arguments.Count - 1
  command = command & " " & Quote(WScript.Arguments(i))
Next

shell.Run command, 0, False

Function Quote(value)
  Quote = Chr(34) & Replace(CStr(value), Chr(34), Chr(34) & Chr(34)) & Chr(34)
End Function
