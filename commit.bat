@echo off

break > Common.csv
break > Common.xml
.\tools\sqlite3.exe Common.db < .\tools\commands.txt
cscript /nologo .\tools\converter.vbs
break > Common.csv
git add .
git commit -a -m "changes"