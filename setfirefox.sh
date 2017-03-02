#!/bin/bash

#####set copy mode
alias 'cp=cp -i'

######setFireFox
#set home page
/bin/cp /root/source/fireFoxSet/all-redhat.js /usr/lib64/firefox/browser/defaults/preferences
#set full screen add-on
cd /root/.mozilla/firefox/*default/
mkdir extensions
/bin/cp -rf /root/source/pkts/fullScreen/* /root/.mozilla/firefox/*default/extensions
#set auto start
mkdir /root/.config/autostart
/bin/cp /root/source/fireFoxSet/firefox.desktop /root/.config/autostart/
