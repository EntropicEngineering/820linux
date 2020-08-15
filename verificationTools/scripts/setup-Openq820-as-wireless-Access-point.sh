#!/bin/bash
#		Copyright © 2018, Intrinsyc Technologies Corp.
#
#		- This script is to setup openQ 820 dev board act as wireless access point
#
#			History:
#			Author (Intrinsyc Rel 3.0): Pradeep M <pradeep.m@intrinsyc.com>
# usage:
#  ./setup-Openq820-as-wireless-Access-point.sh -s <ssid name> -p <password> -b <802.11 band> -u
#
# To delete the wireless access point, run below command
# ./setup-Openq820-as-wireless-Access-point.sh -d
#
#Note 1: set 802.11 band as 'bg' for 2.4GHz
#Note 2: set 802.11 band as 'a' for 5GHz
#Note 3: once you set/change wireless band, then make the link up by running the command
#./setup-Openq820-as-wireless-Access-point.sh -u

myArray=("$@")
GREEN='\e[32;1m'
WHITE='\e[37;1m'

logme_green()
{
	echo -e "`date +'%b %e %R '` $GREEN"$@"$ENDING"
}
logme_white()
{
	echo -e "`date +'%b %e %R '` $WHITE"$@"$ENDING"
}

	if [ -z "${myArray}" ]; then
		logme_white  "No arguments found on command line"
		logme_white "usage: ./setup-Openq820-as-wireless-Access-point.sh -s <ssid name> -p <password> -b <802.11 band> -u"
		logme_white "Note1: only numbers are allowed for password field"
		logme_white "Note2: set 802.11 band as 'bg' for 2.4GHz"
		logme_white "Note3: set 802.11 band as 'a' for 5GHz"
	fi

	if [ $1 == "-d" ]; then
		logme_green "removing the wireless access point"
		nmcli connection delete WirelessAP
	fi

	while getopts ":s:b:p:uh:" o; do
		case "${o}" in
			s)
				s=${OPTARG}
				logme_green "Setting ssid: "${s}""
				if [ -z "${s}" ]; then
					logme_green "No second argument found on command line, setting default ssid to openq820"
					nmcli connection add \
					type wifi \
					ifname wlp1s0 \
					con-name WirelessAP \
					autoconnect no \
					ssid openq820
				else
					nmcli connection add \
					type wifi \
					ifname wlp1s0 \
					con-name WirelessAP \
					autoconnect no \
					ssid ${s}
				fi
				;;
			b)
				b=${OPTARG}
				logme_green "Setting 802.11 wireless band: "${b}""
				if [ -z "${b}" ]; then
					logme_green "No second argument found on command line, setting default wirless band to 2.4 GHz"
					nmcli connection modify WirelessAP 802-11-wireless.mode ap 802-11-wireless.band bg
				else
					nmcli connection modify WirelessAP 802-11-wireless.mode ap \
									802-11-wireless.band ${b}
				fi
				;;
			p)
				p=${OPTARG}
				logme_green "setting password: "${p}""
				if [ -z "${p}" ]; then
					logme_green "No second argument found on command line, setting default password to 1234567890"
					nmcli connection modify WirelessAP ipv4.method shared wifi-sec.key-mgmt wpa-psk \
									wifi-sec.psk 1234567890
				else
					nmcli connection modify WirelessAP ipv4.method shared wifi-sec.key-mgmt wpa-psk \
									wifi-sec.psk ${p}
				fi
				;;
			u)
				logme_white "setting up the link"
				u=${OPTARG}
				if [ -z "${u}" ]; then
				nmcli connection up WirelessAP
				fi
				;;
		esac
		done

