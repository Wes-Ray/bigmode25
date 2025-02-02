
$ROOT_LINES = "."  # assume this is run from project root dir
$TARGET_ENEMY_LINES = "$ROOT_LINES\assets\voicelines\enemy\"
$TARGET_ALLY_LINES = "$ROOT_LINES\assets\voicelines\ally\"

Write-Host "Building voiceline dictionaries..."
Write-Host "Enemy Dir: $TARGET_ENEMY_LINES"
Write-Host "Ally Dir: $TARGET_ALLY_LINES"

function Format-VoicelineFiles {
    param (
        [string]$path,
        [string]$target
    )
    
    Get-ChildItem -Path $path -Filter "*.ogg" -File | ForEach-Object {
        $fileName = $_.BaseName
        "`"$fileName`": preload(`"res://assets/voicelines/$target/$($_.Name)`"),"
    }
}

# Get and format files from both directories
Write-Host "`nEnemy Voicelines:"
Format-VoicelineFiles -path $TARGET_ENEMY_LINES -target "enemy"

Write-Host "`nAlly Voicelines:"
Format-VoicelineFiles -path $TARGET_ALLY_LINES -target "ally"
