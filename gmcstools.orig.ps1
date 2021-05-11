param (
    [Parameter(Mandatory = $true)][string]$command,
    [string]$options
)

$version = "4.0.0"


switch ($command.ToLower()) {
    "online-script" {
        $passwd = ConvertTo-SecureString -String 'Nr8JzTCXjKb4bf' -AsPlainText -Force    
        $cred = New-Object Management.Automation.PSCredential ('device1', $passwd)   
        try { 
            $res = Invoke-RestMethod -Uri "https://devicetools.gmcs.org/scripts?name=$options.pse1" -Credential $cred
            if ($res.count -eq 1) {
                & $env:SystemRoot\System32\WindowsPowerShell\v1.0\Powershell.exe -nologo -executionpolicy bypass -EncodedCommand $res[0].script
            }
            else {
                write-host "Script Not Found"
            }
        }
        catch {
            Write-Host "Connection Error"
        }
    } 
    "uptime" {
        $uptime = (get-date) - (gcim Win32_OperatingSystem).LastBootUpTime
        Write-Host $uptime.Days "Days," $uptime.Hours "Hours," $uptime.Minutes "Minutes," $uptime.Seconds "Seconds"
    }
    "version" {
        write-host $version
    }
    default { "Unknown Command" }
}
