if (-Not (Get-InstalledModule | Where-Object { $_.Name -eq "PSWindowsupdate" })) {
    if (-Not (Get-PackageProvider | Where-Object { $_.Name -eq "NuGet" })) {
        Install-PackageProvider -Confirm:$false -Force NuGet
    }
    Install-Module -Force -Confirm:$false PSWindowsUpdate
}
Get-WindowsUpdate -AcceptAll -Install -IgnoreReboot
