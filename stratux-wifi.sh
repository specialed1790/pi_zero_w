#!/bin/bash


# Preliminaries. Kill off old services.
/usr/bin/killall -9 hostapd hostapd-edimax
/usr/sbin/service isc-dhcp-server stop


# Detect RPi version.
#  Per http://elinux.org/RPi_HardwareHistory

DAEMON_CONF=/etc/hostapd/hostapd.conf
DAEMON_SBIN=/usr/sbin/hostapd

# Edimax: EW-7811Un, USB hub w/builtin Wifi (RTL8188EUS): 8179 Realtek
SPECIAL_CONFIG_DONGLE=$(lsusb | grep -E 'EW-7811Un|8179 Realtek')
RPI_REV=`cat /proc/cpuinfo | grep 'Revision' | awk '{print $3}' | sed 's/^1000//'`
if [ "$RPI_REV" = "a01041" ] || [ "$RPI_REV" = "a21041" ] || [ "$RPI_REV" = "900092" ] || [ "$RPI_REV" = "900093" ] && [ "$SPECIAL_CONFIG_DONGLE" != '' ]; then
 # Edimax USB Wifi dongle or USB hub w/builtin Wifi
 DAEMON_CONF=/etc/hostapd/hostapd-edimax.conf
 DAEMON_SBIN=/usr/sbin/hostapd-edimax
else
 DAEMON_CONF=/etc/hostapd/hostapd.conf
fi


${DAEMON_SBIN} -B ${DAEMON_CONF}

sleep 5

/usr/sbin/service isc-dhcp-server start
