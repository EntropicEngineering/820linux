#	Copyright © 2018, Intrinsyc Technologies Corp.
#	History:
#	Author (Intrinsyc Rel 3.0): Pradeep M <pradeep.m@intrinsyc.com>
##usage: ./encode.sh <width> <height> <location>
##Eg: ./encode.sh 1920 1080 /home/linaro/test.h264

gst-launch-1.0 videotestsrc ! video/x-raw,format=NV12,width=$1,height=$2,framerate=30/1,profile=high ! v4l2h264enc ! queue ! filesink location=$3
