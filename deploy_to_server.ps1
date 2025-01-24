# Configuration deployment.json must be in project root directory
# {
#    "godot_path": "C:\\Users\\wes\\Documents\\windev\\Godot_v4.3-stable_win64.exe",
#    "project_path": "C:\\Users\\wes\\Documents\\windev\\bigmode25\\project.godot",
#    "build_path": "C:\\Users\\wes\\Documents\\windev\\bigmode25\\build\\web"
# }

$config = Get-Content -Path "deployment.json" | ConvertFrom-Json
$GODOT_PATH = $config.godot_path
$PROJECT_PATH = $config.project_path
$BUILD_PATH = $config.build_path

$REMOTE_SERVER = "blog"  # key config must be setup in .ssh
# C:\Users\wes\.ssh/config
# Host blog
#     Hostname 45.33.123.239
#     User wes
#     IdentityFile ~/.ssh/KEYNAME

$REMOTE_PATH = "/home/wes/blog/gamejam"
$PROJECT_NAME = "bigmode25-dev-" + $env:USERNAME
$URL = "https://ogsyn.dev/gamejam/$PROJECT_NAME.html"

# Remove existing build directory if it exists
if (Test-Path $BUILD_PATH) {
   Write-Host "[*] Removing existing build directory..."
   Remove-Item -Path $BUILD_PATH -Recurse -Force
}

# Create fresh build directory
New-Item -ItemType Directory -Force -Path $BUILD_PATH

# Build the web export
Write-Host "[*] Building web export..."
$buildProcess = Start-Process -FilePath $GODOT_PATH -ArgumentList "--headless", "--export-release", "Web", "$BUILD_PATH\$PROJECT_NAME.html", $PROJECT_PATH -NoNewWindow -PassThru -Wait

if ($buildProcess.ExitCode -eq 0) {
   Write-Host "[*] Build successful, deploying to server..."
   
   # Convert Windows path to WSL path format
   $wslSource = $BUILD_PATH -replace "\\", "/"
   $wslSource = $wslSource -replace "C:", "/mnt/c"
   
   # Execute rsync command through WSL
   wsl rsync -avz --delete --include="${PROJECT_NAME}.*" --exclude="*" "${wslSource}/" "${REMOTE_SERVER}:${REMOTE_PATH}/"
   
   Write-Host
   Write-Host "[*] Deployment for '$PROJECT_NAME' complete!"
   Write-Host "[*] Available to play at '$URL'"
} else {
   Write-Host
   Write-Host "[!] Build failed with exit code: $($buildProcess.ExitCode)"
   exit 1
}