#!/bin/bash

# Create supporting variables
PS3="
Option: "
root=`pwd`
cd ~
user=`pwd`
arduino=`lsusb | grep Future`
self='n'
use='n'
installed='n'
selection='0'

echo -e "\e[0m"
echo -e "\e[0m"
echo -e "\e[0m#############################################################"
echo -e "\e[0m######                                                 ######"
echo -e "\e[0m######                   Installation                  ######"
echo -e "\e[0m######             PTZ-CameraControlKeypad             ######"
echo -e "\e[0m######                                                 ######"
echo -e "\e[0m#############################################################"
echo -e "\e[0m"
echo -e "\e[0m"

# Check if program is already installed
if [ -f /opt/keypad/keypad4x4.py ] && [ -f /opt/keypad/keypadhandler.py ] ;
	then
	installed='y'
fi

# Message about installation
if [ $installed == 'n' ];
	then
	echo -e "\e[96mThe program is not installed. Please choose from the following options:\e[0m"
	echo -e "\e[96m"
elif [ $installed == 'y' ];
	then
	echo -e "\e[96mThe program is already installed. Please choose from the following options:\e[0m"
	echo -e "\e[96m"
else
	exit
fi

# Display of a selection menu
if [ $installed == 'n' ];
	then 
	select selection in "Install program" "End setup"
	do
	   case "$selection" in
		  "End setup") 	echo -e "\e[0m"; echo -e "\e[91mSetup aborted. No changes made.\e[0m"; echo -e "\e[96m"; exit ;;
			"")  echo -e "\e[96mWrong selection. Select any number from 1 - 2\e[0m" ; echo -e "\e[96m" ;;
			 *)  break ;;
	   esac
	done
elif [ $installed == 'y' ];
	then
	select selection in "Deinstall programm" "End setup"
	do
	   case "$selection" in
		  "End setup") echo -e "\e[0m"; echo -e "\e[91mSetup aborted. No changes made.\e[0m"; echo -e "\e[96m"; exit ;;
			"")  echo -e "\e[96mWrong selection. Select any number from 1 - 2\e[0m" ; echo -e "\e[96m" ;;
			 *)  break ;;
	   esac
	done
else
	exit
fi

# Convert varialbe selection
if [ "$selection" == 'Install program' ];
	then
	selection='1'
elif [ "$selection" == 'Deinstall programm' ];
	then
	selection='2'
else
	exit
fi

# Running setup
if [ $selection == '1' ];
	then
	echo -e "\e[0m"
	echo -e "\e[0m"
	echo -e "\e[0m#############################################################"
	echo -e "\e[0m######                      Stream                     ######"
	echo -e "\e[0m#############################################################"
	echo -e "\e[0m"
	echo -e "\e[96m"

	# Query the autostart rtsp-stream and vlc
	read -p "Should the RTSP-Stream and VLC-Player be started automatically (y/n): " stream
	echo -e "\e[0m"

	echo -e "\e[0m"
	echo -e "\e[0m"
	echo -e "\e[0m#############################################################"
	echo -e "\e[0m######                      Querys                     ######"
	echo -e "\e[0m#############################################################"
	echo -e "\e[96m"

	# If Arduino is found Query for automatically insert of variables
	if [ -z "${arduino}" ]; then
		echo -e "\e[96m"
	else
		echo -e "\e[96m"
		read -p "Should be tried to find the Arduino automatically: (y/n) " self
		echo -e "\e[96m"
	fi

	# Try to detect data automatically. Should we use them?
	if [ $self == 'y' ]; then
		echo -e "\e[0m"
		bus=`lsusb | grep Future | awk -F " " '{print $2}' | sed -e 's/[[:space:]]*//' -e 's/[[:space:]]*$//'`
		device=`lsusb | grep Future | awk -F " " '{print $4}' | sed -e 's/[[:space:]]*//' -e 's/[[:space:]]*$//' | sed -e 's/://'`
		vsvar=${bus}:${device}
		vendor=`lsusb | grep Future | awk -F " " '{print $6}' | sed -e 's/[[:space:]]*//' -e 's/[[:space:]]*$//' | cut -c -4`
		product=`lsusb | grep Future | awk -F " " '{print $6}' | sed -e 's/[[:space:]]*//' -e 's/[[:space:]]*$//' | cut -c 6-`
		serial=`lsusb -vs ${vsvar} | grep iSerial | awk -F " " '{print $3}' | sed -e 's/[[:space:]]*//' -e 's/[[:space:]]*$//'`
		echo -e "\e[0m"
		echo -e "\e[96mData of the found Arduino:\e[0m"
		echo -e "\e[0m"
		echo -e "\e[96midVendor  = ${vendor}\e[0m"
		echo -e "\e[96midProduct = ${product}\e[0m"
		echo -e "\e[96miSerial   = ${serial}\e[0m"
		echo -e "\e[96m"
		read -p "Should we use this Arduino data: (y/n) " use
		echo -e "\e[96m"
		echo -e "\e[96m"
	fi

	# Use automatically detected data or ask User for data
	if [ $use == 'y' ]; then
		echo "We use the automatically detected data."
		echo -e "\e[96m"
		echo -e "\e[96m"
	else

		# Query idVendor
		read -p "Insert the idVendor of the Arduino: " vendor
		echo -e "\e[96m"
		echo -e "\e[96m"

		# Query idProduct
		read -p "Insert the idProduct of the Arduino: " product
		echo -e "\e[96m"
		echo -e "\e[96m"

		# Query idSerial
		read -p "Insert the idSerial of the Arduino: " serial
		echo -e "\e[96m"
		echo -e "\e[96m"
	fi

	# Query IP of the Camera
	read -p "Insert the IP of the camera (z. B. 192.168.111.5): " cameraip
	echo -e "\e[96m"
	echo -e "\e[96m"

	# Query HTTP-Port of the Camera
	read -p "Insert the HTTP-Port of the camera (default 80): " camerahttpport
	echo -e "\e[96m"
	echo -e "\e[96m"

	# Query RTSP-Port of the Camera
	read -p "Insert the RTSP-Port of the camera (default 554): " camerartspport
	echo -e "\e[96m"
	echo -e "\e[96m"

	# Query the username of the camera
	read -p "Insert the username of the camera: " camerausername
	echo -e "\e[96m"
	echo -e "\e[96m"

	# Query the password of the camera
	read -s -p "Insert the password of the camera: " camerapasswort
	echo -e "\e[96m"
	echo -e "\e[96m"

	echo -e "\e[0m"
	echo -e "\e[0m"
	echo -e "\e[0m#############################################################"
	echo -e "\e[0m######                Create directories               ######"
	echo -e "\e[0m#############################################################"
	echo -e "\e[0m"

	# Create directories
	echo -e "\e[0m"
	echo -e "\e[96mCreate directories\e[0m"
	if [ ! -d $user/.credentials ];
		then
		mkdir $user/.credentials
	fi
	if [ ! -d /opt/keypad ];
		then
		sudo mkdir /opt/keypad
	fi
	if [ ! -d /opt/keypad/sounds ];
		then
		sudo mkdir /opt/keypad/sounds
	fi
	if [ ! -d /opt/stream ];
		then
		sudo mkdir /opt/stream
	fi

	echo -e "\e[0m"
	echo -e "\e[0m"
	echo -e "\e[0m#############################################################"
	echo -e "\e[0m######       Update system and install  programs       ######"
	echo -e "\e[0m#############################################################"
	echo -e "\e[0m"

	# Update Raspberry
	echo -e "\e[0m"
	echo -e "\e[96mUpdate Raspberry\e[0m"
	echo -e "\e[0m"
	sudo apt-get -y update 
	sudo apt-get -y dist-upgrade

	# Install necessary programs
	echo -e "\e[0m"
	echo -e "\e[96mInstall necessary programs\e[0m"
	echo -e "\e[0m"
	sudo apt-get -y install fping minicom python-pip python3-pip

	echo -e "\e[0m"
	echo -e "\e[0m"
	echo -e "\e[0m#############################################################"
	echo -e "\e[0m######              Setting up the system              ######"
	echo -e "\e[0m#############################################################"
	echo -e "\e[0m"

	# Copy credentials
	echo -e "\e[0m"
	echo -e "\e[96mCopy credentials\e[0m"
	cp $root/system/camera.json $user/.credentials/camera.json
	sed $user/.credentials/camera.json -i -e 's/^"benutzername": "YOURS",/"benutzername": "'$camerausername'",/'
	sed $user/.credentials/camera.json -i -e 's/^"passwort": "YOURS",/"passwort": "'$camerapasswort'",/'
	sed $user/.credentials/camera.json -i -e 's/^"server": "YOURS",/"server": "'$cameraip'",/'
	sed $user/.credentials/camera.json -i -e 's/^"httpport": "YOURS",/"httpport": "'$camerahttpport'",/'
	sed $user/.credentials/camera.json -i -e 's/^"rtspport": "YOURS"/"rtspport": "'$camerartspport'"/'

	# Create udev rule
	echo -e "\e[0m"
	echo -e "\e[96mCreate UDEV-Rule\e[0m"
	if [ -f $root/system/91-keypad.rules.new ];
		then
		rm $root/system/91-keypad.rules.new
		touch $root/system/91-keypad.rules.new
	fi
	echo 'SUBSYSTEMS=="usb", ATTRS{idVendor}=="'$vendor'", ATTRS{idProduct}=="'$product'", ATTRS{serial}=="'$serial'", SYMLINK+="keypad", ACTION=="add"' > $root/system/91-keypad.rules.new
	sudo cp $root/system/91-keypad.rules.new /lib/udev/rules.d/91-keypad.rules
	sudo chown root:root /lib/udev/rules.d/91-keypad.rules
	sudo chmod 0644 /lib/udev/rules.d/91-keypad.rules
	rm $root/system/91-keypad.rules.new

	# Create keypad deamon
	echo -e "\e[0m"
	echo -e "\e[96mCreate keypad deamon\e[0m"
	sudo cp $root/system/keypad.service /lib/systemd/system/keypad.service
	sudo chown root:root /lib/systemd/system/keypad.service
	sudo chmod 0644 /lib/systemd/system/keypad.service
	sudo systemctl enable keypad.service

	# Create LXDE autostart object
	echo -e "\e[0m"
	echo -e "\e[96mCreate LXDE autostart object\e[0m"
	if [ $stream == 'y' ];
		then
		echo -e "\e[0m"
		echo -e "\e[96mStream and VLC-Player start automatically\e[0m"
		sudo cp $root/system/streamhandler.desktop /etc/xdg/autostart/streamhandler.desktop
		sudo chown root:root /etc/xdg/autostart/streamhandler.desktop
		sudo chmod 0644 /etc/xdg/autostart/streamhandler.desktop
	else
		echo -e "\e[0m"
		echo -e "\e[96mStream and VLC-Player do not start automatically\e[0m"	
		sudo cp $root/system/streamhandler.desktop /etc/xdg/autostart/streamhandler
		sudo chown root:root /etc/xdg/autostart/streamhandler
		sudo chmod 0644 /etc/xdg/autostart/streamhandler
	fi

	if [ $stream == 'y' ];
		then 
		# disable screen blanking
		echo -e "\e[0m"
		echo -e "\e[96mDisable screen blanking\e[0m"
		sudo mkdir -p /etc/X11/xorg.conf.d/
		sudo cp /usr/share/raspi-config/10-blanking.conf /etc/X11/xorg.conf.d/
	fi
	
	# Enable global sound setting
	echo -e "\e[0m"
	echo -e "\e[96mEnable global sound setting\e[0m"
	if [ -f /home/pi/.asoundrc ];
		then
		sudo cp /home/pi/.asoundrc /etc/asound.conf
	fi

	echo -e "\e[0m"
	echo -e "\e[0m"
	echo -e "\e[0m#############################################################"
	echo -e "\e[0m######                   Copy files                    ######"
	echo -e "\e[0m#############################################################"
	echo -e "\e[0m"

	# Copy program files
	echo -e "\e[0m"
	echo -e "\e[96mCopy keypad files\e[0m"
	find $root/keypad -type f -exec chmod a+x {} +
	sudo cp $root/keypad/* /opt/keypad

	# Copy sound files
	echo -e "\e[0m"
	echo -e "\e[96mCopy sound files\e[0m"
	sudo cp $root/sounds/* /opt/keypad/sounds

	# Adapt file Keypad4x4.py
	echo -e "\e[0m"
	echo -e "\e[96mAdapt file Keypad4x4.py\e[0m"
	sudo sed /opt/keypad/keypad4x4.py -i -e 's#YOURS#'$user'/.credentials/camera.json#'

	# Copy stream files
	echo -e "\e[0m"
	echo -e "\e[96mCopy stream files\e[0m"
	find $root/stream -type f -exec chmod a+x {} +
	sudo cp $root/stream/* /opt/stream

	# Adapt file Streamhandler.py
	echo -e "\e[0m"
	echo -e "\e[96mAdapt file Streamhandler.py\e[0m"
	sudo sed /opt/stream/streamhandler.py -i -e 's#YOURS#'$user'/.credentials/camera.json#'

	echo -e "\e[0m"
	echo -e "\e[0m"
	echo -e "\e[0m#############################################################"
	echo -e "\e[0m######                  Start Serice                   ######"	
	echo -e "\e[0m#############################################################"
	echo -e "\e[0m"

	sudo systemctl start keypad.service

	echo -e "\e[91mInstallation complete. To take effect a reboot is required.\e[0m"
	echo -e "\e[0m"

elif [ $selection == '2' ];
	then

	echo -e "\e[0m"
	echo -e "\e[0m"
	echo -e "\e[0m#############################################################"
	echo -e "\e[0m######          Delete files and directories           ######"	
	echo -e "\e[0m#############################################################"
	echo -e "\e[0m"

	# Delete credentials
	echo -e "\e[0m"
	echo -e "\e[96mDelete credentials\e[0m"
	if [ -f $user/.credentials/camera.json ];
		then
		sudo rm $user/.credentials/camera.json
	fi

	# Delete udev rule
	echo -e "\e[0m"
	echo -e "\e[96mDelete UDEV-Rule\e[0m"
	if [ -f /lib/udev/rules.d/91-keypad.rules ];
		then
		sudo rm /lib/udev/rules.d/91-keypad.rules
	fi

	# Delete keypad deamon
	echo -e "\e[0m"
	echo -e "\e[96mDelete keypad deamon\e[0m"	
	if [ -f /lib/systemd/system/keypad.service ];
		then
		sudo systemctl disable keypad.service
		sudo systemctl stop keypad.service
		sudo rm /lib/systemd/system/keypad.service
	fi

	# Delete LXDE autostart object
	echo -e "\e[0m"
	echo -e "\e[96mDelete LXDE autostart object\e[0m"	
	if [ -f /etc/xdg/autostart/streamhandler.desktop ];
		then
		sudo rm /etc/xdg/autostart/streamhandler.desktop
	fi	
	if [ -f /etc/xdg/autostart/streamhandler ];
		then
		sudo rm /etc/xdg/autostart/streamhandler
	fi	

	# enable screen blanking
	echo -e "\e[0m"
	echo -e "\e[96mEnable screen blanking\e[0m"
	sudo rm -f /etc/X11/xorg.conf.d/10-blanking.conf
	
	# Disable global sound setting
	echo -e "\e[0m"
	echo -e "\e[96mDisable global sound setting\e[0m"
	if [ -f /etc/asound.conf ];
		then
		sudo rm -rf /etc/asound.conf
	fi

	# Delete sound files and directory
	echo -e "\e[0m"
	echo -e "\e[96mDelete sound files and directory\e[0m"
	if [ -d /opt/keypad/sounds ];
		then
		sudo rm -rf /opt/keypad/sounds
	fi	

	# Delete keypad files and directory
	echo -e "\e[0m"
	echo -e "\e[96mDelete keypad files and directory\e[0m"
	if [ -d /opt/keypad ];
		then
		sudo rm -rf /opt/keypad
	fi	

	# Delete stream files and directory
	echo -e "\e[0m"
	echo -e "\e[96mDelete keypad files and directory\e[0m"
	if [ -d /opt/stream ];
		then
		sudo rm -rf /opt/stream
	fi	

	# sudo systemctl start keypad.service
	echo -e "\e[0m"
	echo -e "\e[91mDeinstallation complete. To take effect a reboot is required.\e[0m"
	echo -e "\e[0m"

else
	exit
fi
