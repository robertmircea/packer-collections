if not exist "C:\Windows\Temp\Notepad2_4.2.25_x64.exe" (
    powershell -Command "(New-Object System.Net.WebClient).DownloadFile('http://www.flos-freeware.ch/zip/Notepad2_4.2.25_x64.exe', 'C:\Windows\Temp\Notepad2_4.2.25_x64.exe')" <NUL
)
start /wait %SYSTEMROOT%\Temp\Notepad2_4.2.25_x64.exe /QUIET

copy /y %SYSTEMROOT%\Temp\Notepad2\Notepad2.ini c:\users\vagrant\appdata\Roaming\Notepad2.ini
regedit /S %SYSTEMROOT%\Temp\Notepad2\notepad2_explorer.reg