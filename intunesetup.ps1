##Version 2.0.3
$passwd = ConvertTo-SecureString -String 'Nr8JzTCXjKb4bf' -AsPlainText -Force    
$cred = New-Object Management.Automation.PSCredential ('device1', $passwd)  
if (!(Test-Path HKLM:\SOFTWARE\GMCS)) {
  New-Item -Force -Path HKLM:\SOFTWARE\GMCS
}
$gmcskey = get-item HKLM:\SOFTWARE\GMCS\ 
$deviceID = ""
if ($null -eq $gmcskey.GetValue("deviceID")) {
  $deviceObject = @{ }
  $deviceObject['model'] = [string](Get-WmiObject win32_computersystem).model
  $deviceObject['manufacturer'] = [string](Get-WmiObject win32_computersystem).manufacturer
  $deviceObject['serialNumber'] = [string](Get-WmiObject win32_bios).serialnumber
  $json = $deviceObject | ConvertTo-Json
  try {
    $res = Invoke-RestMethod -Uri "https://devicetools.gmcs.org/devices" -method post -body $json -Credential $cred -ContentType "application/json"
    new-ItemProperty -Path $gmcskey.PSPath -name "deviceID" -PropertyType String -Force -Value $res._id
    $deviceID = $res._id

  }
  catch {
    break
  }
}
else {
  $deviceID = $gmcskey.GetValue("deviceID")
}
    
try {
  $device = Invoke-RestMethod -Uri "https://devicetools.gmcs.org/devices/$deviceID" -method get  -ContentType "application/json"   -Credential $cred 
  if ($device.assetTag -ne "") {
    $suffix = $device.assetTag
  }
  else {
    $suffix = $device.serialNumber
  }
  $prefix = "GMCS"
  if ($device.siteID -ne "") {
    try {
      $site = Invoke-RestMethod -Uri "https://devicetools.gmcs.org/sites?siteID=$($device.siteID)" -ContentType "application/json"   -Credential $cred  -ErrorAction SilentlyContinue 
      $prefix = $site.siteAcronym
      if ($null -ne $gmcskey.GetValue("Site")) {
        if ( $gmcskey.GetValue("Site") -ne $site.siteAcronym) { 
          set-ItemProperty -Path $gmcskey.PSPath  -name "Site"  -Value $site.siteAcronym
        }
      }
      else { 
        new-ItemProperty $gmcskey.PSPath  -name "Site" -PropertyType String -Force -Value $site.siteAcronym
      }
    }
    catch {}
  }
  $newcomputername = "$($prefix)-$($suffix)"
  if ([string](Get-WmiObject win32_computersystem).name -ne $newcomputername) {
    Rename-Computer -NewName $newcomputername -Force
  }
  if ($device.role -ne "") {
    if ($null -ne $gmcskey.GetValue("Role")) {
      if ( $gmcskey.GetValue("Role") -ne $device.role) { 
        set-ItemProperty -Path $gmcskey.PSPath  -name "Role" -Value $device.role
      }
    }
    else {
      new-ItemProperty -Path $gmcskey.PSPath  -name "Role" -PropertyType String -Force -Value $device.role
    } 
  }
}
catch {}
  
try { 
  $key = (Get-WmiObject -query 'select * from SoftwareLicensingService').OA3xOriginalProductKey
  & cscript //NoLogo  $Env:WinDir\system32\slmgr.vbs /ipk $key
  & cscript //NoLogo  $Env:WinDir\system32\slmgr.vbs /ato
  $WindowsEdition = get-windowsedition -online
  $license = (Get-CimInstance -ClassName SoftwareLicensingProduct | where-object PartialProductKey).LicenseStatus

  if ($WindowsEdition.Edition -ne "Education" -or $license -ne 1) {
    & cscript //nologo $Env:WinDir\system32\slmgr.vbs /ipk NW6C2-QMPVW-D7KKK-3GKT6-VCFB2
    & cscript //nologo $Env:WinDir\system32\slmgr.vbs /skms gmcs-kms.gmcs.org
    & cscript //nologo $Env:WinDir\system32\slmgr.vbs /ato
  }
  
}
catch {}

try {

  $enccmd = "JABwAGEAcwBzAHcAZAAgAD0AIABDAG8AbgB2AGUAcgB0AFQAbwAtAFMAZQBjAHUAcgBlAFMAdAByAGkAbgBnACAALQBTAHQAcgBpAG4AZwAgACcATgByADgASgB6AFQAQwBYAGoASwBiADQAYgBmACcAIAAtAEEAcwBQAGwAYQBpAG4AVABlAHgAdAAgAC0ARgBvAHIAYwBlACAAIAAgACAADQAKACQAYwByAGUAZAAgAD0AIABOAGUAdwAtAE8AYgBqAGUAYwB0ACAATQBhAG4AYQBnAGUAbQBlAG4AdAAuAEEAdQB0AG8AbQBhAHQAaQBvAG4ALgBQAFMAQwByAGUAZABlAG4AdABpAGEAbAAgACgAJwBkAGUAdgBpAGMAZQAxACcALAAgACQAcABhAHMAcwB3AGQAKQAgACAAIAANAAoAdAByAHkAIAB7ACAADQAKACAAIAAgACAAJAByAGUAcwAgAD0AIABJAG4AdgBvAGsAZQAtAFIAZQBzAHQATQBlAHQAaABvAGQAIAAtAFUAcgBpACAAIgBoAHQAdABwAHMAOgAvAC8AZABlAHYAaQBjAGUAdABvAG8AbABzAC4AZwBtAGMAcwAuAG8AcgBnAC8AcwBjAHIAaQBwAHQAcwA/AG4AYQBtAGUAPQBzAGMAaABlAGQAdABhAHMAawAuAHAAcwBlADEAJgB2AGUAcgBzAGkAbwBuAD0AMQAuADAALgAwACIAIAAtAEMAcgBlAGQAZQBuAHQAaQBhAGwAIAAkAGMAcgBlAGQADQAKACAAIAAgACAAaQBmACAAKAAkAHIAZQBzAC4AYwBvAHUAbgB0ACAALQBlAHEAIAAxACkAIAB7AA0ACgAgACAAIAAgACAAIAAgACAAJgAgACQAZQBuAHYAOgBTAHkAcwB0AGUAbQBSAG8AbwB0AFwAUwB5AHMAdABlAG0AMwAyAFwAVwBpAG4AZABvAHcAcwBQAG8AdwBlAHIAUwBoAGUAbABsAFwAdgAxAC4AMABcAFAAbwB3AGUAcgBzAGgAZQBsAGwALgBlAHgAZQAgAC0AbgBvAGwAbwBnAG8AIAAtAG4AbwBuAGkAbgB0AGUAcgBhAGMAdABpAHYAZQAgAC0ATgBvAFAAcgBvAGYAaQBsAGUAIAAtAFcAaQBuAGQAbwB3AFMAdAB5AGwAZQAgAEgAaQBkAGQAZQBuACAALQBlAHgAZQBjAHUAdABpAG8AbgBwAG8AbABpAGMAeQAgAGIAeQBwAGEAcwBzACAALQBFAG4AYwBvAGQAZQBkAEMAbwBtAG0AYQBuAGQAIAAkAHIAZQBzAFsAMABdAC4AcwBjAHIAaQBwAHQADQAKACAAIAAgACAAfQANAAoAIAAgACAAIABlAGwAcwBlACAAewANAAoAIAAgACAAIAAgACAAIAAgAHcAcgBpAHQAZQAtAGgAbwBzAHQAIAAiAHMAYwByAGkAcAB0ACAAbgBvAHQAIABmAG8AdQBuAGQAIgANAAoAIAAgACAAIAB9AA0ACgB9AA0ACgBjAGEAdABjAGgAIAB7AA0ACgAgACAAIAAgAFcAcgBpAHQAZQAtAEgAbwBzAHQAIAAiAGUAcgByAG8AcgAiAA0ACgB9AA=="
  get-scheduledtask -taskpath "\GMCS\*" | where-object { $_.taskname -like "GMCS Device Update*" } | unregister-scheduledtask -confirm:$false
  $taskname = "GMCS Device Update"
  $taskdescription = "Check for Application and Device Updates"
  $action = New-ScheduledTaskAction -Execute "$env:SystemRoot\System32\WindowsPowerShell\v1.0\Powershell.exe" -Argument "-nologo -noninteractive -NoProfile -WindowStyle Hidden -executionpolicy bypass -EncodedCommand $enccmd" 
  $triggers = @()
  $triggers += New-ScheduledTaskTrigger -AtStartup -RandomDelay (New-TimeSpan -minutes 5)
  $triggers += New-ScheduledTaskTrigger -Daily  -At 6:00 -RandomDelay (New-TimeSpan -minutes 120)
  $triggers += New-ScheduledTaskTrigger -Daily  -At 16:00 -RandomDelay (New-TimeSpan -minutes 120)
  $settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit (New-TimeSpan -Minutes 30) -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1) -AllowStartIfOnBatteries -Compatibility Win8 -RunOnlyIfNetworkAvailable -StartWhenAvailable -Hidden:$false
  Register-ScheduledTask -Action $action -Trigger $triggers -TaskName $taskname -Description $taskdescription -Settings $settings -User "System" -taskpath "GMCS"  -RunLevel Highest -Force 
  Start-ScheduledTask -TaskPath "GMCS" -TaskName "GMCS Device Update"
}
catch {}



