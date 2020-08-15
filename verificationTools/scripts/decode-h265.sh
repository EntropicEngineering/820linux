#	Copyright © 2019, Intrinsyc Technologies Corp.
#	History:
#	Author (Intrinsyc Rel 3.2): Pradeep M <pradeep.m@intrinsyc.com>
#usage: ./decode.sh <filename.h265>
#Eg: ./decode.sh test.h265

if [ $(dpkg-query -W -f='${Status}' ffmpeg 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
echo "ffmpeg is not present, Installing ......"
sudo apt-get install ffmpeg;
else
echo "ffmpeg already installed"
fi

ffplay -sync video -an -autoexit -vcodec hevc_v4l2m2m -i $1

