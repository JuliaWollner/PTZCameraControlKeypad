#!/bin/bash

# create supporting variables
root=`pwd`
cd ~
user=`pwd`
arduino=`lsusb | grep Future`
self='n'
use='n'

echo -e "\e[0m"
echo -e "\e[0m"
echo -e "\e[0m#######################################################"
echo -e "\e[0m####################### Stream ########################"
echo -e "\e[0m#######################################################"
echo -e "\e[0m"
echo -e "\e[96m"

# Query the autostart rtsp-stream and vlc
read -p "Should the RTSP-Stream and VLC-Player be started automatically (y/n): " stream
echo -e "\e[0m"

echo -e "\e[0m"
echo -e "\e[0m"
echo -e "\e[0m#######################################################"
echo -e "\e[0m####################### Querys ########################"
echo -e "\e[0m#######################################################"
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

# Setting the time
echo -e "\e[96m"
echo -e "\e[96mSetting the time\e[0m"
sudo dpkg-reconfigure tzdata

echo -e "\e[0m"
echo -e "\e[0m"
echo -e "\e[0m#######################################################"
echo -e "\e[0m################## Create directories #################"
echo -e "\e[0m#######################################################"
echo -e "\e[0m"

# create directories
echo -e "\e[0m"
echo -e "\e[96mCreate directories\e[0m"
mkdir $user/.credentials
sudo mkdir /opt/keypad
sudo mkdir /opt/keypad/sounds
sudo mkdir /opt/stream

echo -e "\e[0m"
echo -e "\e[0m"
echo -e "\e[0m#######################################################"
echo -e "\e[0m##### Update system and install necessary programs ####"
echo -e "\e[0m#######################################################"
echo -e "\e[0m"
echo -e "\e[0m"

# update Raspberry
echo -e "\e[0m"
echo -e "\e[96mUpdate Raspberry\e[0m"
echo -e "\e[0m"
sudo apt-get -y update 
sudo apt-get -y dist-upgrade

# install necessary programs
echo -e "\e[0m"
echo -e "\e[96mInstall necessary programs\e[0m"
echo -e "\e[0m"
sudo apt-get -y install fping minicom python-pip python3-pip

echo -e "\e[0m"
echo -e "\e[0m"
echo -e "\e[0m#######################################################"
echo -e "\e[0m################ Setting up the system ################"
echo -e "\e[0m#######################################################"
echo -e "\e[0m"
echo -e "\e[0m"

# copy credentials
echo -e "\e[0m"
echo -e "\e[96mCopy credentials\e[0m"
cp $root/system/camera.json $user/.credentials/camera.json
sed $user/.credentials/camera.json -i -e 's/^"benutzername": "YOURS",/"benutzername": "'$camerausername'",/'
sed $user/.credentials/camera.json -i -e 's/^"passwort": "YOURS",/"passwort": "'$camerapasswort'",/'
sed $user/.credentials/camera.json -i -e 's/^"server": "YOURS",/"server": "'$cameraip'",/'
sed $user/.credentials/camera.json -i -e 's/^"httpport": "YOURS",/"httpport": "'$camerahttpport'",/'
sed $user/.credentials/camera.json -i -e 's/^"rtspport": "YOURS"/"rtspport": "'$camerartspport'"/'

# create udev rule
echo -e "\e[0m"
echo -e "\e[96mCreate UDEV-Rule\e[0m"
touch $root/system/91-keypad.rules.new
echo 'SUBSYSTEMS=="usb", ATTRS{idVendor}=="'$vendor'", ATTRS{idProduct}=="'$product'", ATTRS{serial}=="'$serial'", SYMLINK+="keypad", ACTION=="add"' > $root/system/91-keypad.rules.new
sudo cp $root/system/91-keypad.rules.new /lib/udev/rules.d/91-keypad.rules
sudo chown root:root /lib/udev/rules.d/91-keypad.rules
sudo chmod 0644 /lib/udev/rules.d/91-keypad.rules
rm $root/system/91-keypad.rules.new

# create keypad deamon
echo -e "\e[0m"
echo -e "\e[96mCreate Systemd Service Unit\e[0m"
sudo cp $root/system/keypad.service /lib/systemd/system/keypad.service
sudo chown root:root /lib/systemd/system/keypad.service
sudo chmod 0644 /lib/systemd/system/keypad.service
sudo systemctl enable keypad.service

# create LXDE autostart object
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
	# disable blank screen
	echo -e "\e[0m"
	echo -e "\e[96mDisable blank screen\e[0m"
	sudo bash -c "printf ""'\n'"" >> /etc/xdg/lxsession/LXDE-pi/autostart"
	sudo bash -c "printf ""@xset\ s\ noblank'\n'"" >> /etc/xdg/lxsession/LXDE-pi/autostart"

	# disable screensaver
	echo -e "\e[0m"
	echo -e "\e[96mDisable screensaver\e[0m"
	sudo bash -c "printf ""@xset\ s\ off'\n'"" >> /etc/xdg/lxsession/LXDE-pi/autostart"

	# disable Power Management 
	echo -e "\e[0m"
	echo -e "\e[96mDisable power management\e[0m"
	sudo bash -c "printf ""@xset\ -dpms'\n'"" >> /etc/xdg/lxsession/LXDE-pi/autostart"
	sudo bash -c "printf ""'\n'"" >> /etc/xdg/lxsession/LXDE-pi/autostart"
fi

echo -e "\e[0m"
echo -e "\e[0m"
echo -e "\e[0m#######################################################"
echo -e "\e[0m##################### copy files ######################"
echo -e "\e[0m#######################################################"
echo -e "\e[0m"
echo -e "\e[0m"

# copy program files
echo -e "\e[0m"
echo -e "\e[96mCopy keypad files\e[0m"
find $root/keypad -type f -exec chmod a+x {} +
sudo cp $root/keypad/* /opt/keypad

# copy sound files
echo -e "\e[0m"
echo -e "\e[96mCopy sound files\e[0m"
sudo cp $root/sounds/* /opt/keypad/sounds

# adapt file Keypad4x4.py
echo -e "\e[0m"
echo -e "\e[96mAdapt file Keypad4x4.py\e[0m"
sudo sed /opt/keypad/keypad4x4.py -i -e 's#YOURS#'$user'/.credentials/camera.json#'

# copy stream files
echo -e "\e[0m"
echo -e "\e[96mCopy stream files\e[0m"
find $root/stream -type f -exec chmod a+x {} +
sudo cp $root/stream/* /opt/stream

# adapt file Streamhandler.py
echo -e "\e[0m"
echo -e "\e[96mAdapt file Streamhandler.py\e[0m"
sudo sed /opt/stream/streamhandler.py -i -e 's#YOURS#'$user'/.credentials/camera.json#'

echo -e "\e[0m"
echo -e "\e[0m"
echo -e "\e[0m#######################################################"
echo -e "\e[0m#################### Start Serices ####################"
echo -e "\e[0m#######################################################"
echo -e "\e[0m"
echo -e "\e[0m"

# sudo systemctl start keypad.service
echo -e "\e[91mTo take effect a reboot is required.\e[0m"
echo -e "\e[0m"