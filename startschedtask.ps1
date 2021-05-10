$passwd = ConvertTo-SecureString -String 'Nr8JzTCXjKb4bf' -AsPlainText -Force    
$cred = New-Object Management.Automation.PSCredential ('device1', $passwd)   
try { 
    $res = Invoke-RestMethod -Uri "https://devicetools.gmcs.org/scripts?name=schedtask.pse1&version=1.0.0" -Credential $cred
    if ($res.count -eq 1) {
        & $env:SystemRoot\System32\WindowsPowerShell\v1.0\Powershell.exe -nologo -noninteractive -NoProfile -WindowStyle Hidden -executionpolicy bypass -EncodedCommand $res[0].script
    }
    else {
        write-host "script not found"
    }
}
catch {
    Write-Host "error"
}