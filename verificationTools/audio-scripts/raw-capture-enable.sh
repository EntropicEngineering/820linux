# Copyright © 2018, Intrinsyc Technologies Corp.
# History:
# Author (Intrinsyc Rel 3.1): Ganesh Biradar <gbiradar@intrinsyc.com>

amixer cset iface=MIXER,name='MultiMedia2 Mixer SLIMBUS_0_TX' 1
amixer cset iface=MIXER,name='AIF1_CAP Mixer SLIM TX0' 1
amixer cset iface=MIXER,name='SLIM TX0 MUX' 'DEC0'
amixer cset iface=MIXER,name='ADC MUX0' 'AMIC'
amixer cset iface=MIXER,name='AMIC MUX0' 'ADC2'
amixer cset iface=MIXER,name='ADC2 Volume' 12
echo " "
echo " "
echo "To record in raw format"
echo " "
echo "arecord -d 10 -D plughw:0,1 -r 48000 -f S16_LE S16_LE_48000.wav"
echo " "
echo " -d Duration(in seconds)"
echo " -D select PCM by name"
echo " -r sample rate"
echo " -f sample format (case insensitive)"

