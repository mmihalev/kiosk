#!/bin/bash

xrandr --orientation left

# Import variables
. /home/kiosk/.kiosk/screensaver.cfg
. /home/kiosk/.kiosk/browser.cfg
. /home/kiosk/.kiosk/videos.cfg


# Autorun screensaver on login
if [ $xscreensaver_enable = "True" ]
then
	# Look for new screensaver images
	rm .xscreensaver-getimage.cache

	# Write latest screensaver switches
	bash /home/kiosk/.kiosk/set_glslideshow_switches.sh

	# Read latest screensaver switches
	screensaver_switches=`cat /home/kiosk/.kiosk/glslideshow_switches.cfg`
	
	# Set screensaver timeout
	sed -i "/timeout:/c\timeout:	$xscreensaver_idle" /home/kiosk/.xscreensaver
	# Set glslideshow switches
	sed -i "/programs:/c\programs:	glslideshow -root $screensaver_switches" /home/kiosk/.xscreensaver
	xscreensaver -nosplash &
else
	xset -dpms # Disable DPMS (Energy Star) features
	xset s off # Disable screensaver
	openbox-session &
	start-pulseaudio-x11
fi

# Get screen resolution
#res=$(xrandr -q | awk -F'current' -F',' 'NR==1 {gsub("( |current)","");print $2}')

# Nuke it from orbit
#rm -r /home/kiosk/.opera
#mkdir /home/kiosk/.opera

# Write latest operaprefs.ini
#sh /home/kiosk/.kiosk/operaprefs.sh

# Avoid Opera Welcome screen
#touch -t 201401010001 /home/kiosk/.opera/operaprefs.ini

# Write latest toolbar
#sh /home/kiosk/.kiosk/toolbar/sanickiosk_toolbar_builder.sh

# Restore keyboard shortcuts
#mkdir /home/kiosk/.opera/keyboard
#cp /home/kiosk/.sanickiosk/sanickiosk_keyboard.ini /home/kiosk/.opera/keyboard/

# Write latest browser switches
#bash /home/kiosk/.sanickiosk/set_opera_switches.sh

# Read latest video switches
videos_switches=`cat /home/kiosk/.kiosk/videos_switches.cfg`

# Start browser killer
#sh /home/kiosk/.kiosk/browser_killer.sh &

# Start window manager
#matchbox-window-manager -use_titlebar no &

while true; do
	if [ $enable_browser = "True" ]
	then
		rm -rf ~/.{config,cache}/chromium/
	    chromium-browser --kiosk --no-first-run --disable-infobars --disable-session-crashed-bubble $home_url
	fi

	if [ $enable_videos = "True" ]
	then
		#export DISPLAY=:0
	    mplayer -volume $video_volume $videos_switches
	fi

	sleep 5s
done

