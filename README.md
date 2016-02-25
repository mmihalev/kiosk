# Ubuntu Kiosk
Turn Ubuntu Desktop into informational Kiosk.
Kiosk can be controlled via web interface using Ajenti. Ajenti custom plugins can be downloaded from https://github.com/mmihalev/Ajenti-Plugins

It can work in 3 different modes:
* Browser mode - Customized Chromium browser will be started at system startup (in full screen). Browser will be running into "kiosk" mode and startup page can be customized.
* Videos mode - Mplayer will be started at system startup. Player will play all videos from ~/Videos folder in full screen. 
* Photos mode - Slideshow of pictures from ~/Photos folder will be played ad full screen.

Keyboard and mouse will be locked and can be unlocked only with password.

# Installation

Step 1:
Install Ubuntu dekstop 14.04.02 (other versions may work but not tested)

Step 2:
Download installation script ``install.sh`` and run it ``./install.sh``

Please note that you must have an sudo privileges.
