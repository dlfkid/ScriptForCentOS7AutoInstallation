# ScriptForCentOS7AutoInstallation
Scripts used in CentOS auto installation with kick start tech. Guides for CDRom / usb flash disk install.

CentOS7 is capable of auto install with a proper kickstart file.
You can get a ks file by manually install centos7 for once and find your own kickstart file in directory /root/anaconda-ks.cfg.

in ks file you can do something before the installation begin or after the installation is complete.

before:
%pre
#state any thing you wanna do with shell commands.
%end

after:
%post
#state any thing you wanna don with shell commands.
%end

when the ks file is ready, all you need is to tell the system where to find your ks:

in isolinux.cfg file, find the line as below:
label linux
  menu label ^Install CentOS 7
  kernel vmlinuz
  append initrd=initrd.img inst.stage2=hd:LABEL=CentOS\x207\x20x86_64 quiet
  
delete "quiet" and replace it with "inst.ks=cdrom:/isolinux/ks.cfg"

"cdrom:/" is the root directory of your iso image.

this only work for CDs, as for usb disk:

"cdrom:/" must be changed into "hd:sdx4:" x represent the mount point of your usb disk.

for example, if you got one harddisk in your pc, the mount point will be sdb4.
if you got two, it will be sdc4.

After there steps were done, you can simply run the geniso shell to make a iso image for auto install.

Burn the image into a cdrom or usb as you pleased.(Utraliso or powerISO are recommanded)
