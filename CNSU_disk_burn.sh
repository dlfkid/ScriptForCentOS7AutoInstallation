#!/bin/sh
#automatic external hard disk configuration

function help()
{
        name=`basename $1`
        echo -e "Usage:./${name} <sata device name> \nExample: ./${name} /dev/sdc"
}

CFDEVICE=$1
CURDIR=`pwd`
DONICA="donica.dat"
BOOT="sys_boot_bk"
ROOT="sys_root_bk"
GRUB="grub.conf"
VMWARE="vmware-ws-full-9.0.0-812388.i386.bundle"
AC="meru"
TMP=/mnt/disk_cfg

if [ "x${CFDEVICE}" = "x" ]; then
        help $0
        exit -1
fi


/bin/umount ${CFDEVICE}1
/bin/umount ${CFDEVICE}2
/bin/umount ${CFDEVICE}3
/bin/umount ${CFDEVICE}5
/bin/umount ${CFDEVICE}6
/bin/umount ${CFDEVICE}7
/bin/umount ${CFDEVICE}8


echo -e "\033[33;35m >>>>>start partition<<<<< \033[0m"

/sbin/fdisk $CFDEVICE <<EOF

d
1

d
2

d
3

d
4

n
p
1

7298

n
p
2

12288

n
e
4

55296

n
p



n


20480

n


28672

n


36864

n



t
7
82

w
EOF

echo -e "\033[33;35m >>>>>Start format partition<<<<< \033[0m"
sleep 5
echo -e "\033[33;35m >>>>>start format ${CFDEVICE}1... \033[0m"
/sbin/mkfs -t xfs ${CFDEVICE}1
tune2fs -c -1 ${CFDEVICE}1
sleep 5
echo -e "\033[33;35m >>>>>start format ${CFDEVICE}2... \033[0m"
/sbin/mkfs -t xfs ${CFDEVICE}2
tune2fs -c -1 ${CFDEVICE}2
sleep 5
echo -e "\033[33;35m >>>>>start format ${CFDEVICE}3... \033[0m"
/sbin/mkfs -t xfs ${CFDEVICE}3
tune2fs -c -1 ${CFDEVICE}3
sleep 5
echo -e "\033[33;35m >>>>>start format ${CFDEVICE}5... \033[0m"
/sbin/mkfs -t xfs ${CFDEVICE}5
tune2fs -c -1 ${CFDEVICE}5
sleep 5
echo -e "\033[33;35m >>>>>start format ${CFDEVICE}6... \033[0m"
/sbin/mkfs -t xfs ${CFDEVICE}6
tune2fs -c -1 ${CFDEVICE}6
sleep 5
echo -e "\033[33;35m >>>>>start format ${CFDEVICE}8... \033[0m"
/sbin/mkfs -t xfs ${CFDEVICE}8
tune2fs -c -1 ${CFDEVICE}8
sleep 5

echo -e "\033[33;35m >>>>>Start copy files<<<<< \033[0m"
/bin/mkdir -p $TMP

#chmod 777 $CURDIR/$DONICA
chmod 777 $CURDIR/$GRUB

mount ${CFDEVICE}5 $TMP

echo -e "\033[33;35m >>>>>write donica.dat to ${CFDEVICE}5... \033[0m"
echo "#DONICA DISK" > $TMP/$DONICA
#echo -e "\033[33;35m >>>>>copy grub.conf to /boot/grub... \033[0m"
#/bin/cp -f $CURDIR/$GRUB /boot/grub/

sync

cd $CURDIR
/bin/umount $TMP

echo -e "\033[33;35m >>>>>copy Vmware&AC to ${CFDEVICE}1... \033[0m"
mount ${CFDEVICE}1 $TMP
mkdir -p $TMP/vmware

/bin/cp -f $VMWARE $TMP/vmware
/bin/cp -rf $AC $TMP/vmware
/bin/cp -rf $AC $TMP/vmware/meru_donica
umount $TMP

echo -e "\033[33;35m >>>>>Start write back-up system into hard disk<<<<< \033[0m"

chmod 777 $CURDIR/$BOOT
chmod 777 $CURDIR/$ROOT

echo -e "\033[33;35m >>>>>write boot into ${CFDEVICE}6... \033[0m"
/bin/dd if=$CURDIR/${BOOT} of=${CFDEVICE}6 bs=1K
#chmod 777 ${CFDEVICE}6
sleep 5
echo -e "\033[33;35m >>>>>write root into ${CFDEVICE}8... \033[0m"
/bin/dd if=$CURDIR/${ROOT} of=${CFDEVICE}8 bs=1K
#chmod 777 ${CFDEVICE}8

echo -e "\033[33;35m >>>>>Write back-up system is done<<<<< \033[0m"

mkswap ${CFDEVICE}7
rm -r $TMP

echo -e "\033[33;35m >>>>>Extra hard disk configuration is done<<<<< \033[0m"

