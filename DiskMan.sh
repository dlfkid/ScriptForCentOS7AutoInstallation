#!/bin/sh
devname[0]="/dev/sdb"
devname[1]="/dev/sdc"
devname[2]="/dev/sdd"

mountdir[1]="/usr/donica/update"
mountdir[2]="/opt/lampp/htdocs/epg"
mountdir[3]="/opt/lampp/htdocs/files/program0"
mountdir[4]="/opt/lampp/htdocs/files/program1"

SdbKeyDir="/opt/lampp/htdocs/epg_key/"
SdbKey="/opt/lampp/htdocs/epg_key/sdb_key.dat"
Donica="/usr/donica/diskman/donica.dat"
Diskinfo="/usr/donica/conf/diskinfo.xml"
Version="/usr/donica/update/system/system_version_info.xml"
Vmware="/opt/lampp/htdocs/files/program0/vmware/meru-5.3.50/"
LOGFILE="/usr/donica/script/DiskMan.log"

X=0
Y=0

master_disk_num=0
slave_disk_num=1

if [ ! -d $SdbKeyDir ];then
	mkdir $SdbKeyDir
fi

cd /usr/donica/script
mv DiskMan.log DiskMan.log.last

nums=${#devname[*]}
#echo $nums

checkmount()
{
  num=`mount | grep "$1"|cut -d/ -f3|cut -d' ' -f1|wc -l`
  return $num
}

checkvmware()
{
	if [ ! -d Vmware ];then
		mount /dev/sdb3 /opt/lampp/htdocs/files/program0 >/dev/null 2>&1 
		mkdir -p $Vmware
	fi

}

checkversion()
{
	if [ ! -f "$Version" ]; then
		mkdir -p /usr/donica/update/system
		cp -rf /usr/donica/system_version_info.xml $Version >/dev/null 2>&1
		cp -rf /usr/donica/system_update.xml /usr/donica/update/ >/dev/null 2>&1
		cp -rf /usr/donica/system_update.xml /usr/donica/update/system/ >/dev/null 2>&1 
		chmod 777 /usr/donica/update/system/system_update.xml
		chmod 777 /usr/donica/update/system/system_version_info.xml
		chmod 777 /usr/donica/update/system_update.xml
	fi
}

updatecond()
{
	  if [ "$1" = "" ];then
  		return 1
  	fi
  	if [[ $1 -eq 1 ]];then
  		`sed -i "3s/.*/<updatecond>$2<\/updatecond>/" $Diskinfo` >/dev/null 2>&1
  	elif [[ $1 -eq 2 ]];then
  		`sed -i "4s/.*/<epgcond>$2<\/epgcond>/" $Diskinfo` >/dev/null 2>&1
  	elif [[ $1 -eq 3 ]];then
  		`sed -i "5s/.*/<program0cond>$2<\/program0cond>/" $Diskinfo` >/dev/null 2>&1
  	elif [[ $1 -eq 4 ]];then
  		`sed -i "6s/.*/<program1cond>$2<\/program1cond>/" $Diskinfo` >/dev/null 2>&1
  	else
  		set `date`
  		echo "["$2" "$3" "$4" "$6"]Wrong:update mount condition to diskinfo.xml failed!" >>$LOGFILE
  	fi
}

for ((i=0; i<nums; i++)); do
	if [ -b ${devname[i]}5 ]; then
		mount ${devname[i]}2 /opt/lampp/htdocs/epg_key >/dev/null 2>&1 
		mount ${devname[i]}5 /usr/donica/diskman >/dev/null 2>&1 

		if [ ! -f "$Donica" ]; then
			umount /opt/lampp/htdocs/epg_key >/dev/null 2>&1 

		elif [ ! -f "$SdbKey" ]; then
			umount /opt/lampp/htdocs/epg_key >/dev/null 2>&1 
			mount ${devname[i]}3 ${mountdir[4]} >/dev/null 2>&1 
			let X=$[$X+1]
			let Y=$[$Y+1]
			slave_disk_num=$i

		else	
			mount ${devname[i]}1 ${mountdir[1]} >/dev/null 2>&1 
			mount ${devname[i]}3 ${mountdir[3]} >/dev/null 2>&1 
			umount /opt/lampp/htdocs/epg_key >/dev/null 2>&1 
			mount ${devname[i]}2 ${mountdir[2]} >/dev/null 2>&1 
			let X=$[$X+1]
			master_disk_num=$i
		fi
		umount /usr/donica/diskman
	fi
done

echo -e "<diskinfo>\n<disknum>$X</disknum>\n<updatecond>0</updatecond>\n<epgcond>0</epgcond>\n<program0cond>0</program0cond>\n<program1cond>0</program1cond>\n</diskinfo>">$Diskinfo

if [[ $X -eq 2 ]];then
	if [[ $Y -eq 2 ]];then
		umount ${mountdir[4]} >/dev/null 2>&1 
		umount ${mountdir[4]} >/dev/null 2>&1 
		umount ${mountdir[4]} >/dev/null 2>&1 
		mount ${devname[0]}1 ${mountdir[1]} >/dev/null 2>&1 
		mount ${devname[0]}2 ${mountdir[2]} >/dev/null 2>&1 
		Ret=$?
		if [[ $Ret -eq 0 ]];then
			echo "#This is sdb disk!">/opt/lampp/htdocs/epg/sdb_key.dat
		fi
		mount ${devname[0]}3 ${mountdir[3]} >/dev/null 2>&1 
		mount ${devname[1]}3 ${mountdir[4]} >/dev/null 2>&1 
		master_disk_num=0
		slave_disk_num=1
	elif [[ $Y -eq 1 ]];then
		set `date`
		echo "["$2" "$3" "$4" "$6"] Right:A master disk and a slave disk exist!!" >>$LOGFILE
	elif [[ $Y -eq 0 ]];then
		umount ${mountdir[1]} >/dev/null 2>&1 
		umount ${mountdir[1]} >/dev/null 2>&1 
		umount ${mountdir[2]} >/dev/null 2>&1 
		umount ${mountdir[2]} >/dev/null 2>&1 
		umount ${mountdir[3]} >/dev/null 2>&1 
		umount ${mountdir[3]} >/dev/null 2>&1 
		mount ${devname[1]}2 /opt/lampp/htdocs/epg_key >/dev/null 2>&1 
		Ret=$?
		if [[ $Ret -eq 0 ]];then
			cd /opt/lampp/htdocs/epg_key
			rm -rf $SdbKey
		fi
		umount /opt/lampp/htdocs/epg_key >/dev/null 2>&1 
		
		mount ${devname[0]}1 ${mountdir[1]} >/dev/null 2>&1 
		mount ${devname[0]}2 ${mountdir[2]} >/dev/null 2>&1 
		mount ${devname[0]}3 ${mountdir[3]} >/dev/null 2>&1 
		mount ${devname[1]}3 ${mountdir[4]} >/dev/null 2>&1 
		master_disk_num=0
		slave_disk_num=1
	else
		set `date`
		echo "["$2" "$3" "$4" "$6"] Wrong:slave_disk_num=$Y is bigger than donica_disk_num=$X!!" >>$LOGFILE
	fi
		
	while [ 1 ]; do
		for ((j=1;j<4;j++));do
			checkmount ${devname[$master_disk_num]}$j
			master_result=$?
			if [[ $master_result -eq 0 ]];then
				set `date`
				echo "["$2" "$3" "$4" "$6"] ${devname[$master_disk_num]}$j not mounted,try again..."
				echo "["$2" "$3" "$4" "$6"] ${devname[$master_disk_num]}$j not mounted,try again..." >>$LOGFILE
				updatecond $j 0
				mount ${devname[$master_disk_num]}$j ${mountdir[$j]} >/dev/null 2>&1 
				checkmount ${devname[$master_disk_num]}$j
				master_result=$?
				if [[ $master_result -eq 0 ]];then
					set `date`
					echo "["$2" "$3" "$4" "$6"] Failed to remount ${devname[$master_disk_num]}$j on ${mountdir[$j]}..."
					echo "["$2" "$3" "$4" "$6"] Failed to remount ${devname[$master_disk_num]}$j on ${mountdir[$j]}..." >>$LOGFILE
					updatecond $j 0
				else
					set `date`
					echo "["$2" "$3" "$4" "$6"] Remount ${devname[$master_disk_num]}$j on ${mountdir[$j]} successfully..."
					echo "["$2" "$3" "$4" "$6"] Remount ${devname[$master_disk_num]}$j on ${mountdir[$j]} successfully..." >>$LOGFILE
					updatecond $j 1
				fi
			else
				echo "${devname[$master_disk_num]}$j is OK!"
				updatecond $j 1
				if [[ $j -eq 1 ]];then
					checkversion
				fi
				if [[ $j -eq 3 ]];then
					checkvmware 
				fi
			fi
		done
		checkmount ${devname[$slave_disk_num]}3
		slave_result=$?
		if [[ $slave_result -eq 0 ]];then
			set `date`
			echo "["$2" "$3" "$4" "$6"] ${devname[$slave_disk_num]}3 not mounted,try again..."
			echo "["$2" "$3" "$4" "$6"] ${devname[$slave_disk_num]}3 not mounted,try again..." >>$LOGFILE
			updatecond 4 0
			mount ${devname[$slave_disk_num]}3 ${mountdir[4]} >/dev/null 2>&1 
			checkmount ${devname[$slave_disk_num]}3
			slave_result=$?
			if [[ $slave_result -eq 0 ]];then
				set `date`
				echo "["$2" "$3" "$4" "$6"] Failed to remount ${devname[$slave_disk_num]}3 on ${mountdir[4]}..."
				echo "["$2" "$3" "$4" "$6"] Failed to remount ${devname[$slave_disk_num]}3 on ${mountdir[4]}..." >>$LOGFILE
				updatecond 4 0
			else
				set `date`
				echo "["$2" "$3" "$4" "$6"] Remount ${devname[$slave_disk_num]}3 on ${mountdir[4]} successfully..."
				echo "["$2" "$3" "$4" "$6"] Remount ${devname[$slave_disk_num]}3 on ${mountdir[4]} successfully..." >>$LOGFILE
				updatecond 4 1
			fi
		else
			updatecond 4 1
			echo "${devname[$slave_disk_num]}3 is OK!"
		fi
		echo "*************************"
		sleep 3
	done
elif [[ $X -eq 1 ]];then
	if [[ $Y -eq 1 ]];then
		umount ${mountdir[4]} >/dev/null 2>&1 
		umount ${mountdir[4]} >/dev/null 2>&1 
		mount ${devname[0]}1 ${mountdir[1]} >/dev/null 2>&1 
		mount ${devname[0]}2 ${mountdir[2]} >/dev/null 2>&1 
		Ret=$?
		if [[ $Ret -eq 0 ]];then
			echo "#This is sdb disk!">/opt/lampp/htdocs/epg/sdb_key.dat
		fi
		mount ${devname[0]}3 ${mountdir[3]} >/dev/null 2>&1 
		master_disk_num=0
	elif [[ $Y -eq 0 ]];then 
		master_disk_num=0
	else
		set `date`
		echo "["$2" "$3" "$4" "$6"] Wrong:slave_disk_num=$Y is bigger than donica_disk_num=$X!!" >>$LOGFILE
	fi
	while [ 1 ]; do
		for ((j=1;j<4;j++));do
			checkmount ${devname[$master_disk_num]}$j
			master_result=$?
			if [[ $master_result -eq 0 ]];then
				set `date`
				echo "["$2" "$3" "$4" "$6"] ${devname[$master_disk_num]}$j not mounted,try again..."
				echo "["$2" "$3" "$4" "$6"] ${devname[$master_disk_num]}$j not mounted,try again..." >>$LOGFILE
				updatecond $j 0
				mount ${devname[$master_disk_num]}$j ${mountdir[$j]} >/dev/null 2>&1 
				checkmount ${devname[$master_disk_num]}$j
				master_result=$?
				if [[ $master_result -eq 0 ]];then
					set `date`
					echo "["$2" "$3" "$4" "$6"] Failed to remount ${devname[$master_disk_num]}$j on ${mountdir[$j]}..."
					echo "["$2" "$3" "$4" "$6"] Failed to remount ${devname[$master_disk_num]}$j on ${mountdir[$j]}..." >>$LOGFILE
					updatecond $j 0
				else
					set `date`
					echo "["$2" "$3" "$4" "$6"] Remount ${devname[$master_disk_num]}$j on ${mountdir[$j]} successfully..."
					echo "["$2" "$3" "$4" "$6"] Remount ${devname[$master_disk_num]}$j on ${mountdir[$j]} successfully..." >>$LOGFILE
					updatecond $j 1
				fi
			else
				updatecond $j 1
				echo "${devname[$master_disk_num]}$j is OK!"
				if [[ $j -eq 1 ]];then
					checkversion
				fi
				if [[ $j -eq 3 ]];then
					checkvmware 
				fi
			fi
		done
		echo "*************************"
		sleep 3
	done
elif [[ $X -eq 0 ]];then
	set `date`
	echo "["$2" "$3" "$4" "$6"] There is no donica disk."
	echo "["$2" "$3" "$4" "$6"] There is no donica disk." >>$LOGFILE
else
	set `date`
	echo "["$2" "$3" "$4" "$6"] The number of the donica disks is wrong!"
	echo "["$2" "$3" "$4" "$6"] The number of the donica disks is wrong!" >>$LOGFILE
fi
