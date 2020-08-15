#	Copyright © 2018, Intrinsyc Technologies Corp.
#	History:
#	Author (Intrinsyc Rel 3.0): Pradeep M <pradeep.m@intrinsyc.com>
#watch Video Hardware accelerator/venus interrupts

watch -n1 "cat /proc/interrupts | grep venus"

