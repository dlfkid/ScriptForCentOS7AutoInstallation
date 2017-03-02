#!/bin/sh
#./geniso.sh /home/iso/1.iso /home/iso/testiso_rw
genisoimage -v -cache-inodes -h -joliet-long -R -J -T -V 'CentOS 7 x86_64' -o $1 -c isolinux/boot.cat    -b isolinux/isolinux.bin  -no-emul-boot -boot-load-size 4 -boot-info-table  -eltorito-alt-boot     -b images/efiboot.img       -no-emul-boot $2
