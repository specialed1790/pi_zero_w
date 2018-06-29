# Copyright (c) 2016 Joseph D Poirier
# Distributable under the terms of The New BSD License
# that can be found in the LICENSE file.

#### files created and/or modified
# /etc/default/isc-dhcp-server
# /etc/hostapd/hostapd.conf
# /etc/network/interfaces
# /usr/sbin/stratux-wifi.sh


if [ $(whoami) != 'root' ]; then
    echo "${RED}This script must be executed as root, exiting...${WHITE}"
    exit
fi

rm -f /etc/rc*.d/*hostapd
rm -f /etc/network/if-pre-up.d/hostapd
rm -f /etc/network/if-post-down.d/hostapd
rm -f /etc/init.d/hostapd
rm -f /etc/default/hostapd

# what wifi interface, e.g. wlan0, wlan1..., uses the first one found
#wifi_interface=$(lshw -quiet -c network | sed -n -e '/Wireless interface/,+12 p' | sed -n -e '/logical name:/p' | cut -d: -f2 | sed -e 's/ //g')
wifi_interface=wlan0

echo "${MAGENTA}Configuring $wifi_interface interface...${WHITE}"


##############################################################
## Setup DHCP server for IP address management
##############################################################
echo
echo "${YELLOW}**** Setup DHCP server for IP address management *****${WHITE}"

### set /etc/default/isc-dhcp-server
cp -n /etc/default/isc-dhcp-server{,.bak}
cat <<EOT > /etc/default/isc-dhcp-server
INTERFACES="$wifi_interface"
EOT

### set /etc/dhcp/dhcpd.conf
cp -n /etc/dhcp/dhcpd.conf{,.bak}
cat <<EOT > /etc/dhcp/dhcpd.conf
ddns-update-style none;
default-lease-time 86400; # 24 hours
max-lease-time 172800; # 48 hours
authoritative;
log-facility local7;
subnet 192.168.10.0 netmask 255.255.255.0 {
    range 192.168.10.10 192.168.10.50;
    option broadcast-address 192.168.10.255;
    default-lease-time 12000;
    max-lease-time 12000;
    option domain-name "stratux.local";
    option domain-name-servers 4.2.2.2;
}
EOT

echo "${GREEN}...done${WHITE}"


##############################################################
## Setup /etc/hostapd/hostapd.conf
##############################################################
echo
echo "${YELLOW}**** Setup /etc/hostapd/hostapd.conf *****${WHITE}"

if [ "$REVISION" == "$RPI2BxREV" ] || [ "$REVISION" == "$RPI2ByREV" ] || [ "$REVISION" = "$RPI0xREV" ] || [ "$REVISION" = "$RPI0yREV" ]; then

cat <<EOT > /etc/hostapd/hostapd-edimax.conf
interface=$wifi_interface
driver=rtl871xdrv
ssid=stratux
hw_mode=g
channel=1
wmm_enabled=1
ieee80211n=1
ignore_broadcast_ssid=0
EOT

fi

cat <<EOT > /etc/hostapd/hostapd.conf
interface=$wifi_interface
ssid=stratux
hw_mode=g
channel=1
wmm_enabled=1
ieee80211n=1
ignore_broadcast_ssid=0
EOT

echo "${GREEN}...done${WHITE}"


##############################################################
## Setup /etc/network/interfaces
##############################################################
echo
echo "${YELLOW}**** Setup /etc/network/interfaces *****${WHITE}"

cp -n /etc/network/interfaces{,.bak}

cat <<EOT > /etc/network/interfaces
source-directory /etc/network/interfaces.d

auto lo
iface lo inet loopback

allow-hotplug wlan0

iface wlan0 inet static
  address 192.168.10.1
  netmask 255.255.255.0
  post-up /usr/sbin/stratux-wifi.sh
EOT

echo "${GREEN}...done${WHITE}"


#################################################
## Setup /usr/sbin/stratux-wifi.sh
#################################################
echo
echo "${YELLOW}**** Setup /usr/sbin/stratux-wifi.sh *****${WHITE}"

# we use a slightly modified version to handle more hardware scenarios
chmod 755 ${SCRIPTDIR}/stratux-wifi.sh
cp ${SCRIPTDIR}/stratux-wifi.sh /usr/sbin/stratux-wifi.sh

echo "${GREEN}...done${WHITE}"


#################################################
## Legacy wifiap cleanup
#################################################
echo
echo "${YELLOW}**** Legacy wifiap cleanup *****${WHITE}"

#### legacy file check
if [ -f "/etc/init.d/wifiap" ]; then
    service wifiap stop
    rm -f /etc/init.d/wifiap
    echo "${MAGENTA}legacy wifiap service stopped and file removed... *****${WHITE}"
fi

echo "${GREEN}...done${WHITE}"

