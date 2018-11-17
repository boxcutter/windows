' see http://stackoverflow.com/a/911796/1432614
' http://stackoverflow.com/a/12718299/1432614

'If the extraction location does not exist create it.
Set fso = CreateObject("Scripting.FileSystemObject")

'The location of the zip file.
ZipFile=fso.GetAbsolutePathName(Wscript.Arguments(0))
'The folder the contents should be extracted to.
ExtractTo=fso.GetAbsolutePathName(Wscript.Arguments(1))

If NOT fso.FolderExists(ExtractTo) Then
   fso.CreateFolder(ExtractTo)
End If

'Extract the contents of the zip file.
set objShell = CreateObject("Shell.Application")
set FilesInZip=objShell.NameSpace(ZipFile).items
objShell.NameSpace(ExtractTo).CopyHere(FilesInZip)
Set fso = Nothing
Set objShell = Nothing
