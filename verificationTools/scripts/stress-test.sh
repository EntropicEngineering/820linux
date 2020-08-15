#	Copyright © 2018, Intrinsyc Technologies Corp.
#	History:
#	Author (Intrinsyc Rel 3.0): Pradeep M <pradeep.m@intrinsyc.com>
# perform stress test on cpu and memory

# This test will run for 300 seconds with 4 cpu stressors, 2 io stressors and 1 vm stressor using 1GB of virtual memory

if [ $(dpkg-query -W -f='${Status}' stress-ng 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
echo "stress-ng is not present, Installing ......"
sudo apt-get install stress-ng;
else
echo "stress-ng already installed"
fi
echo "This test will stress the cpu and memory and it  will run for 5 minutes, please wait till it gets completed"
stress-ng --cpu 4 --io 2 --vm 1 --vm-bytes 1G --timeout 300s &
