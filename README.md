# Prism One: Trench Run
## Links
https://itch.io/jam/bigmode-game-jam-2025/rate/3297954#post-11967138
https://flook.itch.io/prism-one-trench-run
https://www.youtube.com/watch?v=HswYfvhhwn4 

## Description
Balance your ship's power between guns and thrusters as you dodge missiles and blow up power crystals along the enemy trench.

You are Prism One, a retired military pilot turned civilian racer. You've been recalled for one last mission, that only you can pull off.

Equipped with a pair of rocket pods strapped to your trusty race ship, you're on an impossible mission to infiltrate a hardened enemy base. Slipping through the narrow mining system and lightly defended trench to reach the main objective.

Good luck, Prism One. You'll need it.

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
