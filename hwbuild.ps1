$mountdir="T:\wimmount"
$TemplateDate=""
$Version="20H2"
$DriversPath="c:\builddrivers"
$TemplatePath="T:\wimwitch\CompletedWIMs"
$TempDir="T:\temp-wims"
$ImageDir="\\clonezilla\clonezilla\newimages"

$destimages="$ImageDir\$TemplateDate"
if (-not (test-path $destimages) ) {
	new-item -path $destimages -ItemType "directory"
}

$Makes=get-childitem -Path $DriversPath
foreach ($make in $makes) {
     $makeName=$make.Name.Replace('^','')
    

     write-output $makeName
     write-output  $make.pspath
     $models=Get-childitem  $make.PSpath

     
     foreach ($model in $models) {
       $ModelFileName="$($makeName)-$($model.name).wim"
        if (-not (test-path -path "$($destimages)\$($ModelFileName)")) {
              Write-Host  "$destimages\$ModelFileName does not exists. creating"
            & robocopy  "$TemplatePath\"  "$TempDir\" "Win-10-Edu-$($Version).wim"
            dism /scratchdir:c:\scratch /mount-wim /wimfile:"$TempDir\Win-10-Edu-$($Version).wim" /mountdir:$mountdir /Index:1
            dism /Image:$mountdir /add-driver /driver:"$($model.fullname)" /Recurse
            #new-item -itemtype directory -path c:\wim\installs
            #robocopy /MIR \\i\win10\64\installs e:\wim\installs
            #$env:cygwin='nontsec'
            #rsync -rtv rsync://i/win10/64/installs/ /cygdrive/e/wim/installs/
            #if (-not (test-path e:\wim\programdata\chocolatey\lib\gmcs-rsync\cwRsync_5.5.0_x86_Free\etc\fstab)) {
            #  new-item -itemtype directory -path e:\wim\programdata\chocolatey\lib\gmcs-rsync\cwRsync_5.5.0_x86_Free\etc -ErrorAction SilentlyContinue
            #  Copy-Item C:\programdata\chocolatey\lib\rsync\cwRsync_5.5.0_x86_Free\etc\fstab   e:\wim\programdata\chocolatey\lib\gmcs-rsync\cwRsync_5.5.0_x86_Free\etc
            #}
            dism /unmount-wim /mountdir:$mountdir /commit
            #Remove-Item -path "$($ImageDir)\$($makeName)-$($model.name)-$($version)_*.wim"
            & robocopy "$TempDir\" "$destimages\"  "Win-10-Edu-$($Version).wim" /MOVE 
			#move-item -path   "$TempDir\Template-$($Version)_$TemplateDate.wim" -destination "$destimages\$ModelFileName"
			rename-item "$destimages\Win-10-Edu-$($Version).wim" -newname $ModelFileName

        } else {
            Write-Host  "$destimages\$ModelFileName exists"

         }

     }


}