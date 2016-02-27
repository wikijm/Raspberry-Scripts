#!/bin/bash
#======================================================================================================================================
#          FILE:  bootstrap-install.sh
# 
#         USAGE:  cd /home/pi && chmod +x ./bootstrap-install.sh && ./bootstrap-install.sh
# 
#   DESCRIPTION:  Prepare Raspbian after fresh new deployment 
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  * Connect Raspberry with:
#											- MicroSD card containing last Raspbian OS		
#											- Network cable
#											- (Optional) Wifi dongle
#											- Power supply
#
#                 * On Desktop, launch Menu > Raspberry Pi Configuration, then:
#					   						- Click "Expand Filesystem"
#					   					 	- Modify "Hostname" value
#					   						- Select "To CLI" for "Boot" option
#					   						- Modify "Hostname" value
#					  						- Uncheck "Auto Login option"
#					  						- Modify options on "Localisation" tab
#					  						- Apply modifications by clicking on "OK" then "YES"
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Jean-Marc ALBERT
#       COMPANY:  ---
#       CREATED: 18.02.2016 19:17:34 UST
#      REVISION:  0.0.1
#======================================================================================================================================


### Variables ###
NOW=$(date +%y.%m.%d-%T)
scriptfile="$(readlink -f $0)"
CURRENT_DIR="$(dirname ${scriptfile})"


### Functions ###
	shw_grey () {
    echo $(tput bold)$(tput setaf 0) $@ $(tput sgr 0)
}
	shw_norm () {
    echo $(tput bold)$(tput setaf 9) $@ $(tput sgr 0)
}
	shw_info () {
    echo $(tput bold)$(tput setaf 4) $@ $(tput sgr 0)
}
	shw_warn () {
    echo $(tput bold)$(tput setaf 2) $@ $(tput sgr 0)
}
	shw_err ()  {
    echo $(tput bold)$(tput setaf 1) $@ $(tput sgr 0)
}


### Actions ###
shw_info "Active root shell prompt colorization"
echo "PS1='${debian_chroot:+($debian_chroot)}\[\033[01;31m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ ' " >> /root/.bashrc

shw_info "Stopping expensive services"
sudo update-rc.d mysql remove
sudo /etc/init.d/mysql stop
sudo update-rc.d tor remove
sudo /etc/init.d/tor stop
sudo /etc/init.d/postgresql stop
sudo update-rc.d postgresql remove

shw_info "Active apt for progressbar"
echo 'Dpkg::Progress-Fancy "1";' > /etc/apt/apt.conf.d/99progressbar

shw_info "Doing Debian Updates (slow) ..."
sudo apt -y update
sudo apt -y install apt-transport-https
sudo apt -y upgrade
sudo apt -y dist-upgrade
sudo aptitude -y autoclean
sudo apt -y full-upgrade

shw_info "Installing Standard Tools"
sudo apt -y install htop git git-all

shw_info "Install raspberry-motd"
cd /etc/profile.d/
wget https://raw.githubusercontent.com/wikijm/raspberrypi-motd/master/motd.sh
chown pi:pi motd.sh
chmod +x motd.sh

shw_info "Installing rpi-update"
sudo apt -y install ca-certificates git-core
sudo wget https://raw.github.com/Hexxeh/rpi-update/master/rpi-update -O /usr/bin/rpi-update && sudo chmod +x /usr/bin/rpi-update

shw_info "Updating firmware"
sudo rpi-update

shw_warn "Rebooting Raspberry"
sudo reboot
