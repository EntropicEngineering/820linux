#	Copyright © 2019, Intrinsyc Technologies Corp.
#	History:
#	Author (Intrinsyc Rel 3.2): Pradeep M <pradeep.m@intrinsyc.com>
#usage: ./preview-pix-1080p-cam2.sh

sudo media-ctl -d /dev/media0 -l '"msm_csiphy2":1->"msm_csid2":0[1],"msm_csid2":1->"msm_ispif2":0[1],"msm_ispif2":1->"msm_vfe0_rdi0":0[1]'
sudo media-ctl -d /dev/media0 -V '"ov5640 4-003a":0[fmt:UYVY2X8/1920x1080 field:none],"msm_csiphy2":0[fmt:UYVY2X8/1920x1080 field:none],"msm_csid2":0[fmt:UYVY2X8/1920x1080 field:none],"msm_ispif2":0[fmt:UYVY2X8/1920x1080 field:none],"msm_vfe0_rdi0":0[fmt:UYVY2X8/1920x1080 field:none]'
gst-launch-1.0 v4l2src device=/dev/video0 ! 'video/x-raw,format=UYVY,width=1920,height=1080' ! glimagesink


