# Copyright © 2018, Intrinsyc Technologies Corp.
# History:
# Author (Intrinsyc Rel 3.1): Ganesh Biradar <gbiradar@intrinsyc.com>

# MultiMedia1 play MP3/COMPRESS format
# root@OpenQ820:~# ls /dev/snd/
# by-path  comprC0D0  controlC0  pcmC0D1c  pcmC0D1p  pcmC0D2c  pcmC0D2p  timer
# $ cplay

amixer cset iface=MIXER,name='SLIM RX0 MUX' 'ZERO'
amixer cset iface=MIXER,name='SLIM RX1 MUX' 'ZERO'
amixer cset iface=MIXER,name='SLIM RX2 MUX' 'ZERO'
amixer cset iface=MIXER,name='SLIM RX3 MUX' 'ZERO'
amixer cset iface=MIXER,name='SLIM RX4 MUX' 'ZERO'
amixer cset iface=MIXER,name='SLIM RX7 MUX' 'ZERO'
amixer cset iface=MIXER,name='SLIM RX5 MUX' 'AIF4_PB'
amixer cset iface=MIXER,name='SLIM RX6 MUX' 'AIF4_PB'
amixer cset iface=MIXER,name='RX INT2_2 MUX' 'RX6'
amixer cset iface=MIXER,name='RX INT1_2 MUX' 'RX5'
amixer cset iface=MIXER,name='RX5 Digital Volume' 32
amixer cset iface=MIXER,name='RX6 Digital Volume' 32
amixer cset iface=MIXER,name='SLIMBUS_6_RX Audio Mixer MultiMedia1' 1
amixer cset iface=MIXER,name='RX INT2 DEM MUX' 'CLSH_DSM_OUT'
amixer cset iface=MIXER,name='RX INT1 DEM MUX' 'CLSH_DSM_OUT'

echo "Install tinycompress(tinycompress_4.14_arm64.deb) on target system if it is not available."
echo "Check Verification Tools for tinycompress deb package"
echo "sudo dpkg -i tinycompress_4.14_arm64.deb."
echo "run command cplay in target system. If it gives unknown/missing library."
echo "run sudo ldconfig"
echo "MP3 File can be played using cplay which is part of tinycompress_4.14_arm64.deb package"
echo "usage: cplay [OPTIONS] filename"
echo "-c      card number"
echo "-d      device node"
echo "-I      specify codec ID (default is mp3)"
echo "-b      buffer size"
echo "-f      fragments"
echo "-v      verbose mode"
echo "-h      Prints this help list"

echo "Example:"
echo 	"cplay -c 0 -d 0 filename.mp3"

echo "Valid codec IDs:"
echo "PCM MP3 AMR AMRWB AMRWBPLUS AAC WMA REAL"
echo "VORBIS FLAC IEC61937 G723_1 G729 "
echo "or the value in decimal or hex"


