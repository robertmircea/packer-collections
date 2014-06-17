param (
  [switch]$Silent = $true
)


function Install-VisualStudio
{
    [CmdletBinding()]
    param (
        [string] $ImagePath,
        [string[]] $ArgumentList,
        [string] $InstallPath,
        [string] $ProductKey,
        [string] $AdminFile,
        [switch] $Silent = $true
    )
    Write-Verbose "Installing Visual Studio..."
    
    $filePath = Join-Path $ImagePath "vs_*.exe" -Resolve
    $argumentList = @("/NoRestart","/Log c:\VisualStudio_Install.log", "/Passive")
 
    if(![String]::IsNullOrEmpty($InstallPath))
    {
        $argumentList +="/CustomInstallPath ${InstallPath}"
    }
    if(![String]::IsNullOrEmpty($ProductKey))
    {
        $argumentList +="/ProductKey ${ProductKey}"
    }

    if(![String]::IsNullOrEmpty($AdminFile)){
        $argumentList += "/adminfile ${AdminFile}"
    } else {
        $argumentList += "/Full"
    }

    if($Silent){
        $argumentList += "/quiet"
    }
    
    Write-Progress -Activity "Installing Visual Studio" -Status "Install..."
    Start-Process -FilePath $filePath -ArgumentList $ArgumentList  -Wait 
    Write-Progress -Activity "Installing Visual Studio" -Completed
}
 
function Install-VisualStudioUpdate
{
    [CmdletBinding()]
    param (
        [string] $ImagePath
    )
    Write-Verbose "Install Visual Studio Update..."
    
    $filePath = Join-Path $ImagePath "VS2012.*.exe" -Resolve
 
    $argumentList = @("/Full","/Passive","/NoRestart","/NoWeb","/Log c:\VisualStudio_Update_Install.log")
 
    Write-Progress -Activity "Install Visual Studio 2012 Update" -Status "Install..."
    Start-Process -FilePath $filePath -ArgumentList $ArgumentList -Wait 
    Write-Progress -Activity "Install Visual Studio 2012 Update" -Completed
}



$destinationInstallPath = "c:\VisualStudio"
Write-Host "Destination install path for Visual Studio ${destinationInstallPath}"

Write-Host "Installing Visual Studio"
$isoPath = "C:\users\vagrant\en_visual_studio_ultimate_2013_with_update_2_x86_dvd_4238214.iso"
$rc = Mount-DiskImage -PassThru -ImagePath $isoPath
$driveLetter = ($rc | Get-Volume).DriveLetter
Install-VisualStudio -ImagePath "${driveLetter}:" -InstallPath $destinationInstallPath -AdminFile A:\AdminDeployment.xml -Silent $Silent

Dismount-DiskImage -ImagePath $isoPath
Remove-Item -Force -Path $isoPath
Remove-Item -Force -Path c:\VisualStudio_Install*.log



Write-Host "Installing Resharper"
$resharperInstallerPath = "C:\Users\vagrant\ReSharperSetup.8.2.0.2160.msi"
Start-Process -FilePath $resharperInstallerPath -ArgumentList "/qn" -Wait
Remove-Item -Force -Path $resharperInstallerPath


Write-Host "Installing the Hide Main Menu VSIX"
$vsixInstallerPath = "${destinationInstallPath}\Common7\IDE\VSIXInstaller.exe"
$extensionPath = "c:\users\vagrant\HideMenu.vsix"
Write-Host "VSIX installer path ${vsixInstallerPath}"
Start-Process -FilePath $vsixInstallerPath -ArgumentList "/q $extensionPath" -NoNewWindow -Wait
Remove-Item -Force -Path $extensionPath


Write-Host "Configuring Resharper to use the IntelliJ Keyboard Scheme"
$dotSettingsSource = "C:\Users\vagrant\vsActionManager.DotSettings"
$dotSettingsDestination = "C:\Users\vagrant\AppData\Local\JetBrains\ReSharper\vAny\vs12.0"
New-Item $dotSettingsDestination -Type directory
Move-Item -Force -Path $dotSettingsSource -Destination $dotSettingsDestination


Write-Host "Pinning Visual Studio to the TaskBar"
$shell = new-object -com "Shell.Application"
$dir = $shell.Namespace("${destinationInstallPath}\Common7\IDE")
$item = $dir.ParseName("devenv.exe")
$item.InvokeVerb('taskbarpin')


Write-Host "Importing some sensible defaults to Visual Studio and killing the first run wizard"
$settingsPath = "C:\Users\vagrant\insane.vssettings"
$devenvPath = "${destinationInstallPath}\Common7\IDE\devenv.exe"
$process = Start-Process -FilePath $devenvPath -ArgumentList "/ResetSettings $settingsPath /Command File.Exit" -NoNewWindow -PassThru
#If this doesn't complete in 1 minute, then seriously, WTF?
if ( ! $process.WaitForExit(60000) ) {
    $process.Kill()
}
Remove-Item -Force -Path $settingsPath


Write-Host "FIXING THE ALL CAPS MENU IN VISUAL STUDIO"
Set-ItemProperty -Path HKCU:\Software\Microsoft\VisualStudio\12.0\General -Name SuppressUppercaseConversion -Type DWord -Value 1


#Write-Host "Fixing the Visual Studio Start Screen"
New-ItemProperty -Force -Path HKCU:\Software\Microsoft\VisualStudio\12.0\General -Name OnEnvironmentStartup -Type DWord -Value 4
New-Item -Force -Path HKCU:\Software\Microsoft\VisualStudio\12.0\General\StartPage
New-ItemProperty -Force -Path HKCU:\Software\Microsoft\VisualStudio\12.0\General\StartPage -Name IsDownloadRefreshEnabled -Type DWord -Value 0
New-ItemProperty -Force -Path HKCU:\Software\Microsoft\VisualStudio\12.0\General\StartPage -Name OptIn -Type DWord -Value 0

#We register ReSharper in the box VagrantFile instead of here as it's
# a per user setting which comes from an environment variable.

