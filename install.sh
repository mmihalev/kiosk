#!/bin/bash

# Pretty colors
red='\e[0;31m'
green='\e[1;32m'
blue='\e[1;36m'
NC='\e[0m' # No color

clear
# Determine Ubuntu Version Codename
VERSION=$(lsb_release -cs)

echo -e "${red}Installing operating system updates ${blue}(this may take a while)${red}...${NC}\n"

# Use mirror method
sed -i "1i \
deb mirror://mirrors.ubuntu.com/mirrors.txt $VERSION main restricted universe multiverse\n\
deb mirror://mirrors.ubuntu.com/mirrors.txt $VERSION-updates main restricted universe multiverse\n\
deb mirror://mirrors.ubuntu.com/mirrors.txt $VERSION-backports main restricted universe multiverse\n\
deb mirror://mirrors.ubuntu.com/mirrors.txt $VERSION-security main restricted universe multiverse\n\
" /etc/apt/sources.list

# Refresh
apt-get -q=2 update

# Download & Install
#apt-get -q=2 dist-upgrade > /dev/null

# Clean
apt-get -q=2 autoremove
apt-get -q=2 clean
echo -e "${green}Done!${NC}\n"

echo -e "${red}Disabling root recovery mode...${NC}\n"
sed -i -e 's/#GRUB_DISABLE_RECOVERY/GRUB_DISABLE_RECOVERY/g' /etc/default/grub
sed -i -e 's/GRUB_DISTRIBUTOR=`lsb_release -i -s 2> \/dev\/null || echo Debian`/GRUB_DISTRIBUTOR=Kiosk/g' /etc/default/grub
sed -i -e 's/GRUB_TIMEOUT=10/GRUB_TIMEOUT=4/g' /etc/default/grub
update-grub
echo -e "\n${green}Done!${NC}\n"

echo -e "${red}Enabling secure wireless support...${NC}\n"
apt-get -q=2 install --no-install-recommends wpasupplicant > /dev/null
echo -e "${green}Done!${NC}\n"

echo -e "${red}Installing a graphical user interface...${NC}\n"
apt-get -q=2 install --no-install-recommends xorg nodm matchbox-window-manager > /dev/null

# Hide Cursor
apt-get -q=2 install --no-install-recommends unclutter > /dev/null
echo -e "\n${green}Done!${NC}\n"

echo -e "${red}Creating administrator user...${NC}\n"
useradd administrator -m -d /home/administrator -p `openssl passwd -crypt ISdjE830` -s /bin/bash
echo -e "${green}Done!${NC}\n"

echo -e "${red}Creating kiosk user...${NC}\n"
useradd kiosk -m -d /home/kiosk -p `openssl passwd -crypt K10sk201` -s /bin/bash
echo -e "${green}Done!${NC}\n"

# Configure kiosk autologin
echo -e "${red}Configuring kiosk autologin...${NC}\n"
sed -i -e 's/NODM_ENABLED=false/NODM_ENABLED=true/g' /etc/default/nodm
sed -i -e 's/NODM_USER=root/NODM_USER=kiosk/g' /etc/default/nodm
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/master/etc/init.d/nodm -O /etc/init.d/nodm
echo -e "${green}Done!${NC}\n"

# Create .xscreensaver
echo -e "${red}Installing and configuring the screensaver...${NC}\n"
apt-get -q=2 install --no-install-recommends xscreensaver xscreensaver-data-extra xscreensaver-gl-extra libwww-perl > /dev/null
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/master/home/kiosk/xscreensaver -O /home/kiosk/.xscreensaver

# Create the screensaver directory
mkdir /home/kiosk/screensavers
echo -e "\n${green}Done!${NC}\n"

# Install Chromium browser
echo -e "${red}Installing ${blue}Chromium${red} browser...${NC}\n"
echo "
# Ubuntu Partners
deb http://archive.canonical.com/ $VERSION partner
"  >> /etc/apt/sources.list
apt-get -q=2 update
apt-get -q=2 -y install --force-yes chromium-browser > /dev/null
apt-get -q=2 install flashplugin-installer icedtea-7-plugin ttf-liberation > /dev/null # flash, java, and fonts
echo -e "\n${green}Done!${NC}\n"

# Kiosk scripts
echo -e "${red}Creating Kiosk Scripts...${NC}\n"
mkdir /home/kiosk/.kiosk

# Create xsession
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/master/home/kiosk/xsession -O /home/kiosk/.xsession

# Create other kiosk scripts
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/master/home/kiosk/kiosk/browser.cfg -O /home/kiosk/.kiosk/browser.cfg
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/master/home/kiosk/kiosk/browser_killer.sh -O /home/kiosk/.kiosk/browser_killer.sh
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/master/home/kiosk/kiosk/browser_switches.cfg -O /home/kiosk/.kiosk/browser_switches.cfg
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/master/home/kiosk/kiosk/glslideshow_switches.cfg -O /home/kiosk/.kiosk/glslideshow_switches.cfg
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/master/home/kiosk/kiosk/screensaver.cfg -O /home/kiosk/.kiosk/screensaver.cfg
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/master/home/kiosk/kiosk/set_glslideshow_switches.sh -O /home/kiosk/.kiosk/set_glslideshow_switches.sh
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/master/home/kiosk/kiosk/videos.cfg -O /home/kiosk/.kiosk/videos.cfg
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/master/home/kiosk/kiosk/videos_switches.cfg -O /home/kiosk/.kiosk/videos_switches.cfg

# Create browser killer
apt-get -q=2 install --no-install-recommends xprintidle > /dev/null
chmod +x /home/kiosk/.kiosk/browser_killer.sh

# Mplayer
echo -e "${red}Installing video player ${blue}mplayer${red}...${NC}\n"
apt-get -q=2 install mplayer > /dev/null
mkdir /home/kiosk/videos
echo -e "${green}Done!${NC}\n"

# Kiosk Web Control (Ajenti)
echo -e "${red}Adding the browser-based system administration tool ${blue}Kiosk web control${red}...${NC}\n"
wget -q http://repo.ajenti.org/debian/key -O- | apt-key add -
echo '
## Ajenti
deb http://repo.ajenti.org/ng/debian main main ubuntu
'  >> /etc/apt/sources.list
apt-get -q=2 update && apt-get -q=2 install --no-install-recommends ajenti > /dev/null
service ajenti stop
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/master/etc/ajenti/config.json -O /etc/ajenti/config.json

wget -q https://raw.githubusercontent.com/mmihalev/kiosk/master/usr/share/pyshared/ajenti/plugins/dashboard/content/js/controls.dashboard.coffee -O /usr/share/pyshared/ajenti/plugins/dashboard/content/js/controls.dashboard.coffee
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/master/usr/share/pyshared/ajenti/plugins/dashboard/content/js/controls.dashboard.coffee.c.js -O /usr/share/pyshared/ajenti/plugins/dashboard/content/js/controls.dashboard.coffee.c.js
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/master/usr/share/pyshared/ajenti/plugins/dashboard/layout/dash.xml -O /usr/share/pyshared/ajenti/plugins/dashboard/layout/dash.xml
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/master/usr/share/pyshared/ajenti/plugins/fm/__init__.py -O /usr/share/pyshared/ajenti/plugins/fm/__init__.py
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/master/usr/share/pyshared/ajenti/plugins/fm/fm.py -O /usr/share/pyshared/ajenti/plugins/fm/fm.py
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/master/usr/share/pyshared/ajenti/plugins/main/content/js/controls.index.coffee -O /usr/share/pyshared/ajenti/plugins/main/content/js/controls.index.coffee
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/master/usr/share/pyshared/ajenti/plugins/main/content/js/controls.index.coffee.c.js -O /usr/share/pyshared/ajenti/plugins/main/content/js/controls.index.coffee.c.js
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/master/usr/share/pyshared/ajenti/plugins/main/content/static/auth.html -O /usr/share/pyshared/ajenti/plugins/main/content/static/auth.html
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/master/usr/share/pyshared/ajenti/plugins/main/content/static/index.html -O /usr/share/pyshared/ajenti/plugins/main/content/static/index.html
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/master/usr/share/pyshared/ajenti/plugins/power/layout/widget.xml -O /usr/share/pyshared/ajenti/plugins/power/layout/widget.xml

echo -e "\n${green}Done!${NC}\n"

echo -e "${red}Adding Kiosk plugins to Kiosk web control...${NC}\n"
apt-get -q=2 install --no-install-recommends unzip > /dev/null
wget -q https://github.com/mmihalev/Ajenti-Plugins/archive/master.zip -O kiosk_plugins-master.zip
unzip -qq kiosk_plugins-master.zip
mv Ajenti-Plugins-master/* /var/lib/ajenti/plugins/
rm -rf Ajenti-Plugins-master
rm -rf /var/lib/ajenti/plugins/sanickiosk_*
echo -e "${green}Done!${NC}\n"

#NGINX
echo -e "${red}Installing ${blue}nginx${red} web server...${NC}\n"
apt-get -q=2 install nginx > /dev/null
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/master/etc/nginx/sites-enabled/default -O /etc/nginx/sites-available/default
sed -i -e 's/www-data/kiosk/g' /etc/nginx/nginx.conf
mkdir /home/kiosk/html
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/master/home/kiosk/html/index.html -O /home/kiosk/html/index.html
chown -R kiosk.kiosk /home/kiosk/html
echo -e "\n${green}Done!${NC}\n"

echo -e "${red}Installing touchscreen support...${NC}\n"
apt-get -q=2 install --no-install-recommends xserver-xorg-input-multitouch xinput-calibrator > /dev/null
echo -e "${green}Done!${NC}\n"

echo -e "${red}Installing audio...${NC}\n"
apt-get -q=2 install --no-install-recommends alsa > /dev/null
adduser kiosk audio
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/master/home/kiosk/asoundrc -O /home/kiosk/.asoundrc
chown kiosk.kiosk /home/kiosk/.asoundrc
echo -e "\n${green}Done!${NC}\n"

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


# Mondo Rescue
#echo -e "${red}Adding the customized image installation maker ${blue}(Mondo Rescue)${red}...${NC}\n"
#wget -q -O - ftp://ftp.mondorescue.org/ubuntu/12.10/mondorescue.pubkey | apt-key add -
#echo '
### Mondo Rescue
#deb ftp://ftp.mondorescue.org/ubuntu 14.04 contrib
#'  >> /etc/apt/sources.list
#apt-get -q=2 update && apt-get -q=2 install --no-install-recommends --force-yes mondo > /dev/null
#echo -e "${green}Done!${NC}\n"

echo -e "${green}Reboot?${NC}"
select yn in "Yes" "No"; do
        case $yn in
                Yes )
                        reboot ;;
                No )
                        break ;;
        esac
done
