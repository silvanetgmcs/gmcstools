$key=(Get-WmiObject -query 'select * from SoftwareLicensingService').OA3xOriginalProductKey
& cscript //NoLogo  $Env:WinDir\system32\slmgr.vbs /ipk $key
& cscript //NoLogo  $Env:WinDir\system32\slmgr.vbs /ato
& cscript //NoLogo  $Env:WinDir\system32\slmgr.vbs /dlv