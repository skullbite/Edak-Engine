#!bin/sh

declare -a dumbLibs=("flixel" "openfl" "flixel-addons" "flixel-ui" "yaml" "hxcodec")
if ! command -v haxe; then
    echo "No haxe? :("
    echo "https://haxe.org/download/version/4.3.0"
    exit 0
fi

echo "haxelib found, we gucci :D"

if ! command -v lime; then
    echo "No lime?? don't worry i'll install it lol"
    haxelib install lime
    haxelib run lime setup
else
    echo "Found lime"
fi

for lib in ${dumbLibs[@]}; do
    haxelib install $lib
done

for lib in "haxelib git SScript https://github.com/TheWorldMachinima/SScript", 
           "haxelib git discord_rpc https://github.com/Aidan63/linc_discord-rpc"; do
    eval "$lib"
done

echo "You're now all set up for using edak engine."