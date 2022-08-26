# Matomo Server Backup Script

Matomo is the leading Free/Libre open analytics platform.

Matomo is a full-featured PHP MySQL software program that you download and install on your own webserver. At the end of the five-minute installation process, you will be given a JavaScript code. Simply copy and paste this tag on websites you wish to track and access your analytics reports in real-time.

Matomo aims to be a Free software alternative to Google Analytics and is already used on more than 1,400,000 websites. Privacy is built-in!

Matomo:

- [Matomo (Matomo)](https://matomo.org/)

Matomo Github;

- [Matomo Github (Matomo Github)](https://github.com/matomo-org/matomo)

# This is a Linux Backup Script to Back up the Matomo Root Folder and Databases
# It supports both Local and Remote Backups as well as backup Rotation
# Please note that this is still a beta script
# Any pull requests and suggestion welcome!
# Author: Dieskim

## Installation

1. Log in to you server via SSH as root

2. Create a folder where you would like to place the script and move into the folder

``mkdir matomo-backup-script``

``cd matomo-backup-script``

3. wget the backup script

``wget https://raw.githubusercontent.com/dieskim/matomo-backup-script/main/matomo-backup.sh``

4. Set the script to be executable

``chmod a+x matomo-backup.sh``

5. For remote backups set up [Linux SSH KEY Password Free Automatic Config Authentication](http:/dieskim.me/2015/05/13/how-to-linux-ssh-key-password-free-automatic-config-authentication-backup-sftp-scp/)

6. Edit all the setting in the top of the script.

7. Test the script via
``sh -x matomo-backup.sh 2>&1 | tee debug.txt``

7. Add Script to Crontab to run daily

``crontab -e``

- Choose your editor and add the below to the crontab to run script every night at midnight - save file
	
``00 00 * * * /path/to/matomo-backup-script/matomo-backup.sh``

## Author

Author: Dieskim

## License
MIT
