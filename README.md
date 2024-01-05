# game_rip
Backup image creation scripts for various game consoles

This script rips console game disks for use as backups or in emulators. Verifying the legality in your jurisdiction is your responsibility.

For simplified compatibility across distroes, the script uses a Docker container to perform the ripping. Docker and a CD (or DVD or Blu-Ray) drive are really the only prerequisites.

## Installation and Usage
Basic usage consists of cloning into this repo, moving into its folder, and running the script to automatically build the Docker image and begin ripping disks.
```
$ git clone https://github.com/NateTheGreat68/game_rip.git
$ cd game_rip
$ ./game_rip.sh psx:Spyro psx:Spyro2 psx:Spyro3 ps2:Spyro4
```

The arguments to the script are of the form "console:rom\_name". *console* determines how the disk will be ripped and processed, and *rom\_name* determines the output ROM filename.

The disk will be ejected after each rip and wait for you to load the next, allowing you to set up a queue to rip multiple games/disks back-to-back.

Currently supported consoles: psx and ps2. Images for both are automatically compressed to .chd format files.

If the base output path (GAME\_RIP\_ROM\_BASE\_PATH) has a matching subdirectory such as PSX, PS1, Playstation2, etc., the output ROM file will be automatically placed there as appropriate.

The ownership of the output ROM file will be matched to that of the directory it's in.

## Configuration and Defaults
**The script assumes your CD drive is /dev/sr0 and that the desired directory for finished ROM files is ~/Games/.** There are 3 ways to override one or both of these:
1. Edit the first few lines of game\_rip.sh. Note that these changes will be reverted if you perform a git pull to update your local copy of the script.
1. Run the script like `GAME_RIP_DRIVE=/dev/cd GAME_RIP_ROM_BASE_PATH=/mnt/games ./game_rip.sh ...`. Note that you'll have to specify these each time you run the script.
1. Export the GAME\_RIP\_DRIVE and GAME\_RIP\_ROM\_BASE\_PATH environment variables: `$ export GAME_RIP_DRIVE=/dev/cd` and/or `$ export GAME_RIP_ROM_BASE_PATH=/mnt/games`. Note that you'll have to export the variables each time you open a new terminal if you don't add them to your ~/.bashrc file or similar.
