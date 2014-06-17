$conemuSetup = "C:\Users\vagrant\ConEmuSetup.140602.exe"
$conemuArgs = '/p:x64 /quiet ADDLOCAL="FConEmuGui,FConEmuGui64,ProductFeature,FConEmuBase32,FConEmuBase,FConEmuBase64,FConEmuCmdExt,FConEmuDocs,FCEShortcutStart"'

Write-Host "Installing ConEmu"
Start-Process -FilePath $conemuSetup -ArgumentList $conemuArgs -NoNewWindow -Wait
Remove-Item -Force -Path $conemuSetup

Write-Host "Installing Sane Defaults for ConEmu"
$defaultsPath = "C:\Users\vagrant\ConEmu.reg"
Start-Process -FilePath "reg" -ArgumentList "import $defaultsPath" -NoNewWindow -Wait
Remove-Item -Force -Path $defaultsPath

Write-Host "Pinning ComEmu to the TaskBar"
$shell = new-object -com "Shell.Application"
$dir = $shell.Namespace("C:\Program Files\ConEmu")
$item = $dir.ParseName("ConEmu64.exe")
$item.InvokeVerb('taskbarpin')
