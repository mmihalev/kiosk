
#!/bin/bash

# Import variables
. /home/kiosk/.kiosk/screensaver.cfg

switches=""
for option in glslideshow_duration glslideshow_pan glslideshow_fade glslideshow_zoom glslideshow_clip ; do
	value=${!option}
	delete="glslideshow_"
	option=${option#${delete}}
	if [ $option != "clip" ]
	then
		if [ -n "$value" ]
		then
			switches=$switches" -"$option" "$value
		fi
	else
		if [ $value="True" ]
		then
			switches=$switches" -clip"
		else
			switches=$switches" -letterbox"
		fi
	fi
done

echo $switches > /home/kiosk/.kiosk/glslideshow_switches.cfg

