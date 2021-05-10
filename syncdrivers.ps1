$srcdir="C:\builddrivers\"
$dstdir="\\nocvmdt01\e$\drivers\"
$Makes=get-childitem -Path $srcdir
foreach ($make in $makes) {
    $models=Get-childitem  $make.PSpath
    foreach ($model in $models) {
        $model.FullName
        $fulldstdir=join-path  $dstdir (join-path $make.Name  $model.name) 
        $fulldstdir
        & robocopy "$($model.Fullname)" "$($fulldstdir)" /MIR
    }
}
