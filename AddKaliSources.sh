#!/bin/bash
#=======================================================================
#
#          FILE:  AddKaliSources.sh
# 
#         USAGE:  ./AddKaliSources.sh 
# 
#   DESCRIPTION:  Add a .sourcelist file who contains kali tool forensics packages without installing the full Kali-linux distribution
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  Root access rights
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Jean-Marc ALBERT
#       COMPANY:  ---
#       CREATED:  06.09.2015 10:34:00 UST
#      REVISION:  0.0.1
#=======================================================================

### Variables ###
NOW=$(date +%y.%m.%d-%T)
scriptfile="$(readlink -f $0)"
CURRENT_DIR="$(dirname ${scriptfile})"
kaliListFile="/etc/apt/sources.list.d/kali.list"

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

# Add progressbar for apt-get commands
	echo 'Dpkg::Progress-Fancy "1";' > /etc/apt/apt.conf.d/99progressbar


### Actions ###

# Create and complete /etc/apt/sources.list.d/kali.list
	shw_info "### Step 1 : Create $kaliListFile file ###"
		if [ -f $kaliListFile ];
		then
			shw_err "File $kaliListFile already exists. No modification needed. Exit of the script."
			exit 0
		else
			shw_info "Creation of $kaliListFile file done."
		fi
	
	shw_info "### Step 2 : Completion of $kaliListFile ###"
		printf "#kali linux distros
		\n	deb http://http.kali.org/kali kali main non-free contrib
		\n	deb http://security.kali.org/kali-security kali/updates main contrib non-free
		\n	deb http://repo.kali.org/kali kali-bleeding-edge main
		" >> $kaliListFile

	shw_info "### Step 3 : Start 'apt-get update' command ###"
	apt update
	shw_info "'apt-get update' command done."	

	exit 0