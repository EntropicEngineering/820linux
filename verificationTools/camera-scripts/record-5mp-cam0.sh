#	Copyright © 2018, Intrinsyc Technologies Corp.
#	History:
#	Author (Intrinsyc Rel 3.1): Pradeep M <pradeep.m@intrinsyc.com>
#usage: ./record-5mp-cam0.sh <video bitrate> <filename>

sudo media-ctl -d /dev/media0 -l '"msm_csiphy0":1->"msm_csid0":0[1],"msm_csid0":1->"msm_ispif0":0[1],"msm_ispif0":1->"msm_vfe0_pix":0[1]'
sudo media-ctl -d /dev/media0 -V '"ov5640 4-0078":0[fmt:UYVY2X8/2592x1944 field:none],"msm_csiphy0":0[fmt:UYVY2X8/2592x1944 field:none],"msm_csid0":0[fmt:UYVY2X8/2592x1944 field:none],"msm_ispif0":0[fmt:UYVY2X8/2592x1944 field:none],"msm_vfe0_pix":0[fmt:UYVY2X8/2592x1944 field:none],"msm_vfe0_pix":1[fmt:UYVY1_5X8/2592x1944 field:none]'
gst-launch-1.0 -e v4l2src device=/dev/video3 ! video/x-raw,format=NV12,width=2592,height=1944 ! v4l2h264enc extra-controls="controls,h264_profile=4,video_bitrate=$1000000;" ! h264parse ! mp4mux ! filesink location=$2.h264
