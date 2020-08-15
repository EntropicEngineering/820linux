#	Copyright © 2019, Intrinsyc Technologies Corp.
#	History:
#	Author (Intrinsyc Rel 3.2): Pradeep M <pradeep.m@intrinsyc.com>
#usage: ./record-1080p-cam2.sh <video bitrate> <filename>

sudo media-ctl -d /dev/media0 -l '"msm_csiphy2":1->"msm_csid2":0[1],"msm_csid2":1->"msm_ispif2":0[1],"msm_ispif2":1->"msm_vfe0_rdi0":0[1]'
sudo media-ctl -d /dev/media0 -V '"ov5640 4-003a":0[fmt:UYVY2X8/1280x720 field:none],"msm_csiphy2":0[fmt:UYVY2X8/1280x720 field:none],"msm_csid2":0[fmt:UYVY2X8/1280x720 field:none],"msm_ispif2":0[fmt:UYVY2X8/1280x720 field:none],"msm_vfe0_rdi0":0[fmt:UYVY2X8/1280x720 field:none]'

gst-launch-1.0 -e v4l2src device=/dev/video0  ! video/x-raw,format=UYVY,width=1280,height=720,framerate=30/1 ! videoconvert ! video/x-raw,format=NV12,width=1280,height=720,framerate=30/1 ! v4l2h264enc extra-controls="controls,h264_profile=4,video_bitrate=$1000000;" ! h264parse ! mp4mux ! filesink location=$2.h264




