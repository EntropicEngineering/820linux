# Copyright © 2018, Intrinsyc Technologies Corp.
# History:
# Author (Intrinsyc Rel 3.1): Ganesh Biradar <gbiradar@intrinsyc.com>

# MultiMedia2 play PCM format
# root@OpenQ820:~# ls /dev/snd/
# by-path  comprC0D0  controlC0  pcmC0D1c  pcmC0D1p  pcmC0D2c  pcmC0D2p  timer
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
amixer cset iface=MIXER,name='RX5 Digital Volume' 68
amixer cset iface=MIXER,name='RX6 Digital Volume' 68
amixer cset iface=MIXER,name='SLIMBUS_6_RX Audio Mixer MultiMedia2' 1
amixer cset iface=MIXER,name='RX INT2 DEM MUX' 'CLSH_DSM_OUT'
amixer cset iface=MIXER,name='RX INT1 DEM MUX' 'CLSH_DSM_OUT'
echo " "
echo " "
echo "Run below command replace filename.wav with your wav filename"
echo "aplay -D plughw:0,1 filname.wav"

