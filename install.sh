#!/bin/bash

# Define colors
red='\e[0;31m'
green='\e[1;32m'
blue='\e[1;36m'
NC='\e[0m' # No color

clear


# Determine Ubuntu Version Codename
VERSION=$(lsb_release -cs)

# Check if stages.cfg exists. If not, created it. 
if [ ! -f stages.cfg ]
then
echo 'grub_recovery_disable=0
admin_created=0
kiosk_created=0
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
disable_dekstop=0
reconfigure_xorg=0
kiosk_permissions=0' > stages.cfg
fi

# Import stages config
. stages.cfg



# Prevent sleeping for inactivity
echo -e "${red}Prevent sleeping for inactivity...${NC}\n"
if [ "$prevent_sleeping" == 0 ]
then
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop/etc/kbd/config -O /etc/kbd/config
sed -i -e 's/prevent_sleeping=0/prevent_sleeping=1/g' stages.cfg
echo -e "${green}Done!${NC}\n"
else
	echo -e "${blue}Prevent sleeping already done. Skipping...${NC}\n"
fi


echo -e "${red}Installing 3rd party software...${NC}\n"
if [ "$additional_software_installed" == 0 ]
then
apt-get -q=2 update
apt-get -q=2 install --no-install-recommends openbox pulseaudio mc ssh > /dev/null
sed -i -e 's/additional_software_installed=0/additional_software_installed=1/g' stages.cfg
echo -e "${green}Done!${NC}\n"
else
	echo -e "${blue}3rd party software already installed. Skipping...${NC}\n"
fi



echo -e "${red}Disabling root recovery mode...${NC}\n"
if [ "$grub_recovery_disable" == 0 ]
then
sed -i -e 's/#GRUB_DISABLE_RECOVERY/GRUB_DISABLE_RECOVERY/g' /etc/default/grub
sed -i -e 's/GRUB_DISTRIBUTOR=`lsb_release -i -s 2> \/dev\/null || echo Debian`/GRUB_DISTRIBUTOR=Kiosk/g' /etc/default/grub
sed -i -e 's/GRUB_TIMEOUT=10/GRUB_TIMEOUT=4/g' /etc/default/grub
update-grub
sed -i -e 's/grub_recovery_disable=0/grub_recovery_disable=1/g' stages.cfg
echo -e "\n${green}Done!${NC}\n"
else
	echo -e "${blue}Root recovery already disabled. Skipping...${NC}\n"
fi


echo -e "${red}Creating administrator user...${NC}\n"
if [ "$admin_created" == 0 ]
then
useradd administrator -m -d /home/administrator -p `openssl passwd -crypt ISdjE830` -s /bin/bash
sed -i -e 's/admin_created=0/admin_created=1/g' stages.cfg
echo -e "${green}Done!${NC}\n"
else
	echo -e "${blue}Administrator already created. Skipping...${NC}\n"
fi


echo -e "${red}Creating kiosk user...${NC}\n"
if [ "$kiosk_created" == 0 ]
then
useradd kiosk -m -d /home/kiosk -p `openssl passwd -crypt K10sk201` -s /bin/bash
usermod -a -G audio kiosk
sed -i -e 's/kiosk_created=0/kiosk_created=1/g' stages.cfg
echo -e "${green}Done!${NC}\n"
else
	echo -e "${blue}Kiosk already created. Skipping...${NC}\n"
fi



# Create .xscreensaver
echo -e "${red}Installing and configuring the screensaver...${NC}\n"
if [ "$screensaver_installed" == 0 ]
then
apt-get -q=2 install --no-install-recommends xscreensaver xscreensaver-data-extra xscreensaver-gl-extra libwww-perl > /dev/null
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop/home/kiosk/xscreensaver -O /home/kiosk/.xscreensaver
mkdir /home/kiosk/screensavers
sed -i -e 's/screensaver_installed=0/screensaver_installed=1/g' stages.cfg
echo -e "\n${green}Done!${NC}\n"
else
	echo -e "${blue}Screensaver already configured. Skipping...${NC}\n"
fi


# Install Chromium browser
echo -e "${red}Installing ${blue}Chromium${red} browser...${NC}\n"
if [ "$chromium_installed" == 0 ]
then
echo "
# Ubuntu Partners
deb http://archive.canonical.com/ $VERSION partner
"  >> /etc/apt/sources.list
apt-get -q=2 update
apt-get -q=2 -y install --force-yes chromium-browser > /dev/null
apt-get -q=2 install flashplugin-installer icedtea-7-plugin ttf-liberation > /dev/null # flash, java, and fonts
sed -i -e 's/chromium_installed=0/chromium_installed=1/g' stages.cfg
echo -e "\n${green}Done!${NC}\n"
else
	echo -e "${blue}Chromium already installed. Skipping...${NC}\n"
fi


# Kiosk scripts
echo -e "${red}Creating Kiosk Scripts...${NC}\n"
if [ "$kiosk_scripts" == 0 ]
then
mkdir /home/kiosk/.kiosk

# Create xsession
#wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop/home/kiosk/xsession -O /home/kiosk/.xsession

wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop/opt/kiosk.sh -O /home/kiosk/kiosk.sh
install -b -m 755 /home/kiosk/kiosk.sh /opt/kiosk.sh
rm -rf /home/kiosk/kiosk.sh

wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop/etc/init/kiosk.conf -O /home/kiosk/kiosk.conf
install -b -m 755 /home/kiosk/kiosk.conf /etc/init/kiosk.conf
rm -rf /home/kiosk/kiosk.conf

# Create other kiosk scripts
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop/home/kiosk/kiosk/browser.cfg -O /home/kiosk/.kiosk/browser.cfg
#wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop/home/kiosk/kiosk/browser_killer.sh -O /home/kiosk/.kiosk/browser_killer.sh
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop/home/kiosk/kiosk/browser_switches.cfg -O /home/kiosk/.kiosk/browser_switches.cfg
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop/home/kiosk/kiosk/glslideshow_switches.cfg -O /home/kiosk/.kiosk/glslideshow_switches.cfg
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop/home/kiosk/kiosk/screensaver.cfg -O /home/kiosk/.kiosk/screensaver.cfg
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop/home/kiosk/kiosk/set_glslideshow_switches.sh -O /home/kiosk/.kiosk/set_glslideshow_switches.sh
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop/home/kiosk/kiosk/videos.cfg -O /home/kiosk/.kiosk/videos.cfg
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop/home/kiosk/kiosk/videos_switches.cfg -O /home/kiosk/.kiosk/videos_switches.cfg



## Create browser killer
#apt-get -q=2 install --no-install-recommends xprintidle > /dev/null
#chmod +x /home/kiosk/.kiosk/browser_killer.sh
#sed -i -e 's/kiosk_scripts=0/kiosk_scripts=1/g' stages.cfg
#echo -e "${green}Done!${NC}\n"
#else
#	echo -e "${blue}Kiosk scripts already installed. Skipping...${NC}\n"
#fi


# Mplayer
echo -e "${red}Installing video player ${blue}mplayer${red}...${NC}\n"
if [ "$mplayer_installed" == 0 ]
then
apt-get -q=2 install mplayer > /dev/null
mkdir /home/kiosk/videos
sed -i -e 's/mplayer_installed=0/mplayer_installed=1/g' stages.cfg
echo -e "${green}Done!${NC}\n"
else
	echo -e "${blue}Mplayer already installed. Skipping...${NC}\n"
fi


# Kiosk Web Control (Ajenti)
echo -e "${red}Adding the browser-based system administration tool ${blue}Kiosk web control${red}...${NC}\n"
if [ "$ajenti_installed" == 0 ]
then
wget -q http://repo.ajenti.org/debian/key -O- | apt-key add -
echo '
## Ajenti
deb http://repo.ajenti.org/ng/debian main main ubuntu
'  >> /etc/apt/sources.list
apt-get -q=2 update && apt-get -q=2 install --no-install-recommends ajenti > /dev/null
service ajenti stop
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop/etc/ajenti/config.json -O /etc/ajenti/config.json

wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop/usr/share/pyshared/ajenti/plugins/dashboard/content/js/controls.dashboard.coffee -O /usr/share/pyshared/ajenti/plugins/dashboard/content/js/controls.dashboard.coffee
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop/usr/share/pyshared/ajenti/plugins/dashboard/content/js/controls.dashboard.coffee.c.js -O /usr/share/pyshared/ajenti/plugins/dashboard/content/js/controls.dashboard.coffee.c.js
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop/usr/share/pyshared/ajenti/plugins/dashboard/layout/dash.xml -O /usr/share/pyshared/ajenti/plugins/dashboard/layout/dash.xml
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop/usr/share/pyshared/ajenti/plugins/fm/__init__.py -O /usr/share/pyshared/ajenti/plugins/fm/__init__.py
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop/usr/share/pyshared/ajenti/plugins/fm/fm.py -O /usr/share/pyshared/ajenti/plugins/fm/fm.py
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop/usr/share/pyshared/ajenti/plugins/fm/layout/main.xml -O /usr/share/pyshared/ajenti/plugins/fm/layout/main.xml
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop/usr/share/pyshared/ajenti/plugins/main/content/js/controls.index.coffee -O /usr/share/pyshared/ajenti/plugins/main/content/js/controls.index.coffee
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop/usr/share/pyshared/ajenti/plugins/main/content/js/controls.index.coffee.c.js -O /usr/share/pyshared/ajenti/plugins/main/content/js/controls.index.coffee.c.js
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop/usr/share/pyshared/ajenti/plugins/main/content/static/auth.html -O /usr/share/pyshared/ajenti/plugins/main/content/static/auth.html
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop/usr/share/pyshared/ajenti/plugins/main/content/static/index.html -O /usr/share/pyshared/ajenti/plugins/main/content/static/index.html
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop/usr/share/pyshared/ajenti/plugins/power/layout/widget.xml -O /usr/share/pyshared/ajenti/plugins/power/layout/widget.xml
sed -i -e 's/ajenti_installed=0/ajenti_installed=1/g' stages.cfg
echo -e "\n${green}Done!${NC}\n"
else
	echo -e "${blue}Kiosk web control already installed. Skipping...${NC}\n"
fi



echo -e "${red}Adding Kiosk plugins to Kiosk web control...${NC}\n"
if [ "$ajenti_plugins_installed" == 0 ]
then
apt-get -q=2 install --no-install-recommends unzip > /dev/null
wget -q https://github.com/mmihalev/Ajenti-Plugins/archive/master.zip -O kiosk_plugins-master.zip
unzip -qq kiosk_plugins-master.zip
mv Ajenti-Plugins-master/* /var/lib/ajenti/plugins/
rm -rf Ajenti-Plugins-master
rm -rf /var/lib/ajenti/plugins/sanickiosk_*
sed -i -e 's/ajenti_plugins_installed=0/ajenti_plugins_installed=1/g' stages.cfg
echo -e "${green}Done!${NC}\n"
else
	echo -e "${blue}Kiosk plugins already installed. Skipping...${NC}\n"
fi


#NGINX
echo -e "${red}Installing ${blue}nginx${red} web server...${NC}\n"
if [ "$nginx_installed" == 0 ]
then
apt-get -q=2 install nginx > /dev/null
service nginx stop
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop/etc/nginx/sites-enabled/default -O /etc/nginx/sites-available/default
sed -i -e 's/www-data/kiosk/g' /etc/nginx/nginx.conf
mkdir /home/kiosk/html
chown -R kiosk.kiosk /home/kiosk/html
service nginx start
sed -i -e 's/nginx_installed=0/nginx_installed=1/g' stages.cfg
echo -e "\n${green}Done!${NC}\n"
else
	echo -e "${blue}Nginx already installed. Skipping...${NC}\n"
fi

#PHP
echo -e "${red}Installing ${blue}PHP${red}...${NC}\n"
if [ "$php_installed" == 0 ]
then
apt-get -q=2 install php5-cli php5-common php5-fpm php5-mysqlnd php5-mcrypt
update-rc.d php5-fpm defaults
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop/etc/php5/fpm/php.ini -O /etc/php5/fpm/php.ini
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop/etc/php5/fpm/pool.d/www.conf -O /etc/php5/fpm/pool.d/www.conf
service php5-fpm restart
sed -i -e 's/php_installed=0/php_installed=1/g' stages.cfg
echo -e "\n${green}Done!${NC}\n"
else
	echo -e "${blue}PHP already installed. Skipping...${NC}\n"
fi



# Website content
echo -e "${red}Downloading ${blue}Website content${red}...${NC}\n"
if [ "$website_downloaded" == 0 ]
then
wget -q https://dl.dropboxusercontent.com/u/47604729/kiosk_html.zip -O kiosk_html.zip
unzip -qq kiosk_html.zip
mv kiosk_html/* /home/kiosk/html/
chown -R kiosk.kiosk /home/kiosk/html/*
rm -rf kiosk_html*	
service nginx restart
service php5-fpm restart
sed -i -e 's/website_downloaded=0/website_downloaded=1/g' stages.cfg
echo -e "\n${green}Done!${NC}\n"
else
	echo -e "${blue}Website content already downloaded. Skipping...${NC}\n"
fi	



# Ubuntu loading theme
echo -e "${red}Customizing base theme...${NC}\n"
if [ "$plymouth_theme_installed" == 0 ]
then
mkdir /lib/plymouth/themes/kiosk
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop/lib/plymouth/themes/kiosk/dig.png -O /lib/plymouth/themes/kiosk/dig.png
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop/lib/plymouth/themes/kiosk/kiosk.plymouth -O /lib/plymouth/themes/kiosk/kiosk.plymouth
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop/lib/plymouth/themes/kiosk/kiosk.script -O /lib/plymouth/themes/kiosk/kiosk.script
#wget -q https://raw.githubusercontent.com/mmihalev/kiosk/ubuntu-desktop/usr/share/initramfs-tools/scripts/functions -O /usr/share/initramfs-tools/scripts/functions
update-alternatives --install /lib/plymouth/themes/default.plymouth default.plymouth /lib/plymouth/themes/kiosk/kiosk.plymouth 100
#update-alternatives --config default.plymouth
update-initramfs -u
sed -i -e 's/plymouth_theme_installed=0/plymouth_theme_installed=1/g' stages.cfg
echo -e "${green}Done!${NC}\n"
else
	echo -e "${blue}Base theme already installed. Skipping...${NC}\n"
fi



# Set correct user and group permissions for /home/kiosk
echo -e "${red}Set correct user and group permissions for ${blue}/home/kiosk${red}...${NC}\n"
if [ "$kiosk_permissions" == 0 ]
then
chown -R kiosk.kiosk /home/kiosk/
sed -i -e 's/kiosk_permissions=0/kiosk_permissions=1/g' stages.cfg
echo -e "${green}Done!${NC}\n"
else
	echo -e "${blue}Permissions already set. Skipping...${NC}\n"
fi



# Reconfigure Xorg
echo -e "${red}Reconfiguring ${blue}Xorg${red}...${NC}\n"
if [ "$reconfigure_xorg" == 0 ]
then
sed -i -e 's/allowed_users=console/allowed_users=anybody/g' /etc/X11/Xwrapper.config
sed -i -e 's/reconfigure_xorg=0/reconfigure_xorg=1/g' stages.cfg
echo -e "${green}Done!${NC}\n"
else
	echo -e "${blue}Xorg already reconfigured. Skipping...${NC}\n"
fi




# Disable desktop
echo -e "${red}Disabling ${blue}Desktop${red}...${NC}\n"
if [ "$disable_desktop" == 0 ]
then
echo manual | tee /etc/init/lightdm.override 
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


echo -e "${green}Reboot?${NC}"
select yn in "Yes" "No"; do
        case $yn in
                Yes )
                        reboot ;;
                No )
                        break ;;
        esac
done
