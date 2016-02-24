#!/bin/bash

# Define colors
red='\e[0;31m'
green='\e[1;32m'
blue='\e[1;36m'
NC='\e[0m' # No color


# Check if we have root permissions
#if [ "$(id -u)" != "0" ]; then
#	echo -e "${red}Please, run installation with root privileges (e.g.: sudo ./install.sh)${NC}"
#	exit 1
#fi

clear


# Determine Ubuntu Version Codename
VERSION=$(lsb_release -cs)

# Check if stages.cfg exists. If not, created it. 
if [ ! -f stages.cfg ]
then
echo 'grub_recovery_disable=0
updates_disabled=0
appport_disabled=0
guest_disabled=0
top_panel_removed=0
desktop_txt_changed=0
desktop_personalized=0
keyboard_locked=0
chromium_installed=0
kiosk_scripts=0
ajenti_installed=0
ajenti_plugins_installed=0
nginx_installed=0
php_installed=0
website_downloaded=0
additional_software_installed=0
plymouth_theme_installed=0
kiosk_mode=0
hostname_set=0
kiosk_permissions=0' > stages.cfg
fi

# Import stages config
. stages.cfg


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



echo -e "${red}Installing 3rd party software...${NC}\n"
if [ "$additional_software_installed" == 0 ]
then
sudo apt-get -q=2 update
sudo apt-get -q=2 install mplayer lm-sensors mc htop ssh build-essential gcc libx11-dev unclutter feh > /dev/null
sed -i -e 's/additional_software_installed=0/additional_software_installed=1/g' stages.cfg
echo -e "${green}Done!${NC}\n"
else
	echo -e "${blue}3rd party software already installed. Skipping...${NC}\n"
fi



echo -e "${red}Disabling automatic updates...${NC}\n"
if [ "$updates_disabled" == 0 ]
then
sudo wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop-v2/etc/apt/apt.conf.d/10periodic -O /etc/apt/apt.conf.d/10periodic
sed -i -e 's/updates_disabled=0/updates_disabled=1/g' stages.cfg
echo -e "${green}Done!${NC}\n"
else
	echo -e "${blue}Automatic updates already disabled. Skipping...${NC}\n"
fi



echo -e "${red}Disabling appport...${NC}\n"
if [ "$appport_disabled" == 0 ]
then
sudo sed -i -e 's/enabled=1/enabled=0/g' /etc/default/apport
sed -i -e 's/appport_disabled=0/appport_disabled=1/g' stages.cfg
echo -e "${green}Done!${NC}\n"
else
	echo -e "${blue}Appport already disabled. Skipping...${NC}\n"
fi


echo -e "${red}Disabling guest user...${NC}\n"
if [ "$guest_disabled" == 0 ]
then
sudo wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop-v2/etc/lightdm/lightdm.conf -O /etc/lightdm/lightdm.conf
sed -i -e 's/guest_disabled=0/guest_disabled=1/g' stages.cfg
echo -e "${green}Done!${NC}\n"
else
	echo -e "${blue}Guest user already disabled. Skipping...${NC}\n"
fi



echo -e "${red}Removing top panel...${NC}\n"
if [ "$top_panel_removed" == 0 ]
then
sudo mv /usr/lib/unity/unity-panel-service /usr/lib/unity/unity-panel-service_org
sudo touch /usr/lib/unity/unity-panel-service
sudo chmod +x /usr/lib/unity/unity-panel-service
sed -i -e 's/top_panel_removed=0/top_panel_removed=1/g' stages.cfg
echo -e "${green}Done!${NC}\n"
else
	echo -e "${blue}Top panel already removed. Skipping...${NC}\n"
fi



echo -e "${red}Changing \"Ubuntu Dekstop\" text to \"Kiosk\"...${NC}\n"
if [ "$desktop_txt_changed" == 0 ]
then
echo '
msgid "Ubuntu Desktop"
msgstr "Kiosk"
' > /tmp/foo.po
sudo msgfmt -o /usr/share/locale/en/LC_MESSAGES/unity.mo /tmp/foo.po
sudo rm -rf /tmp/foo.po
sed -i -e 's/desktop_txt_changed=0/desktop_txt_changed=1/g' stages.cfg
echo -e "${green}Done!${NC}\n"
else
	echo -e "${blue}\"Ubuntu Desktop\" text already changed. Skipping...${NC}\n"
fi



echo -e "${red}Personalizing the desktop...${NC}\n"
if [ "$desktop_personalized" == 0 ]
then
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop-v2/home/kiosk/Pictures/desktop-logo.jpg -O /home/kiosk/Pictures/desktop-logo.jpg
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop-v2/home/kiosk/config/dconf/user -O /home/kiosk/.config/dconf/user
#export DISPLAY=:0
#dconf load / < /home/kiosk/.config/dconf/user_tmp
sed -i -e 's/desktop_personalized=0/desktop_personalized=1/g' stages.cfg
echo -e "${green}Done!${NC}\n"
else
	echo -e "${blue}Desktop already personalized. Skipping...${NC}\n"
fi



echo -e "${red}Installing mouse and keyboard locking mechanism...${NC}\n"
if [ "$keyboard_locked" == 0 ]
then
sudo wget -q https://github.com/mmihalev/Better-XTrLock/archive/master.zip -O /tmp/master.zip
sudo unzip /tmp/master.zip -d /tmp
sudo make -C /tmp/Better-XTrLock-master/.
sudo make install -C /tmp/Better-XTrLock-master/
sed -i -e 's/keyboard_locked=0/keyboard_locked=1/g' stages.cfg
echo -e "${green}Done!${NC}\n"
else
	echo -e "${blue}Mouse and keyboard locking already installed. Skipping...${NC}\n"
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
echo -e "${red}Installing Kiosk Scripts...${NC}\n"
if [ "$kiosk_scripts" == 0 ]
then
mkdir /home/kiosk/.config/autostart
mkdir /home/kiosk/.kiosk/
mkdir /home/kiosk/Photos/
sudo wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop-v2/home/kiosk/config/autostart/0-unclutter.desktop -O /home/kiosk/.config/autostart/0-unclutter.desktop
sudo wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop-v2/home/kiosk/config/autostart/1-xtrlock.desktop -O /home/kiosk/.config/autostart/1-xtrlock.desktop
sudo wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop-v2/home/kiosk/config/autostart/2-videos.desktop -O /home/kiosk/.config/autostart/2-videos.desktop
sudo wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop-v2/home/kiosk/config/autostart/2-photos.desktop -O /home/kiosk/.config/autostart/2-photos.desktop
sudo wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop-v2/home/kiosk/config/autostart/2-browser.desktop -O /home/kiosk/.config/autostart/2-browser.desktop
sudo wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop-v2/home/kiosk/kiosk/videos.sh -O /home/kiosk/.kiosk/videos.sh
sed -i -e 's/kiosk_scripts=0/kiosk_scripts=1/g' stages.cfg
echo -e "${green}Done!${NC}\n"
else
	echo -e "${blue}Kiosk scripts already installed. Skipping...${NC}\n"
fi




# Kiosk Web Control (Ajenti)
echo -e "${red}Adding the browser-based system administration tool ${blue}Kiosk web control${red}...${NC}\n"
if [ "$ajenti_installed" == 0 ]
then
wget -qO - http://repo.ajenti.org/debian/key | sudo apt-key add -
echo '
## Ajenti
deb http://repo.ajenti.org/ng/debian main main ubuntu
' | sudo tee -a /etc/apt/sources.list > /dev/null
sudo apt-get -q=2 update 
sudo apt-get -q=2 install --no-install-recommends ajenti > /dev/null
sudo service ajenti stop
sudo wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop-v2/etc/ajenti/config.json -O /etc/ajenti/config.json
sudo wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop-v2/usr/share/pyshared/ajenti/plugins/dashboard/content/js/controls.dashboard.coffee -O /usr/share/pyshared/ajenti/plugins/dashboard/content/js/controls.dashboard.coffee
sudo wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop-v2/usr/share/pyshared/ajenti/plugins/dashboard/content/js/controls.dashboard.coffee.c.js -O /usr/share/pyshared/ajenti/plugins/dashboard/content/js/controls.dashboard.coffee.c.js
sudo wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop-v2/usr/share/pyshared/ajenti/plugins/dashboard/layout/dash.xml -O /usr/share/pyshared/ajenti/plugins/dashboard/layout/dash.xml
sudo wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop-v2/usr/share/pyshared/ajenti/plugins/fm/__init__.py -O /usr/share/pyshared/ajenti/plugins/fm/__init__.py
sudo wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop-v2/usr/share/pyshared/ajenti/plugins/fm/fm.py -O /usr/share/pyshared/ajenti/plugins/fm/fm.py
sudo wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop-v2/usr/share/pyshared/ajenti/plugins/fm/layout/main.xml -O /usr/share/pyshared/ajenti/plugins/fm/layout/main.xml
sudo wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop-v2/usr/share/pyshared/ajenti/plugins/main/content/js/controls.index.coffee -O /usr/share/pyshared/ajenti/plugins/main/content/js/controls.index.coffee
sudo wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop-v2/usr/share/pyshared/ajenti/plugins/main/content/js/controls.index.coffee.c.js -O /usr/share/pyshared/ajenti/plugins/main/content/js/controls.index.coffee.c.js
sudo wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop-v2/usr/share/pyshared/ajenti/plugins/main/content/static/auth.html -O /usr/share/pyshared/ajenti/plugins/main/content/static/auth.html
sudo wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop-v2/usr/share/pyshared/ajenti/plugins/main/content/static/index.html -O /usr/share/pyshared/ajenti/plugins/main/content/static/index.html
sudo wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop-v2/usr/share/pyshared/ajenti/plugins/power/layout/widget.xml -O /usr/share/pyshared/ajenti/plugins/power/layout/widget.xml
sudo rm -rf key
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
sudo wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop-v2/etc/nginx/sites-enabled/default -O /etc/nginx/sites-available/default
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
sudo apt-get -q=2 install php5-cli php5-fpm php5-geoip php5-imagick php5-imap php5-intl php5-mcrypt php5-memcache php5-memcached php5-mysqlnd php-net-smtp php-net-socket php-net-url php-net-url2 php-net-imap php-net-ftp php-mdb2-driver-mysql > /dev/null
sudo update-rc.d php5-fpm defaults
sudo wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop-v2/etc/php5/fpm/php.ini -O /etc/php5/fpm/php.ini
sudo wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop-v2/etc/php5/fpm/pool.d/www.conf -O /etc/php5/fpm/pool.d/www.conf
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
sudo wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop-v2/lib/plymouth/themes/kiosk/dig.png -O /lib/plymouth/themes/kiosk/dig.png
sudo wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop-v2/lib/plymouth/themes/kiosk/kiosk.plymouth -O /lib/plymouth/themes/kiosk/kiosk.plymouth
sudo wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop-v2/lib/plymouth/themes/kiosk/kiosk.script -O /lib/plymouth/themes/kiosk/kiosk.script
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




echo -e "${green}Choose Kiosk Mode:${NC}"
if [ "$kiosk_mode" == 0 ]
then
PS3="Type 1, 2 or 3:"
options=("Video mode" "Photo mode" "Browser mode")
select opt in "${options[@]}"
do
	case $opt in
		"Video mode")
			echo -e "${green}Configuring the kiosk in Video mode...${NC}"
			sudo sed -i -e 's/X-GNOME-Autostart-enabled=false/X-GNOME-Autostart-enabled=true/g' /home/kiosk/.config/autostart/2-videos.desktop
			sudo sed -i -e 's/\\"enable_videos\\": false/\\"enable_videos\\": true/g' /etc/ajenti/config.json
			
			sudo sed -i -e 's/X-GNOME-Autostart-enabled=true/X-GNOME-Autostart-enabled=false/g' /home/kiosk/.config/autostart/2-photos.desktop
			sudo sed -i -e 's/\\"photos_enable\\": true/\\"photos_enable\\": false/g' /etc/ajenti/config.json
			
			sudo sed -i -e 's/X-GNOME-Autostart-enabled=true/X-GNOME-Autostart-enabled=false/g' /home/kiosk/.config/autostart/2-browser.desktop
			sudo sed -i -e 's/\\"enable_browser\\": true/\\"enable_browser\\": false/g' /etc/ajenti/config.json
			
			echo -e "${green}Done!${NC}\n"
			break
			;;
		"Photo mode")
			echo -e "${green}Configuring the kiosk in Photo mode...${NC}"
			sudo sed -i -e 's/X-GNOME-Autostart-enabled=false/X-GNOME-Autostart-enabled=true/g' /home/kiosk/.config/autostart/2-photos.desktop
			sudo sed -i -e 's/\\"photos_enable\\": false/\\"photos_enable\\": true/g' /etc/ajenti/config.json
			
			sudo sed -i -e 's/X-GNOME-Autostart-enabled=true/X-GNOME-Autostart-enabled=false/g' /home/kiosk/.config/autostart/2-videos.desktop
			sudo sed -i -e 's/\\"enable_videos\\": true/\\"enable_videos\\": false/g' /etc/ajenti/config.json
			
			sudo sed -i -e 's/X-GNOME-Autostart-enabled=true/X-GNOME-Autostart-enabled=false/g' /home/kiosk/.config/autostart/2-browser.desktop
			sudo sed -i -e 's/\\"enable_browser\\": true/\\"enable_browser\\": false/g' /etc/ajenti/config.json
			
			echo -e "${green}Done!${NC}\n"
			break
			;;
		"Browser mode")
			echo -e "${green}Configuring the kiosk in Browser mode...${NC}"
			sudo sed -i -e 's/X-GNOME-Autostart-enabled=false/X-GNOME-Autostart-enabled=true/g' /home/kiosk/.config/autostart/2-browser.desktop
			sudo sed -i -e 's/\\"enable_browser\\": false/\\"enable_browser\\": true/g' /etc/ajenti/config.json
			
			sudo sed -i -e 's/X-GNOME-Autostart-enabled=true/X-GNOME-Autostart-enabled=false/g' /home/kiosk/.config/autostart/2-videos.desktop
			sudo sed -i -e 's/\\"enable_videos\\": true/\\"enable_videos\\": false/g' /etc/ajenti/config.json
			
			sudo sed -i -e 's/X-GNOME-Autostart-enabled=true/X-GNOME-Autostart-enabled=false/g' /home/kiosk/.config/autostart/2-photos.desktop
			sudo sed -i -e 's/\\"photos_enable\\": true/\\"photos_enable\\": false/g' /etc/ajenti/config.json
			
			echo -e "${green}Done!${NC}\n"
			break
			;;
		*) echo -e "${red}Invalid Option. Please, choose 1, 2 or 3${NC}";;
	esac
done
sed -i -e 's/kiosk_mode=0/kiosk_mode=1/g' stages.cfg
else
	echo -e "${blue}Kiosk mode already set. Skipping...${NC}\n"
fi




echo -e "${green}Kiosk name...${NC}"
if [ "$hostname_set" == 0 ]
then
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
sed -i -e 's/hostname_set=0/hostname_set=1/g' stages.cfg
echo -e "${blue}Kiosk hostname set to: ${kiosk_name}${NC}"
else
	echo -e "${blue}Kiosk name already set. Skipping...${NC}\n"
fi


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