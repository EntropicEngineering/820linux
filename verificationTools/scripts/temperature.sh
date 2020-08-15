#	Copyright © 2018, Intrinsyc Technologies Corp.
#	History:
#	Author (Intrinsyc Rel 3.0): Pradeep M <pradeep.m@intrinsyc.com>
# watch the temperature of cores
sudo watch -n1 "cat /sys/devices/virtual/thermal/thermal_zone*/temp"
