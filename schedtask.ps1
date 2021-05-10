#Version 1.0.1
$passwd = ConvertTo-SecureString -String 'Nr8JzTCXjKb4bf' -AsPlainText -Force    
$cred = New-Object Management.Automation.PSCredential ('device1', $passwd)   
if (-not (Test-Path HKLM:\SOFTWARE\GMCS)) {
  New-Item -Force -Path HKLM:\SOFTWARE\GMCS
}
if ($null -eq (Get-ItemProperty -Path HKLM:Software\GMCS -name "deviceID" -ErrorAction SilentlyContinue | out-null)) {
  $deviceObject = @{ }
  $deviceObject['model'] = [string](Get-WmiObject win32_computersystem).model
  $deviceObject['manufacturer'] = [string](Get-WmiObject win32_computersystem).manufacturer
  $deviceObject['serialNumber'] = [string](Get-WmiObject win32_bios).serialnumber
  $json = $deviceObject | ConvertTo-Json
  try {
    $res = Invoke-RestMethod -Uri "https://devicetools.gmcs.org/devices" -method post -body $json -Credential $cred -ContentType "application/json"  -ErrorAction SilentlyContinue 
    if ($null -ne $res._id -and $res._id -ne "") {
      new-ItemProperty -Path HKLM:Software\GMCS -name "deviceID" -PropertyType String -Force -Value $res._id
    }
    else {
      Break
    }
  }
  catch {
    Throw "Failed to get device ID"
  }
}
$ChocoInstall = Join-Path ([System.Environment]::GetFolderPath("CommonApplicationData")) "Chocolatey\bin\choco.exe"
if (!(Test-Path $ChocoInstall)) {
  try {
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    Invoke-Expression "cmd.exe /c $ChocoInstall source add -n=GMCS -s'http://choco.gmcs.k12.nm.us/chocolatey'" -ErrorAction Stop
  }
  catch {
    Throw "Failed to install Chocolatey"
  }
}
$chocApps = ([string](& $ChocoInstall list -lo -r)).Split(' ')
$installedPackages = @()
foreach ($chocApp in $chocApps) {
  ($chocoAppName, $chocoAppVersion) = $chocApp.Split('|')
  $installedPackages += (@{packageName = $chocoAppName; version = $chocoAppVersion })
}
$deviceID = Get-ItemProperty  -Path HKLM:Software\GMCS -name "deviceID"
$apps = Invoke-RestMethod -Uri "https://devicetools.gmcs.org/devices/$($deviceID.deviceID)/packages" -ContentType "application/json"   -Credential $cred  -ErrorAction SilentlyContinue 
foreach ($package in $apps.packageInstalls) {
  $pkgFound = $false
  foreach ($ipackage in $installedPackages) {
    if ($ipackage.packageName -like $package.packageName) {
      $pkgFound = $true
      if ([version]$ipackage.version -lt [version]$package.version) {
        try {
          & $ChocoInstall upgrade $package.packageName --yes --force --version $package.version $package.options
        }
        catch {
          Write-Host "An error occurred:"
          Write-Host $_
        }
      }
    }
  }
  if ($pkgFound -eq $false) {
    try {
      & $ChocoInstall install $package.packageName --yes --force --version $package.version $package.options
    }
    catch {
      Write-Host "An error occurred:"
      Write-Host $_
    }
  }
}
exit 0