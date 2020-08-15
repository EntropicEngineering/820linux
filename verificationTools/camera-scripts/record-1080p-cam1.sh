#	Copyright © 2018, Intrinsyc Technologies Corp.
#	History:
#	Author (Intrinsyc Rel 3.1): Pradeep M <pradeep.m@intrinsyc.com>
#usage: ./record-1080p-cam0.sh <video bitrate> <filename>

sudo media-ctl -d /dev/media0 -l '"msm_csiphy1":1->"msm_csid1":0[1],"msm_csid1":1->"msm_ispif1":0[1],"msm_ispif1":1->"msm_vfe1_pix":0[1]'

sudo media-ctl -d /dev/media0 -V '"ov5640 4-003c":0[fmt:UYVY2X8/1920x1080 field:none],"msm_csiphy1":0[fmt:UYVY2X8/1920x1080 field:none],"msm_csid1":0[fmt:UYVY2X8/1920x1080 field:none],"msm_ispif1":0[fmt:UYVY2X8/1920x1080 field:none],"msm_vfe1_pix":0[fmt:UYVY2X8/1920x1080 field:none],"msm_vfe1_pix":1[fmt:UYVY1_5X8/1920x1080 field:none]'

gst-launch-1.0 -e v4l2src device=/dev/video7 ! video/x-raw,format=NV12,width=1920,height=1080 ! v4l2h264enc extra-controls="controls,h264_profile=4,video_bitrate=$1000000;" ! h264parse ! mp4mux ! filesink location=$2.h264
