#	Copyright © 2018, Intrinsyc Technologies Corp.
#	History:
#	Author (Intrinsyc Rel 3.0): Pradeep M <pradeep.m@intrinsyc.com>
# Watch the frequency of cores

sudo watch -n1 "cat /sys/devices/system/cpu/cpu*/cpufreq/cpuinfo_cur_freq"
