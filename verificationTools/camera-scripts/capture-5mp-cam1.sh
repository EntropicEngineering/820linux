#	Copyright © 2018, Intrinsyc Technologies Corp.
#	History:
#	Author (Intrinsyc Rel 3.1): Pradeep M <pradeep.m@intrinsyc.com>
#usage: ./capture-5mp-cam1.sh <filename>

sudo media-ctl -d /dev/media0 -l '"msm_csiphy1":1->"msm_csid1":0[1],"msm_csid1":1->"msm_ispif1":0[1],"msm_ispif1":1->"msm_vfe1_pix":0[1]'

sudo media-ctl -d /dev/media0 -V '"ov5640 4-003c":0[fmt:UYVY2X8/2592x1944 field:none],"msm_csiphy1":0[fmt:UYVY2X8/2592x1944 field:none],"msm_csid1":0[fmt:UYVY2X8/2592x1944 field:none],"msm_ispif1":0[fmt:UYVY2X8/2592x1944 field:none],"msm_vfe1_pix":0[fmt:UYVY2X8/2592x1944 field:none],"msm_vfe1_pix":1[fmt:UYVY1_5X8/2592x1944 field:none]'

gst-launch-1.0 v4l2src device=/dev/video7 num-buffers=1 ! 'video/x-raw,format=NV12,width=2592,height=1944,framerate=30/1' ! jpegenc ! filesink location=$1.jpg
