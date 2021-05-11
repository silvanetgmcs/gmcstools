
<#PSScriptInfo

.VERSION 1.0.0

.GUID 75cf047e-4ffa-4e63-924a-f114e7683d68

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
 "GMCS Workstation Weekly Tasks" 

#> 
Param()
if (-Not (Get-InstalledModule | Where-Object { $_.Name -eq "PSWindowsupdate" })) {
    if (-Not (Get-PackageProvider | Where-Object { $_.Name -eq "NuGet" })) {
        Install-PackageProvider -Confirm:$false -Force NuGet
    }
    Install-Module -Force -Confirm:$false PSWindowsUpdate
}
Get-WindowsUpdate -AcceptAll -Install -IgnoreReboot

