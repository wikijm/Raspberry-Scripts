echo "Doing Debian Updates (slow) ..."
sudo aptitude -y update
sudo aptitude -y upgrade
sudo aptitude -y dist-upgrade
sudo aptitude -y autoclean
sudo aptitude -y full-upgrade

echo "Installing Raspberry Pi Packages"
sudo aptitude -y libraspberrypi-bin libraspberrypi0 raspberrypi-bootloader libraspberrypi-doc libraspberrypi-dev

echo "Installing Base Packages"
sudo aptitude -y install libgl1-mesa-dri libparse-debianchangelog-perl uuid-runtime xfonts-base gnupg-curl oss-compat upower libreadline5 sysv-rc-conf sysstat

echo "Installing USB WLAN Firmware"
sudo aptitude -y install zd1211-firmware firmware-ralink firmware-realtek

echo "Installing Web Servers"
sudo aptitude -y install apache2 lighttpd

echo "Installing Languages"
sudo aptitude -y install python php5 python-pygame python-rpi.gpio python3-rpi.gpio

echo "Installing Standard Tools"
sudo aptitude -y install irssi telnet dnsutils bluetooth whois htop

echo "Installing Development Environment"
sudo aptitude -y install vim nano git git-all tmux screen

echo "Installing System/Security"
sudo aptitude -y install libpcap-dev python-libpcap bridge-utils tcpdump tor nmap python-nmap

echo "Stopping expensive services"
sudo update-rc.d mysql remove
sudo /etc/init.d/mysql stop
sudo update-rc.d tor remove
sudo /etc/init.d/tor stop
sudo /etc/init.d/postgresql stop
sudo update-rc.d postgresql remove

echo "Doing Debian Updates (slow) ..."
sudo aptitude -y update
sudo aptitude -y upgrade
sudo aptitude -y dist-upgrade
sudo aptitude -y autoclean
sudo aptitude -y full-upgrade

echo "Install raspberry-motd"
cd /etc/profile.d/
wget https://raw.githubusercontent.com/wikijm/raspberrypi-motd/master/motd.sh
chown root:root motd.sh
chmod +x motd.sh

echo "Installing rpi-update"
sudo aptitude -y install ca-certificates git-core
sudo wget https://raw.github.com/Hexxeh/rpi-update/master/rpi-update -O /usr/bin/rpi-update && sudo chmod +x /usr/bin/rpi-update

echo "Updating firmware"
sudo rpi-update

echo "Define root password"
sudo passwd root

echo "Rebooting Raspberry"
sudo reboot
