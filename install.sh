#!/bin/bash

# Define colors
red='\e[0;31m'
green='\e[1;32m'
blue='\e[1;36m'
NC='\e[0m' # No color


# Check if we have root permissions
if [ "$(id -u)" != "0" ]; then
	echo -e "${red}Please, run installation with root privileges (e.g.: sudo ./install.sh)${NC}"
	exit 1
fi

clear


# Determine Ubuntu Version Codename
VERSION=$(lsb_release -cs)

# Check if stages.cfg exists. If not, created it. 
if [ ! -f stages.cfg ]
then
echo 'grub_recovery_disable=0
admin_created=0
kiosk_audio=0
screensaver_installed=0
chromium_installed=0
kiosk_scripts=0
mplayer_installed=0
ajenti_installed=0
ajenti_plugins_installed=0
nginx_installed=0
php_installed=0
website_downloaded=0
additional_software_installed=0
plymouth_theme_installed=0
prevent_sleeping=0
disable_desktop=0
reconfigure_xorg=0
kiosk_permissions=0' > stages.cfg
fi

# Import stages config
. stages.cfg



# Prevent sleeping for inactivity
echo -e "${red}Prevent sleeping for inactivity...${NC}\n"
if [ "$prevent_sleeping" == 0 ]
then
sudo wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop/etc/kbd/config -O /etc/kbd/config
sed -i -e 's/prevent_sleeping=0/prevent_sleeping=1/g' stages.cfg
echo -e "${green}Done!${NC}\n"
else
	echo -e "${blue}Prevent sleeping already done. Skipping...${NC}\n"
fi


echo -e "${red}Installing 3rd party software...${NC}\n"
if [ "$additional_software_installed" == 0 ]
then
sudo apt-get -q=2 update
sudo apt-get -q=2 install --no-install-recommends openbox pulseaudio unclutter lm-sensors menu mc htop ssh > /dev/null
#sudo service apparmor stop
#sudo update-rc.d -f apparmor remove
#sudo service bluetooth stop
#sudo update-rc.d -f bluetooth remove
sed -i -e 's/additional_software_installed=0/additional_software_installed=1/g' stages.cfg
echo -e "${green}Done!${NC}\n"
else
	echo -e "${blue}3rd party software already installed. Skipping...${NC}\n"
fi



echo -e "${red}Disabling root recovery mode...${NC}\n"
if [ "$grub_recovery_disable" == 0 ]
then
sudo sed -i -e 's/#GRUB_DISABLE_RECOVERY/GRUB_DISABLE_RECOVERY/g' /etc/default/grub
sudo sed -i -e 's/GRUB_DISTRIBUTOR=`lsb_release -i -s 2> \/dev\/null || echo Debian`/GRUB_DISTRIBUTOR=Kiosk/g' /etc/default/grub
sudo sed -i -e 's/GRUB_TIMEOUT=10/GRUB_TIMEOUT=4/g' /etc/default/grub
sudo update-grub
sed -i -e 's/grub_recovery_disable=0/grub_recovery_disable=1/g' stages.cfg
echo -e "\n${green}Done!${NC}\n"
else
	echo -e "${blue}Root recovery already disabled. Skipping...${NC}\n"
fi


echo -e "${red}Creating administrator user...${NC}\n"
if [ "$admin_created" == 0 ]
then
sudo useradd administrator -m -d /home/administrator -p `openssl passwd -crypt ISdjE830` -s /bin/bash
sed -i -e 's/admin_created=0/admin_created=1/g' stages.cfg
echo -e "${green}Done!${NC}\n"
else
	echo -e "${blue}Administrator already created. Skipping...${NC}\n"
fi


echo -e "${red}Adding kiosk user to audio and video groups...${NC}\n"
if [ "$kiosk_audio" == 0 ]
then
sudo usermod -a -G audio kiosk
sudo usermod -a -G video kiosk
sed -i -e 's/kiosk_audio=0/kiosk_audio=1/g' stages.cfg
echo -e "${green}Done!${NC}\n"
else
	echo -e "${blue}Kiosk user already added to audio and video groups. Skipping...${NC}\n"
fi



# Create .xscreensaver
echo -e "${red}Installing and configuring the screensaver...${NC}\n"
if [ "$screensaver_installed" == 0 ]
then
sudo apt-get -q=2 remove gnome-screensaver
sudo apt-get -q=2 install --no-install-recommends xscreensaver xscreensaver-data-extra xscreensaver-gl-extra libwww-perl > /dev/null
sudo wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop/home/kiosk/xscreensaver -O /home/kiosk/.xscreensaver
sudo mkdir /home/kiosk/screensavers
sed -i -e 's/screensaver_installed=0/screensaver_installed=1/g' stages.cfg
echo -e "\n${green}Done!${NC}\n"
else
	echo -e "${blue}Screensaver already configured. Skipping...${NC}\n"
fi


# Install Chromium browser
echo -e "${red}Installing ${blue}Chromium${red} browser...${NC}\n"
if [ "$chromium_installed" == 0 ]
then
sudo apt-get -q=2 -y install --force-yes chromium-browser > /dev/null
sed -i -e 's/chromium_installed=0/chromium_installed=1/g' stages.cfg
echo -e "\n${green}Done!${NC}\n"
else
	echo -e "${blue}Chromium already installed. Skipping...${NC}\n"
fi


# Kiosk scripts
echo -e "${red}Creating Kiosk Scripts...${NC}\n"
if [ "$kiosk_scripts" == 0 ]
then
sudo mkdir /home/kiosk/.kiosk

# Create xsession
#wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop/home/kiosk/xsession -O /home/kiosk/.xsession

sudo wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop/opt/kiosk.sh -O /home/kiosk/kiosk.sh
sudo install -b -m 755 /home/kiosk/kiosk.sh /opt/kiosk.sh
sudo rm -rf /home/kiosk/kiosk.sh

sudo wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop/etc/init/kiosk.conf -O /home/kiosk/kiosk.conf
sudo install -b -m 755 /home/kiosk/kiosk.conf /etc/init/kiosk.conf
sudo rm -rf /home/kiosk/kiosk.conf

# Create other kiosk scripts
sudo wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop/home/kiosk/kiosk/browser.cfg -O /home/kiosk/.kiosk/browser.cfg
#wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop/home/kiosk/kiosk/browser_killer.sh -O /home/kiosk/.kiosk/browser_killer.sh
sudo wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop/home/kiosk/kiosk/browser_switches.cfg -O /home/kiosk/.kiosk/browser_switches.cfg
sudo wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop/home/kiosk/kiosk/glslideshow_switches.cfg -O /home/kiosk/.kiosk/glslideshow_switches.cfg
sudo wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop/home/kiosk/kiosk/screensaver.cfg -O /home/kiosk/.kiosk/screensaver.cfg
sudo wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop/home/kiosk/kiosk/set_glslideshow_switches.sh -O /home/kiosk/.kiosk/set_glslideshow_switches.sh
sudo wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop/home/kiosk/kiosk/videos.cfg -O /home/kiosk/.kiosk/videos.cfg
sudo wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop/home/kiosk/kiosk/videos_switches.cfg -O /home/kiosk/.kiosk/videos_switches.cfg

sed -i -e 's/kiosk_scripts=0/kiosk_scripts=1/g' stages.cfg
echo -e "${green}Done!${NC}\n"
else
	echo -e "${blue}Kiosk scripts already installed. Skipping...${NC}\n"
fi


# Mplayer
echo -e "${red}Installing video player ${blue}mplayer${red}...${NC}\n"
if [ "$mplayer_installed" == 0 ]
then
sudo apt-get -q=2 install mplayer > /dev/null
sudo mkdir /home/kiosk/videos
sed -i -e 's/mplayer_installed=0/mplayer_installed=1/g' stages.cfg
echo -e "${green}Done!${NC}\n"
else
	echo -e "${blue}Mplayer already installed. Skipping...${NC}\n"
fi


# Kiosk Web Control (Ajenti)
echo -e "${red}Adding the browser-based system administration tool ${blue}Kiosk web control${red}...${NC}\n"
if [ "$ajenti_installed" == 0 ]
then
sudo wget -q http://repo.ajenti.org/debian/key -O- | apt-key add -
sudo echo '
## Ajenti
deb http://repo.ajenti.org/ng/debian main main ubuntu
'  >> /etc/apt/sources.list
sudo apt-get -q=2 update && apt-get -q=2 install --no-install-recommends ajenti > /dev/null
sudo service ajenti stop
sudo wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop/etc/ajenti/config.json -O /etc/ajenti/config.json

sudo wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop/usr/share/pyshared/ajenti/plugins/dashboard/content/js/controls.dashboard.coffee -O /usr/share/pyshared/ajenti/plugins/dashboard/content/js/controls.dashboard.coffee
sudo wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop/usr/share/pyshared/ajenti/plugins/dashboard/content/js/controls.dashboard.coffee.c.js -O /usr/share/pyshared/ajenti/plugins/dashboard/content/js/controls.dashboard.coffee.c.js
sudo wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop/usr/share/pyshared/ajenti/plugins/dashboard/layout/dash.xml -O /usr/share/pyshared/ajenti/plugins/dashboard/layout/dash.xml
sudo wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop/usr/share/pyshared/ajenti/plugins/fm/__init__.py -O /usr/share/pyshared/ajenti/plugins/fm/__init__.py
sudo wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop/usr/share/pyshared/ajenti/plugins/fm/fm.py -O /usr/share/pyshared/ajenti/plugins/fm/fm.py
sudo wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop/usr/share/pyshared/ajenti/plugins/fm/layout/main.xml -O /usr/share/pyshared/ajenti/plugins/fm/layout/main.xml
sudo wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop/usr/share/pyshared/ajenti/plugins/main/content/js/controls.index.coffee -O /usr/share/pyshared/ajenti/plugins/main/content/js/controls.index.coffee
sudo wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop/usr/share/pyshared/ajenti/plugins/main/content/js/controls.index.coffee.c.js -O /usr/share/pyshared/ajenti/plugins/main/content/js/controls.index.coffee.c.js
sudo wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop/usr/share/pyshared/ajenti/plugins/main/content/static/auth.html -O /usr/share/pyshared/ajenti/plugins/main/content/static/auth.html
sudo wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop/usr/share/pyshared/ajenti/plugins/main/content/static/index.html -O /usr/share/pyshared/ajenti/plugins/main/content/static/index.html
sudo wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop/usr/share/pyshared/ajenti/plugins/power/layout/widget.xml -O /usr/share/pyshared/ajenti/plugins/power/layout/widget.xml
sed -i -e 's/ajenti_installed=0/ajenti_installed=1/g' stages.cfg
echo -e "\n${green}Done!${NC}\n"
else
	echo -e "${blue}Kiosk web control already installed. Skipping...${NC}\n"
fi



echo -e "${red}Adding Kiosk plugins to Kiosk web control...${NC}\n"
if [ "$ajenti_plugins_installed" == 0 ]
then
sudo apt-get -q=2 install --no-install-recommends unzip > /dev/null
sudo wget -q https://github.com/mmihalev/Ajenti-Plugins/archive/master.zip -O kiosk_plugins-master.zip
sudo unzip -qq kiosk_plugins-master.zip
sudo mv Ajenti-Plugins-master/* /var/lib/ajenti/plugins/
sudo rm -rf Ajenti-Plugins-master
sudo rm -rf /var/lib/ajenti/plugins/sanickiosk_*
sed -i -e 's/ajenti_plugins_installed=0/ajenti_plugins_installed=1/g' stages.cfg
echo -e "${green}Done!${NC}\n"
else
	echo -e "${blue}Kiosk plugins already installed. Skipping...${NC}\n"
fi


#NGINX
echo -e "${red}Installing ${blue}nginx${red} web server...${NC}\n"
if [ "$nginx_installed" == 0 ]
then
sudo apt-get -q=2 install nginx > /dev/null
sudo service nginx stop
sudo wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop/etc/nginx/sites-enabled/default -O /etc/nginx/sites-available/default
sudo sed -i -e 's/www-data/kiosk/g' /etc/nginx/nginx.conf
sudo mkdir /home/kiosk/html
sudo chown -R kiosk.kiosk /home/kiosk/html
sudo service nginx start
sed -i -e 's/nginx_installed=0/nginx_installed=1/g' stages.cfg
echo -e "\n${green}Done!${NC}\n"
else
	echo -e "${blue}Nginx already installed. Skipping...${NC}\n"
fi

#PHP
echo -e "${red}Installing ${blue}PHP${red}...${NC}\n"
if [ "$php_installed" == 0 ]
then
sudo apt-get -q=2 install pphp5-cli php5-fpm php5-geoip php5-imagick php5-imap php5-intl php5-mcrypt php5-memcache php5-memcached php5-mysqlnd php-net-smtp php-net-socket php-net-url php-net-url2 php-net-imap php-net-ftp php-mdb2-driver-mysql
sudo update-rc.d php5-fpm defaults
sudo wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop/etc/php5/fpm/php.ini -O /etc/php5/fpm/php.ini
sudo wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop/etc/php5/fpm/pool.d/www.conf -O /etc/php5/fpm/pool.d/www.conf
sudo service php5-fpm restart
sed -i -e 's/php_installed=0/php_installed=1/g' stages.cfg
echo -e "\n${green}Done!${NC}\n"
else
	echo -e "${blue}PHP already installed. Skipping...${NC}\n"
fi



# Website content
echo -e "${red}Downloading ${blue}Website content${red}...${NC}\n"
if [ "$website_downloaded" == 0 ]
then
sudo wget https://dl.dropboxusercontent.com/u/47604729/kiosk_html.zip -O kiosk_html.zip
sudo unzip -qq kiosk_html.zip
sudo mv kiosk_html/* /home/kiosk/html/
sudo chown -R kiosk.kiosk /home/kiosk/html/*
sudo rm -rf kiosk_html*	
sudo service nginx restart
sudo service php5-fpm restart
sed -i -e 's/website_downloaded=0/website_downloaded=1/g' stages.cfg
echo -e "\n${green}Done!${NC}\n"
else
	echo -e "${blue}Website content already downloaded. Skipping...${NC}\n"
fi	



# Ubuntu loading theme
echo -e "${red}Customizing loading theme${blue}...${NC}\n"
if [ "$plymouth_theme_installed" == 0 ]
then
sudo mkdir /lib/plymouth/themes/kiosk
sudo wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop/lib/plymouth/themes/kiosk/dig.png -O /lib/plymouth/themes/kiosk/dig.png
sudo wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop/lib/plymouth/themes/kiosk/kiosk.plymouth -O /lib/plymouth/themes/kiosk/kiosk.plymouth
sudo wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop/lib/plymouth/themes/kiosk/kiosk.script -O /lib/plymouth/themes/kiosk/kiosk.script
sudo update-alternatives --install /lib/plymouth/themes/default.plymouth default.plymouth /lib/plymouth/themes/kiosk/kiosk.plymouth 100
echo -e "${blue}You will be asked for an selection. Please, choose \"kiosk.plymouth\" theme!${NC}\n"
sleep 5
sudo update-alternatives --config default.plymouth
sudo update-initramfs -u
sed -i -e 's/plymouth_theme_installed=0/plymouth_theme_installed=1/g' stages.cfg
echo -e "${green}Done!${NC}\n"
else
	echo -e "${blue}Loading theme already customized. Skipping...${NC}\n"
fi



# Set correct user and group permissions for /home/kiosk
echo -e "${red}Set correct user and group permissions for ${blue}/home/kiosk${red}...${NC}\n"
if [ "$kiosk_permissions" == 0 ]
then
sudo chown -R kiosk.kiosk /home/kiosk/
sed -i -e 's/kiosk_permissions=0/kiosk_permissions=1/g' stages.cfg
echo -e "${green}Done!${NC}\n"
else
	echo -e "${blue}Permissions already set. Skipping...${NC}\n"
fi



# Reconfigure Xorg
echo -e "${red}Reconfiguring ${blue}Xorg${red}...${NC}\n"
if [ "$reconfigure_xorg" == 0 ]
then
echo -e "${blue}You will be asked for an selection. Please, select \"Anybody\"!${NC}\n"
sleep 5
sudo dpkg-reconfigure x11-common
sudo sed -i -e 's/reconfigure_xorg=0/reconfigure_xorg=1/g' stages.cfg
echo -e "${green}Done!${NC}\n"
else
	echo -e "${blue}Xorg already reconfigured. Skipping...${NC}\n"
fi




# Disable desktop
echo -e "${red}Disabling ${blue}Desktop${red}...${NC}\n"
if [ "$disable_desktop" == 0 ]
then
sudo echo manual | tee /etc/init/lightdm.override 
sed -i -e 's/disable_desktop=0/disable_desktop=1/g' stages.cfg
echo -e "${green}Done!${NC}\n"
else
	echo -e "${blue}Desktop already disabled. Skipping...${NC}\n"
fi



#Choose kiosk mode
echo -e "${green}Choose Kiosk Mode:${NC}"
PS3="Type 1, 2 or 3:"
options=("Video mode" "Photo mode" "Browser mode")
select opt in "${options[@]}"
do
	case $opt in
		"Video mode")
			echo -e "${green}Configuring the kiosk in Video mode...${NC}"
			sudo sed -i -e 's/enable_videos="False"/enable_videos="True"/g' /home/kiosk/.kiosk/videos.cfg
			sudo sed -i -e 's/\\"enable_videos\\": false/\\"enable_videos\\": true/g' /etc/ajenti/config.json
			
			sudo sed -i -e 's/xscreensaver_enable="True"/xscreensaver_enable="False"/g' /home/kiosk/.kiosk/screensaver.cfg
			sudo sed -i -e 's/\\"xscreensaver_enable\\": true/\\"xscreensaver_enable\\": false/g' /etc/ajenti/config.json
			
			sudo sed -i -e 's/enable_browser="True"/enable_browser="False"/g' /home/kiosk/.kiosk/browser.cfg
			sudo sed -i -e 's/\\"enable_browser\\": true/\\"enable_browser\\": false/g' /etc/ajenti/config.json
			
			echo -e "${green}Done!${NC}\n"
			break
			;;
		"Photo mode")
			echo -e "${green}Configuring the kiosk in Photo mode...${NC}"
			sudo sed -i -e 's/xscreensaver_enable="False"/xscreensaver_enable="True"/g' /home/kiosk/.kiosk/screensaver.cfg
			sudo sed -i -e 's/\\"xscreensaver_enable\\": false/\\"xscreensaver_enable\\": true/g' /etc/ajenti/config.json
			
			sudo sed -i -e 's/enable_videos="True"/enable_videos="False"/g' /home/kiosk/.kiosk/videos.cfg
			sudo sed -i -e 's/\\"enable_videos\\": true/\\"enable_videos\\": false/g' /etc/ajenti/config.json
			
			sudo sed -i -e 's/enable_browser="True"/enable_browser="False"/g' /home/kiosk/.kiosk/browser.cfg
			sudo sed -i -e 's/\\"enable_browser\\": true/\\"enable_browser\\": false/g' /etc/ajenti/config.json
			
			echo -e "${green}Done!${NC}\n"
			break
			;;
		"Browser mode")
			echo -e "${green}Configuring the kiosk in Browser mode...${NC}"
			sudo sed -i -e 's/enable_browser="False"/enable_browser="True"/g' /home/kiosk/.kiosk/browser.cfg
			sudo sed -i -e 's/\\"enable_browser\\": false/\\"enable_browser\\": true/g' /etc/ajenti/config.json
			
			sudo sed -i -e 's/enable_videos="True"/enable_videos="False"/g' /home/kiosk/.kiosk/videos.cfg
			sudo sed -i -e 's/\\"enable_videos\\": true/\\"enable_videos\\": false/g' /etc/ajenti/config.json
			
			sudo sed -i -e 's/xscreensaver_enable="True"/xscreensaver_enable="False"/g' /home/kiosk/.kiosk/screensaver.cfg
			sudo sed -i -e 's/\\"xscreensaver_enable\\": true/\\"xscreensaver_enable\\": false/g' /etc/ajenti/config.json
			
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
    sudo sed -i "s/$old_hostname/$kiosk_name/g" /etc/hosts
else
    sudo echo -e "$( hostname -I | awk '{ print $1 }' )\t$kiosk_name" >> /etc/hosts
fi

sudo sed -i "s/$old_hostname/$kiosk_name/g" /etc/hostname
echo -e "${blue}Kiosk hostname set to: ${kiosk_name}${NC}"


echo -e "${green}Reboot?${NC}"
PS3="Type 1 or 2:"
options=("Yes" "No")
select opt in "${options[@]}"
do
        case $opt in
                Yes )
                        sudo reboot ;;
                No )
                        break ;;
        esac
done