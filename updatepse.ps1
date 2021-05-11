
<#PSScriptInfo

.VERSION 1.0.0 )

.GUID 5ad977be-a0b7-4132-8322-bd3e42e9e6d3

.AUTHOR Lupe Silva

.COMPANYNAME

.COPYRIGHT

.TAGS

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES


.PRIVATEDATA

#>

<# 

.DESCRIPTION 
 Upload Scripts API server 

#> 
Param(
    [string]$Path
)
if ( (test-path $Path) ) {
    if (Get-Content -Path $Path |  Where-Object { $_ -match "\.VERSION (.*)" }) {
        $version=$Matches[1]
        $Code = Get-Content -Path $Path -Raw
        $Bytes = [System.Text.Encoding]::Unicode.GetBytes($Code) 
        $Base64 = [Convert]::ToBase64String($Bytes) 
  
        $NewPath = [System.IO.Path]::ChangeExtension($Path, '.pse1')
        $Base64 | Set-Content -Path $NewPath
        $NewFile=[System.IO.Path]::GetFileName($NewPath)
        $passwd = ConvertTo-SecureString -String 'Nr8JzTCXjKb4bf' -AsPlainText -Force    
        $cred = New-Object Management.Automation.PSCredential ('device1', $passwd)   
        $psescript=@{}
        $psescript["type"]="powershell"
        $psescript["name"]=$NewFile
        $psescript["version"]=$version
        $psescript["script"]=$Base64
        $json=$psescript | ConvertTo-Json
        Invoke-RestMethod -Uri "https://devicetools.gmcs.org/scripts" -method post -body $json -Credential $cred -ContentType "application/json"  

    }
    else {
        Write-Host "Version Not Found"
        
    }
}
else {
    Write-host "File not found"
}



