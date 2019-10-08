@echo off

del Common.csv
del Common.xml
.\tools\sqlite3.exe Common.db < .\tools\commands.txt
start /wait "" cmd /c cscript /nologo .\tools\converter.vbs
del Common.csv
git add .
git commit -a -m "changes"