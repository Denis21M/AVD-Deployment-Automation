# install-apps.ps1
# Script to install Google Chrome and Visual Studio Code silently on Windows

# --------------------
# Install Google Chrome
# --------------------
Write-Output "Downloading and installing Google Chrome..."
$chromeInstaller = "$env:TEMP\ChromeSetup.exe"
Invoke-WebRequest -Uri "https://dl.google.com/chrome/install/375.126/chrome_installer.exe" -OutFile $chromeInstaller -UseBasicParsing
Start-Process -FilePath $chromeInstaller -ArgumentList "/silent /install" -Wait
Remove-Item $chromeInstaller -Force
Write-Output "Google Chrome installation completed."

# --------------------
# Install Visual Studio Code
# --------------------
Write-Output "Downloading and installing Visual Studio Code..."
$vscodeInstaller = "$env:TEMP\VSCodeSetup.exe"
Invoke-WebRequest -Uri "https://update.code.visualstudio.com/latest/win32-x64-user/stable" -OutFile $vscodeInstaller -UseBasicParsing
Start-Process -FilePath $vscodeInstaller -ArgumentList "/silent /mergetasks=!runcode" -Wait
Remove-Item $vscodeInstaller -Force
Write-Output "Visual Studio Code installation completed."
