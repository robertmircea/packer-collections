if not exist "C:\Windows\Temp\GoogleChromeStandaloneEnterprise.msi" (
    powershell -Command "(New-Object System.Net.WebClient).DownloadFile('https://dl.google.com/edgedl/chrome/install/GoogleChromeStandaloneEnterprise.msi', 'C:\Windows\Temp\GoogleChromeStandaloneEnterprise.msi')" <NUL
)
start /wait msiexec /qb /i %SYSTEMROOT%\Temp\GoogleChromeStandaloneEnterprise.msi
copy /y %SYSTEMROOT%\Temp\master_preferences "C:\Program Files (x86)\Google\Chrome\Application\"