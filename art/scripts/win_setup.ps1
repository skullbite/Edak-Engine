try {
    if (Get-Command "haxelib" -ErrorAction Stop) {
        # $haxeVer = &haxe --version
        # todo: learn how to version check
        Write-Host "Found haxelib, we gucci :D" -ForegroundColor Green
        # lime setup if needed
        try {
            if (Get-Command "lime" -ErrorAction Stop) { Write-Host "Found lime" -ForegroundColor Green }
        }
        catch {
            Write-Host "No lime?? don't worry i'll install it lol" -ForegroundColor Yellow
            &haxelib install lime
            &haxelib run lime setup
        }

        Write-Host "Installing the libraries..." -ForegroundColor Yellow
        $dumbLibs = @("flixel", "openfl", "flixel-addons", "flixel-ui", "yaml", "hxcodec")
        $gitLibs = @("haxelib git SScript https://github.com/TheWorldMachinima/SScript")
        foreach ($i in $dumbLibs) {
            &haxelib install $i
        }
        foreach ($i in $gitLibs) {
            Invoke-Expression $i
        } Write-Host "You're now all set up for using edak engine."

        -ForegroundColor Green
    }
}
catch { 
    Write-Host "No haxe? :(" -ForegroundColor Red
    Write-Host "https://haxe.org/download/" -ForegroundColor Blue

}