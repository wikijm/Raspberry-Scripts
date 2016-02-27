# Raspberry-bootstrap

First script to run after setting up SD for Raspberry Pi

REQUIREMENTS:

		* Connect Raspberry with:
					   					- MicroSD card containing last Raspbian OS							   				- Network cable
					   					- (Optional) Wifi dongle
					   					- Power supply

		* On Desktop, launch Menu > Raspberry Pi Configuration, then:
					   					- Click "Expand Filesystem"
					   					- Modify "Hostname" value
					   					- Select "To CLI" for "Boot" option
					   					- Modify "Hostname" value
					   					- Uncheck "Auto Login option"
					   					- Modify options on "Localisation" tab
					   					- Apply modifications by clicking on "OK" then "YES"


  From your home directory (/home/pi/)
  ```curl -Lo- http://bit.ly/1Te6AAS | bash```
  
  Tip:
  http://bit.ly/1Te6AAS
  is a URL shorten version of
  https://raw.githubusercontent.com/wikijm/Raspberry-Scripts/master/Bootstrap-install.sh
