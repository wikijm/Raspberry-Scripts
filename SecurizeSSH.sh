#!/bin/bash
#=======================================================================
#
#          FILE:  SecurizeSSH.sh
# 
#         USAGE:  ./SecurizeSSH.sh 
# 
#   DESCRIPTION:  Modification needed 
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Jean-Marc ALBERT
#       COMPANY:  ---
#       CREATED: 31.08.2015 19:50:34 UST
#      REVISION:  0.0.3
#=======================================================================
### Variables ###
NOW=$(date +%y.%m.%d-%T)
scriptfile="$(readlink -f $0)"
CURRENT_DIR="$(dirname ${scriptfile})"

sshdConfigFile='/etc/ssh/sshd_config'
denyhostsConfigFile='/etc/denyhosts.conf'

PKGSTOINSTALL="denyhosts"

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
 
	check_process() {
	echo "Checking if process $1 exists..."
	[ "$1" = "" ]  && return 0
	PROCESS_NUM=$(ps -ef | grep "$1" | grep -v "grep" | wc -l)
	if [ $PROCESS_NUM -ge 1 ];
	then
	        return 1
	else
	        return 0
	fi
}
### Initialisation ###

# Must be root
if [[ $EUID -ne 0 ]]; then
        echo "This script must be run as root" #1>&2
        exit 0
fi


### Actions ###

# sshd configuration
shw_info "### Step 1 : Modify sshd 'PermitRootLogin' value and used port ###"
	if [ -f $sshdConfigFile ];
	then
		cp /etc/ssh/sshd_config /etc/ssh/sshd_config.$NOW
		shw_warn "File $sshdConfigFile exists. Modify 'PermitRootLogin' value from 'yes' to 'no' and 'Port' value from '22' to '2222'."
		sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' $sshdConfigFile
		sed -i 's/PermitRootLogin without-password/PermitRootLogin no/g' $sshdConfigFile
		sed -i 's/Port 22/Port 2222/g' $sshdConfigFile
		shw_warn "sshd restart in progress..."
		service ssh restart
	else
		shw_err "File $sshdConfigFile does not exists. No modification needed. Exit of the script."
	fi
	
shw_info "### Step 2 : Install & Configure DenyHosts ###"
	
	# If some dependencies are missing, asks if user wants to install
	if [ "$PKGSTOINSTALL" != "" ]; then
		echo -n "Some dependencies may missing. Would you like to install them? (Y/n): "
		read SURE
		# If user want to install missing dependencies
		if [[ $SURE = "Y" || $SURE = "y" || $SURE = "" ]]; then
			# Debian, Ubuntu and derivatives (with apt-get)
			if which apt-get &> /dev/null; then
				apt-get install $PKGSTOINSTALL
		# Else, if no package manager has been found
		else
			# Set $NOPKGMANAGER
			NOPKGMANAGER=TRUE
			shw_err "ERROR: No package manager found. Please, manually install: $PKGSTOINSTALL."
			fi
		fi
	fi
		
	if [ "$PROCESS_NUM" == "0" ];
	then
		shw_err "DenyHosts is not installed, install it now."
		apt-get install denyhosts -y
	else
		shw_info "DenyHosts already active."
	fi

		shw_info "Modify configuration thanks to this tutorial : http://www.it-connect.fr/proteger-son-acces-ssh-avec-denyhosts%EF%BB%BF/"
		cp $denyhostsConfigFile $denyhostsConfigFile.$NOW
		sed -i 's@#SECURE_LOG = /var/log/auth.log@SECURE_LOG = /var/log/auth.log@g' $denyhostsConfigFile
		sed -i 's@#HOSTS_DENY = /etc/hosts.deny@HOSTS_DENY = /etc/hosts.deny@g' $denyhostsConfigFile
		sed -i 's@PURGE_DENY =  @PURGE_DENY = 15d@g' $denyhostsConfigFile
		sed -i 's@# a denied host will be purged at most 2 times.@# a denied host will be purged at most 5 times.@g' $denyhostsConfigFile
		sed -i 's@#PURGE_THRESHOLD = 2@PURGE_THRESHOLD = 5@g' $denyhostsConfigFile
		sed -i 's@#BLOCK_SERVICE = ALL@BLOCK_SERVICE = ALL@g' $denyhostsConfigFile
		sed -i 's@BLOCK_SERVICE = sshd@#BLOCK_SERVICE = sshd@g' $denyhostsConfigFile
		shw_warn "denyhosts restart in progress..."
		service denyhosts restart

exit 0
