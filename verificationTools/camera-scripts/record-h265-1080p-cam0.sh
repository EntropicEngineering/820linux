#	Copyright © 2019, Intrinsyc Technologies Corp.
#	History:
#	Author (Intrinsyc Rel 3.2): Pradeep M <pradeep.m@intrinsyc.com>
#usage: ./record-h265-cam0.sh <filename>

sudo media-ctl -d /dev/media0 -l '"msm_csiphy0":1->"msm_csid0":0[1],"msm_csid0":1->"msm_ispif0":0[1],"msm_ispif0":1->"msm_vfe0_pix":0[1]'

sudo media-ctl -d /dev/media0 -V '"ov5640 4-0078":0[fmt:UYVY2X8/1920x1080 field:none],"msm_csiphy0":0[fmt:UYVY2X8/1920x1080 field:none],"msm_csid0":0[fmt:UYVY2X8/1920x1080 field:none],"msm_ispif0":0[fmt:UYVY2X8/1920x1080 field:none],"msm_vfe0_pix":0[fmt:UYVY2X8/1920x1080 field:none],"msm_vfe0_pix":1[fmt:UYVY1_5X8/1920x1080 field:none]'

gst-launch-1.0 -e v4l2src device=/dev/video3 ! video/x-raw,format=NV12,width=1920,height=1080,framerate=30/1 ! v4l2h265enc extra-controls="controls,hevc_profile=0,hevc_level=0,video_bitrate=10000000;" ! h265parse ! mp4mux ! filesink location=$1.h265

