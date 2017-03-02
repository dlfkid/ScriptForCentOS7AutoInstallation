#!/bin/bash
###############################################################################################
# Function: 
#         Auto install system application and configuration for CNSU.
# History: 
#         2017/2/21  PanGang  --First release V1.0
# Note:
#         base config for wifi-6000.
#  
###############################################################################################

#### alias command
shopt -s expand_aliases
alias echo='/bin/echo -e'
alias echo_n='/bin/echo -n'
alias mysql='/opt/lampp/bin/mysql'
alias log='echo " done.">&6 || (echo " faild:">&6; err_info)'
KERNEL_VERSION=`cat /proc/version | grep version | awk 'NR==1{print $3}' | awk -F- 'NR==1{print $1}' | awk -F. '{$NF="";OFS=".";print $0"x"}'`
case "$KERNEL_VERSION" in # CentOS7.2_x64
    3.10.x)
      alias cp='/usr/bin/cp -rf'
      alias rm='/usr/bin/rm -rf'
      alias mv='/usr/bin/mv'
      alias mkdir='/usr/bin/mkdir -p'
      alias systemctl='/usr/bin/systemctl'
      ;;

    *)                    # CentOS5.8_x32
      alias cp='/bin/cp -rf'
      alias rm='/bin/rm -rf'
      alias mv='/bin/mv'
      alias mkdir='/bin/mkdir -p'
      alias chkconfig='/sbin/chkconfig'
      alias service='/sbin/service'
      ;;
esac

#### set logfile variable and environment 
DATETIME=`date +%Y%m%d\%H%M%S`
TIME=`date +[%H:%M:%S] `
LOG_DIR="/root/source/"
LOG_FILE="install_$DATETIME.log"
FILE_LOG="$LOG_DIR$LOG_FILE"
LAMPP_SOURCE_DIR="/root/source/server/app/lampp"
mkdir $LOG_DIR
exec 6> $FILE_LOG

#### creat FIFO for std err cache
tmp_fifofile="/tmp/$$.fifo"
rm $tmp_fifofile 2>/dev/null
mkfifo $tmp_fifofile
exec 5<> $tmp_fifofile
###############################################################################################
# get std error from FIFO 
###############################################################################################
function err_info(){
  echo "__EOF__" >&5 # prevent blocking
  while :  
  do
    ERROR_LINE=""  
    read -u 5 -t 1 ERROR_LINE  
    if [ "$ERROR_LINE" != "__EOF__" ]; then
      echo "$ERROR_LINE" >&6
    else
      break
    fi
  done  
}

###############################################################################################
# Present Title
###############################################################################################
echo ">>>>>>>>>>INSTALLATION & ENVIREMENT SETUP CONFIGURATION LOGS<<<<<<<<<<"		            >&6
echo "VERSION:$OS_NAME"																                                      >&6
echo "Date:`date +%F`"																                                      >&6
echo "Time:`date +%0H:%0M:%0S`"														                                  >&6
echo ">>>>>>>>>>START<<<<<<<<<<"													                                  >&6

###############################################################################################
# set SELinux to Permissive mode
###############################################################################################
echo "\n$DATETIME(line:$LINENO)(line:$LINENO) set SELinux to Permissive mode..."	          >&6
setenforce 0 																		1>/dev/null 2>&5 && log

###############################################################################################
# stop firewall
###############################################################################################
echo "\n$DATETIME(line:$LINENO)(line:$LINENO) stop firewall..." 					                  >&6
systemctl stop firewalld.service                                                              1>/dev/null 2>&5 && log


###############################################################################################
# modify system configuration
###############################################################################################
echo "\n$DATETIME(line:$LINENO)(line:$LINENO) modify system configuration"			            >&6
mkdir  /opt/lampp/htdocs/epg                                                        
mkdir  /opt/lampp/htdocs/epg_key                                                    
mkdir  /opt/lampp/htdocs/files/program0                                             
mkdir  /opt/lampp/htdocs/files/program1
mkdir  /usr/donica/diskman
cp /root/source/etc/rc.local /etc/rc.d/                                                   1>/dev/null 2>&5 && log
/bin/chmod +x /etc/rc.d/rc.local                                                               1>/dev/null 2>&5 && log
cp /root/source/etc/ifcfg-eth1 /etc/sysconfig/network-scripts/                            1>/dev/null 2>&5 && log
cp /root/source/etc/sysctl.conf /etc/                                                     1>/dev/null 2>&5 && log
cp  /root/source/etc/inittab /etc                                                         1>/dev/null 2>&5 && log
cp /root/source/etc/custom.conf /etc/gdm/                                                 1>/dev/null 2>&5 && log
###############################################################################################################################cp /root/source/server/grub.conf /boot/grub/grub.conf 							                       1>/dev/null 2>&5 && log
cp /root/source/server/server_path.conf /home/ 								                           1>/dev/null 2>&5 && log
cp /root/source/server/system_update.xml /usr/donica/ 					                           1>/dev/null 2>&5 && log
cp /root/source/server/system_version_info.xml /usr/donica/ 				                       1>/dev/null 2>&5 && log
rm -rf /etc/sysconfig/network-scripts/ifcfg-eth0                                               1>/dev/null 2>&5 && log

 
###############################################################################################
# install lampp
###############################################################################################
 echo "\n$DATE(line:$LINENO) install lampp"                                                 >&6
 #tar xvfz /root/source/pkts/lampp/lampp.tar.gz -C /opt                              1>/dev/null 2>&5 && log
tar xzf $LAMPP_SOURCE_DIR/xampp-linux-5.6.24.tar.gz -C /opt                               1>/dev/null 2>&5 && log
 /opt/lampp/lampp restart                                                           1>/dev/null 2>&5 && log
###############################################################################################
# configure lampp
###############################################################################################
echo "\n$DATE(line:$LINENO) Congfigure lampp"									                              >&6
/opt/lampp/bin/mysql -f -u root < $LAMPP_SOURCE_DIR/sql/DB_USER_CREATE.sql 			1>/dev/null 2>&5 && log
/opt/lampp/bin/mysql -f -u hhwifi -pdonica2012 < $LAMPP_SOURCE_DIR/sql/privileges.sql  1>/dev/null 2>&5 && log
/opt/lampp/bin/mysql -f -u hhwifi -pdonica2012 < $LAMPP_SOURCE_DIR/sql/cmt/cmt_init.sql 1>/dev/null 2>&5 && log
/opt/lampp/bin/mysql -f -u hhwifi -pdonica2012 < $LAMPP_SOURCE_DIR/sql/cmt/init.sql    1>/dev/null 2>&5 && log
/opt/lampp/bin/mysql -f -u hhwifi -pdonica2012 < $LAMPP_SOURCE_DIR/sql/epg/epg_init.sql 1>/dev/null 2>&5 && log
/opt/lampp/bin/mysql -f -u hhwifi -pdonica2012 < $LAMPP_SOURCE_DIR/sql/epg/init.sql 1>/dev/null 2>&5 && log
/opt/lampp/bin/mysql -f -u hhwifi -pdonica2012 --default-character-set=utf8 epg < $LAMPP_SOURCE_DIR/sql/3g_data.sql 1>/dev/null 2>&5 && log

###############################################################################################
# modify ftp default password for improve system security
###############################################################################################
echo "\n$DATE(line:$LINENO) modify ftp default password for improve system security"        >&6
f="/opt/lampp/etc/proftpd.conf"
word=`/opt/lampp/share/lampp/crypt "$1"`
awk -vpw="$word" '
/^UserPassword nobody *+/ {
                print "#"$0
                print "UserPassword nobody "pw
                next
        }
        {
                print
        }
' $f > /tmp/lampp$$
  cp /tmp/lampp$$ $f 
  rm /tmp/lampp$$ 
  /opt/lampp/lampp reloadftp 1>/dev/null 2>&5 && log

###############################################################################################
# configure samba
###############################################################################################
echo "\n$DATE(line:$LINENO)install samba"                                                   >&6
 cp /root/source/pkts/samba/smb.conf /etc/samba                                1>/dev/null 2>&5 && log
 mkdir /var/samba/share
 chown -R nobody. /var/samba/share                                                  1>/dev/null 2>&5 && log
 chmod 777 /var/samba/share                                                         1>/dev/null 2>&5 && log
 cd /var/samba/share                                                                1>/dev/null 2>&5 && log
 ln -s /root root                                                                   1>/dev/null 2>&5 && log
 ln -s /usr/donica donica                                                           1>/dev/null 2>&5 && log
 ln -s /opt/lampp/ lampp                                                            1>/dev/null 2>&5 && log
 cd /var/samba/share                                                                1>/dev/null 2>&5 && log
 chmod 777 root -Rf                                                                 1>/dev/null 2>&5 && log
 chmod 777 donica -Rf                                                               1>/dev/null 2>&5 && log

###############################################################################################
# configure nfs
###############################################################################################
echo "\n$DATETIME(line:$LINENO) configure nfs" 										                          >&6
 cp /root/source/etc/exports /etc/                                             1>/dev/null 2>&5 && log
 service nfs restart                                                                1>/dev/null 2>&5 && log

###############################################################################################
# install proftpd
###############################################################################################
echo "\n$DATETIME(line:$LINENO) install proftpd" 								                            >&6
 useradd root                                                                       1>/dev/null 2>&5 && log
 echo donica_wifi | passwd root --stdin                                             1>/dev/null 2>&5 && log
 useradd update                                                                     1>/dev/null 2>&5 && log
 echo 123456 | passwd update --stdin                                                1>/dev/null 2>&5 && log
 mkdir /usr/donica/update/system                                                    1>/dev/null 2>&5 && log
 chmod 777 -R /usr/donica/update/system                                             1>/dev/null 2>&5 && log
 usermod -d /usr/donica/update/system update                                        1>/dev/null 2>&5 && log
#cp /root/source/pkts/proftp/proftpd.conf /opt/lampp/etc/proftpd.conf          1>/dev/null 2>&5 && log
# cp /root/source/pkts/proftp/my.cnf /opt/lampp/etc                             1>/dev/null 2>&5 && log
 /opt/lampp/lampp restart                                                           1>/dev/null 2>&5 && log

###############################################################################################
# import ftp syslog
###############################################################################################
echo "\n$DATE(line:$LINENO)import ftp syslog"                                               >&6
useradd syslog                                                                     1>/dev/null 2>&5 && log
echo 123456 | passwd syslog --stdin                                                1>/dev/null 2>&5 && log
mkdir /usr/donica/ftp/log                                                          1>/dev/null 2>&5 && log
chmod 777 -R /usr/donica/ftp/log                                                   1>/dev/null 2>&5 && log
usermod -d /usr/donica/ftp/log syslog                                              1>/dev/null 2>&5 && log

###############################################################################################
# configure PAE
###############################################################################################
echo "\n$DATE(line:$LINENO)Congfigure PAE"                                                  >&6
 cd /root/source/pkts/kernel                                                        1>/dev/null 2>&5 && log
 rpm -ivh kernel-3.10.0-514.el7.x86_64.rpm                                          1>/dev/null 2>&5 && log              
 rpm -ivh kernel-devel-3.10.0-514.2.2.el7.x86_64.rpm                                1>/dev/null 2>&5 && log

###############################################################################################
# configure dns
###############################################################################################
echo "\n$DATE(line:$LINENO)configure dns"                                                   >&6
cp /root/source/etc/named.conf /etc -Rf                                        1>/dev/null 2>&5 && log
cp /root/source/etc/named.conf /var/named/chroot/etc -Rf                       1>/dev/null 2>&5 && log
cp /root/source/pkts/named  /var/named/chroot/var -Rf                          1>/dev/null 2>&5 && log
service named restart                                                               1>/dev/null 2>&5 && log

###############################################################################################
# install tools
###############################################################################################
echo "\n$DATE(line:$LINENO)install expect"                                                   >&6
cd /root/source/pkts/expect
rpm -ivh expect-5.45-14.el7_1.x86_64.rpm                                        1>/dev/null 2>&5 && log
rpm -ivh tcl-8.5.13-8.el7.x86_64.rpm                                            1>/dev/null 2>&5 && log
echo "\n$DATE(line:$LINENO)configure minicom"                                                   >&6
rpm -ivh minicom-2.6.2-5.el7.x86_64.rpm                                         1>/dev/null 2>&5 && log

###############################################################################################
# copy app script conf lib to server
###############################################################################################
echo "\n$DATETIME(line:$LINENO) copy app script conf lib to server" 			                  >&6
cp /root/source/server/app /usr/donica  -R 									1>/dev/null 2>&5 && log
cp /root/source/server/script /usr/donica -R 									1>/dev/null 2>&5 && log
cp /root/source/server/conf /usr/donica -R 									1>/dev/null 2>&5 && log
cp /root/source/server/lib /usr/donica -R 										1>/dev/null 2>&5 && log
cp /root/source/server/lib/libcurl.so.4 /lib -R 								1>/dev/null 2>&5 && log
cp /root/source/server/lib/libcurl.so.3 /lib -R 								1>/dev/null 2>&5 && log
cp /root/source/server/lib/libcurl.so /lib -R 									1>/dev/null 2>&5 && log
cp /root/source/server/lib/liblog.so /lib -R 									1>/dev/null 2>&5 && log
cp /root/source/server/lib/libmysqlclient.so.15.0.0 /lib -R 					1>/dev/null 2>&5 && log
cp /root/source/server/lib/libmysqlclient.so.15 /lib -R 						1>/dev/null 2>&5 && log
cp /root/source/server/lib/libmysqlclient.so /lib -R 							1>/dev/null 2>&5 && log
cp /root/source/server/system_update.xml /usr/donica/update/system -R 			1>/dev/null 2>&5 && log
cp /root/source/server/system_version_info.xml /usr/donica/update/system -R 	1>/dev/null 2>&5 && log
cp /root/source/server/system_update.xml /usr/donica/ 							1>/dev/null 2>&5 && log
cp /root/source/server/system_version_info.xml /usr/donica/ 					1>/dev/null 2>&5 && log

###############################################################################################
# copy CMT and epg to server
###############################################################################################
echo "\n$DATETIME(line:$LINENO) copy web & epg to server" 			                  >&6
cp /root/source/web/CMT /opt/lampp/htdocs/                                      1>/dev/null 2>&5 && log
cp /root/source/web/EPG /opt/lampp/htdocs/                                      1>/dev/null 2>&5 && log
cp /root/source/web/index.php /opt/lampp/htdocs/                                1>/dev/null 2>&5 && log
cp /root/source/web/config.inc.php /opt/lampp/phpmyadmin/config.inc.php         1>/dev/null 2>&5 && log
chmod 777 /opt/lampp/CMT -R                                                     1>/dev/null 2>&5 && log
chmod 777 /opt/lampp/EPG -R                                                     1>/dev/null 2>&5 && log
chmod 777 /opt/lampp/htdocs -R                                                  1>/dev/null 2>&5 && log

###############################################################################################
# set Ethernet dev name
###############################################################################################
echo "\n$DATE(line:$LINENO) set Ethernet dev name"                                          >&6
cp /root/source/pkts/dhcp/ifcfg-eth0 /etc/sysconfig/network-scripts/           1>/dev/null 2>&5 && log
mv /etc/default/grub /etc/default/grub_bak                                          1>/dev/null 2>&5 && log
cp /root/source/pkts/dhcp/grub /etc/default/grub                               1>/dev/null 2>&5 && log
grub2-mkconfig -o /boot/grub2/grub.cfg                                              

###############################################################################################
# configure dhcp
###############################################################################################
echo "\n$DATE(line:$LINENO) install dhcpd"                                                  >&6
cd /root/source/pkts/dhcp                                                           1>/dev/null 2>&5 && log
rpm -ivh dhcp-4.2.5-42.el7.centos.x86_64.rpm                                        1>/dev/null 2>&5 && log
rpm -ivh dhcp-devel-4.2.5-42.el7.centos.x86_64.rpm                                  1>/dev/null 2>&5 && log
cp /root/source/pkts/dhcp/dhcpd.conf /etc/dhcp/                                1>/dev/null 2>&5 && log
cp /root/source/pkts/dhcp/dhcpd /etc/sysconfig/                                1>/dev/null 2>&5 && log
mkdir /var/state/dhcp
cp /root/source/pkts/dhcp/dhcpd.leases /var/state/dhcp/ 						1>/dev/null 2>&5 && log
chkconfig dhcpd on 																	1>/dev/null 2>&5 && log
service  dhcpd restart 																1>/dev/null 2>&5 && log


###############################################################################################
# configure snmp
###############################################################################################
echo "\n$DATETIME(line:$LINENO) configure snmp" 									                          >&6
mkdir /usr/local/share/snmp/mibs                                                    
cp /root/source/server/app/snmp/mibs /usr/local/share/snmp -Rf                 1>/dev/null 2>&5 && log

###############################################################################################
# configure tftp-server
###############################################################################################
echo "\n$DATE(line:$LINENO) configure tftp-server"                                          >&6
cd /root/source/pkts/vsftpd/
rpm -ivh ftp-0.17-66.el7.x86_64.rpm                                                1>/dev/null 2>&5 && log
rpm -ivh vsftpd-3.0.2-10.el7.x86_64.rpm                                             1>/dev/null 2>&5 && log
service xinetd restart 																1>/dev/null 2>&5 && log


###############################################################################################
# chmod donica and htdocs dir
###############################################################################################
echo "\n$DATETIME(line:$LINENO) chmod donica and htdocs dir" 						                    >&6
chmod 777 -R /opt/lampp/htdocs/epg_key
chmod 777 -R /opt/lampp/htdocs/files/program0
chmod 777 -R /opt/lampp/htdocs/files/program1
chmod 777 -R /usr/donica


###############################################################################################
# configure 4g dial
###############################################################################################
#set service
echo "\n$DATE(line:$LINENO) configure 4g service"                                           >&6
cd /root/source/service                                                             1>/dev/null 2>&5 && log
./install.sh

#set donica lib
echo "\n$DATE(line:$LINENO) configure donica_wifi lib"                                      >&6
cd /root/source/donica/lib/                                                         1>/dev/null 2>&5 && log
./install.sh            
cd /root/source/donica/libusb-1.0.9/                                                1>/dev/null 2>&5 && log
./configure
make && make install                                                                1>/dev/null 2>&5 && log
cd /root/source/donica/m054                                                         1>/dev/null 2>&5 && log
./compile.sh
cd /root/source/donica/pca9555/                                                     1>/dev/null 2>&5 && log
./compile.sh
cd /root/source/donica/mcp2210/                                                     1>/dev/null 2>&5 && log
./compile.sh
cd /etc                                                                             1>/dev/null 2>&5 && log
mv ppp ppp.bak                                                                      1>/dev/null 2>&5 && log
cp /root/source/ppp /etc -af                                                   1>/dev/null 2>&5 && log
#SAY   			 "Dialing up...*99***1#\n" //移动用户，请把这行前面的#号去掉
#SAY   			 "Dialing up...*99#\n"  //联通用户，请把这行前面的#号去掉
#SAY   			 "Dialing up...#777\n" //电信用户，请把这行前面的#号去掉

#OK              ATDT*99***1#  //移动用户，请把这行前面的#号去掉
#OK              ATDT*99#  //联通用户，请把这行前面的#号去掉
#OK              ATDT#777#  //电信用户，请把这行前面的#号去掉
cd /etc/ppp                                                                         1>/dev/null 2>&5 && log

###############################################################################################
# chmod donica and htdocs dir
###############################################################################################
echo "\n$DATETIME(line:$LINENO) chmod donica and htdocs dir" 						                    >&6
chmod 777 -R /opt/lampp/htdocs/epg_key
chmod 777 -R /opt/lampp/htdocs/files/program0
chmod 777 -R /opt/lampp/htdocs/files/program1
chmod 777 -R /usr/donica

###############################################################################################
# Exit CD-ROM
###############################################################################################
echo "\n$DATETIME(line:$LINENO) exit CD-ROM" 										                            >&6
umount /dev/sdc																    	1>/dev/null 2>&5 && log

echo "\n<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< end <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<" 		1>/dev/null 2>&5 && log

