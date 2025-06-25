# install-apps.ps1
# Silently install Google Chrome and VS Code during image creation

Write-Output "Installing Google Chrome..."
$chromeInstaller = "$env:TEMP\ChromeInstaller.msi"
Invoke-WebRequest -Uri "https://dl.google.com/chrome/install/googlechromestandaloneenterprise64.msi" -OutFile $chromeInstaller -UseBasicParsing
Start-Process msiexec.exe -ArgumentList "/i `"$chromeInstaller`" /qn /norestart" -Wait
Remove-Item $chromeInstaller -Force
Write-Output "Chrome installed successfully."

Write-Output "Installing Visual Studio Code..."
$vscodeInstaller = "$env:TEMP\VSCodeSetup.exe"
Invoke-WebRequest -Uri "https://update.code.visualstudio.com/latest/win32-x64-user/stable" -OutFile $vscodeInstaller -UseBasicParsing
Start-Process -FilePath $vscodeInstaller -ArgumentList "/silent /mergetasks=!runcode" -Wait
Remove-Item $vscodeInstaller -Force
Write-Output "VS Code installed successfully."
