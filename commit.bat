@echo off

set day=%DATE:~0,2%
set month=%DATE:~3,2%
set year=%DATE:~6,4%

set hour=%TIME:~0,2%
set minute=%TIME:~3,2%
set second=%TIME:~6,2%

set datetime=%year%.%month%.%day%_%hour%.%minute%.%second%

del Common.csv
del Common.xml
.\tools\sqlite3.exe Common.db < .\tools\commands.txt
start /wait "" cmd /c cscript /nologo .\tools\converter.vbs
del Common.csv
git add .
git commit -a -m datetime