# Gamejam!

# Setting up deployment
- Install WSL (wsl --install, requires restart of PC)
- make deployment.json with updated paths in root project dir based on template below

{  
   "godot_path": "C:\\Users\\wes\\Documents\\windev\\Godot_v4.3-stable_win64.exe",  
   "project_path": "C:\\Users\\wes\\Documents\\windev\\bigmode25\\project.godot",  
   "build_path": "C:\\Users\\wes\\Documents\\windev\\bigmode25\\build\\web"  
}  

- Set up godot export in godot editor (download web export by project>export>manage export template>download and install)
- generate SSH public key in your WSL user .ssh (/home/YOURNAME/.ssh), send the .pub to be put on VPS
- create ssh config in the WSL .ssh folder, update IP and KEYNAME to match your private key name in .ssh (don't change User, that is VPS username)

/home/USER/.ssh/config  

Host blog  
    Hostname ENTER_IP  
    User wes  
    IdentityFile ~/.ssh/KEYNAME  

- run deploy_to_server.ps1 script, it should build and rsync the build to the server with the given name.