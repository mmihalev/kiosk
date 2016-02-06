#!/bin/bash

# Pretty colors
red='\e[0;31m'
green='\e[1;32m'
blue='\e[1;36m'
NC='\e[0m' # No color

clear
# Determine Ubuntu Version Codename
VERSION=$(lsb_release -cs)


echo -e "${red}Installing 3rd party software...${NC}\n"
apt-get -q=2 install pulseaudio > /dev/null
apt-get -q=2 install libvdpau* > /dev/null
apt-get -q=2 install alsa-utils > /dev/null
apt-get -q=2 install mc > /dev/null

wget -q https://raw.githubusercontent.com/mmihalev/kiosk/master/etc/pulse/default.pa -O /etc/pulse/default.pa
echo -e "${green}Done!${NC}\n"

# Crontab for fixing hdmi sound mute problem
echo -e "${red}Crontab for fixing hdmi sound mute problem${NC}\n"
echo '* * * * * /usr/bin/amixer set IEC958 unmute
' > /var/spool/cron/crontabs/kiosk
chown kiosk.crontab /var/spool/cron/crontabs/kiosk
echo -e "${green}Done!${NC}\n"

# Ubuntu loading theme
echo -e "${red}Customizing base theme...${NC}\n"
mkdir /lib/plymouth/themes/kiosk
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/master/lib/plymouth/themes/kiosk/dig.png -O /lib/plymouth/themes/kiosk/dig.png
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/master/lib/plymouth/themes/kiosk/kiosk.plymouth -O /lib/plymouth/themes/kiosk/kiosk.plymouth
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/master/lib/plymouth/themes/kiosk/kiosk.script -O /lib/plymouth/themes/kiosk/kiosk.script
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/master/usr/share/initramfs-tools/scripts/functions -O /usr/share/initramfs-tools/scripts/functions

update-alternatives --install /lib/plymouth/themes/default.plymouth default.plymouth /lib/plymouth/themes/kiosk/kiosk.plymouth 100
#update-alternatives --config default.plymouth
update-initramfs -u
echo -e "${green}Done!${NC}\n"

# Prevent sleeping for inactivity
echo -e "${red}Prevent sleeping for inactivity...${NC}\n"
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/master/etc/kbd/config -O /etc/kbd/config
echo -e "${green}Done!${NC}\n"

# Set correct user and group permissions for /home/kiosk
echo -e "${red}Set correct user and group permissions for ${blue}/home/kiosk${red}...${NC}\n"
chown -R kiosk.kiosk /home/kiosk/
echo -e "${green}Done!${NC}\n"

#Choose kiosk mode
echo -e "${green}Choose Kiosk Mode:${NC}"
PS3="Type 1, 2 or 3:"
options=("Video mode" "Photo mode" "Browser mode")
select opt in "${options[@]}"
do
	case $opt in
		"Video mode")
			echo -e "${green}Configuring the kiosk in Video mode...${NC}"
			sed -i -e 's/enable_videos="False"/enable_videos="True"/g' /home/kiosk/.kiosk/videos.cfg
			sed -i -e 's/\\"enable_videos\\": false/\\"enable_videos\\": true/g' /etc/ajenti/config.json
			
			sed -i -e 's/xscreensaver_enable="True"/xscreensaver_enable="False"/g' /home/kiosk/.kiosk/screensaver.cfg
			sed -i -e 's/\\"xscreensaver_enable\\": true/\\"xscreensaver_enable\\": false/g' /etc/ajenti/config.json
			
			sed -i -e 's/enable_browser="True"/enable_browser="False"/g' /home/kiosk/.kiosk/browser.cfg
			sed -i -e 's/\\"enable_browser\\": true/\\"enable_browser\\": false/g' /etc/ajenti/config.json
			
			echo -e "${green}Done!${NC}\n"
			break
			;;
		"Photo mode")
			echo -e "${green}Configuring the kiosk in Photo mode...${NC}"
			sed -i -e 's/xscreensaver_enable="False"/xscreensaver_enable="True"/g' /home/kiosk/.kiosk/screensaver.cfg
			sed -i -e 's/\\"xscreensaver_enable\\": false/\\"xscreensaver_enable\\": true/g' /etc/ajenti/config.json
			
			sed -i -e 's/enable_videos="True"/enable_videos="False"/g' /home/kiosk/.kiosk/videos.cfg
			sed -i -e 's/\\"enable_videos\\": true/\\"enable_videos\\": false/g' /etc/ajenti/config.json
			
			sed -i -e 's/enable_browser="True"/enable_browser="False"/g' /home/kiosk/.kiosk/browser.cfg
			sed -i -e 's/\\"enable_browser\\": true/\\"enable_browser\\": false/g' /etc/ajenti/config.json
			
			echo -e "${green}Done!${NC}\n"
			break
			;;
		"Browser mode")
			echo -e "${green}Configuring the kiosk in Browser mode...${NC}"
			sed -i -e 's/enable_browser="False"/enable_browser="True"/g' /home/kiosk/.kiosk/browser.cfg
			sed -i -e 's/\\"enable_browser\\": false/\\"enable_browser\\": true/g' /etc/ajenti/config.json
			
			sed -i -e 's/enable_videos="True"/enable_videos="False"/g' /home/kiosk/.kiosk/videos.cfg
			sed -i -e 's/\\"enable_videos\\": true/\\"enable_videos\\": false/g' /etc/ajenti/config.json
			
			sed -i -e 's/xscreensaver_enable="True"/xscreensaver_enable="False"/g' /home/kiosk/.kiosk/screensaver.cfg
			sed -i -e 's/\\"xscreensaver_enable\\": true/\\"xscreensaver_enable\\": false/g' /etc/ajenti/config.json
			
			echo -e "${green}Done!${NC}\n"
			break
			;;
		*) echo -e "${red}Invalid Option. Please, choose 1, 2 or 3${NC}";;
	esac
done

# Choose kiosk name
kiosk_name=""
while [[ ! $kiosk_name =~ ^[A-Za-z0-9]+$ ]]; do
    echo -e "${green}Kiosk name (e.g. kiosk1):${NC}"
    read kiosk_name
done

old_hostname="$( hostname )"

if [ -n "$( grep "$old_hostname" /etc/hosts )" ]; then
    sed -i "s/$old_hostname/$kiosk_name/g" /etc/hosts
else
    echo -e "$( hostname -I | awk '{ print $1 }' )\t$kiosk_name" >> /etc/hosts
fi

sed -i "s/$old_hostname/$kiosk_name/g" /etc/hostname
echo -e "${blue}Kiosk hostname set to: ${kiosk_name}${NC}"


echo -e "${red}Adding the customized image installation maker ${blue}(Mondo Rescue)${red}...${NC}\n"
wget -q -O - ftp://ftp.mondorescue.org/ubuntu/12.10/mondorescue.pubkey | apt-key add -
echo '
## Mondo Rescue
deb ftp://ftp.mondorescue.org/ubuntu 14.04 contrib
'  >> /etc/apt/sources.list
apt-get -q=2 update && apt-get -q=2 install --no-install-recommends --force-yes mondo > /dev/null
echo -e "${green}Done!${NC}\n"

echo -e "${green}Reboot?${NC}"
select yn in "Yes" "No"; do
        case $yn in
                Yes )
                        reboot ;;
                No )
                        break ;;
        esac
done
