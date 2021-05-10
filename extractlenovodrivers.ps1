$rootpath = "c:\lenovo"
$packagepathroot = "c:\builddrivers\LENOVO"
$databasefile = $rootpath + "\database.xml"
#$systemnum="20NF"
$systemnums = @("20N4", "20D9", "20GA", "20H8", "20H9", "20NF", "81FY", "3372", "20GB", "20KV", "20NJ", "81M9", "20NF", "20HU", "20KT", "20DF", "6885", "11A9", "20NE", "20C6", "20UD", "20S6", "82GK", "20UE", "20RA", "10RS", "81WB")
#$systemnums = @("81WB")

[xml]$xmlfile = Get-Content $databasefile
foreach ($systemnum in $systemnums) {
	$packpath = $packagepathroot + "\" + $systemnum
	IF (!(Test-Path $packpath) -eq $true) {

		Write-Host "$packpath folder was not found Creating Test Folder..." -ForegroundColor Cyan
		New-Item -Path $packpath -ItemType Directory | Out-Null
	}
	Remove-Item "$packpath" -force -Recurse
	[System.Collections.ArrayList]$targetpackages = @()
	#@packages=@()
	foreach ($package in $xmlfile.Database.Package) {
		if ( $package.SystemCompatibility.System | Where-Object { $_.mtm -eq $systemnum -and $_.os -eq "Windows 10" } ) {
			$replaced = $false	
			for ($i = 0 ; $i -lt $targetpackages.count; $i++ ) {
				if ($package.name -eq $targetpackages[$i].name -and $package.Version -gt $targetpackages[$i].Version ) {
					$targetpackages[$i] = $package
					$replaced = $true
					write-host "Found Update Package"
					break
				}
			}
	
			if (!$replaced) {
				$targetpackages.Add($package) | Out-Null

			}
		}
	}

	foreach ($package in $targetpackages) {
			
		write-host $package.id
		$packagexmlpath = $rootpath + [string]$package.LocalPath
		#write-host $packagexmlpath
		[xml]$packagexml = Get-Content $packagexmlpath
		#write-host $packagexml.Package.id
		$extractcmd = [string]$packagexml.Package.ExtractCommand
		#write-host $extractcmd
		if ($extractcmd -match '(^\S*)\s(.*)') {
			$extractexe = $Matches[1]
			$extractargs = $Matches[2]
			$srcexe = $rootpath + "\" + $package.id + "\" + $extractexe
			Copy-Item -Path $srcexe -Destination $env:TMP
			$replace = '"' + $packpath + "\" + [string]$packagexml.Package.Title.Desc.'#text' + " (" + $package.id + ')"'
			$extractargs = $extractargs -replace "%PACKAGEPATH%", $replace
		  
			#Start-Process -FilePath $fullcmd -Wait
			$tmpexe = $env:tmp + "\" + $extractexe
			#Write-host $tmpexe
			#Write-Host $extractargs
			Start-Process -FilePath $tmpexe -WorkingDirectory $packagepathroot -ArgumentList $extractargs -Wait
			Remove-Item -Path $tmpexe
		}
		
	}
}