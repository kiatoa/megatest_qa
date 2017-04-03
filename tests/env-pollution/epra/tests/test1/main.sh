#!/usr/bin/env bash

# Run your step here
echo Got here!

#start_step step1
megatest -step step1 :state start :status n/a

# mutate env var which is eval'ed in megatest.config
echo "before PATH=$PATH"
export PATH=/pollution:$PATH # POLLUTE the environment .  This should NOT get propagated to .megatest.cfg-## cache

# force cache cleaning
echo "after PATH=$PATH"


touch kickoff # trigger test clean/restart
sleep 10  # during this pause, ./wait_kickoff will simulate user running "megatest -target $TARGET -runname $RUNNAME -run -testpatt $TESTPATT -clean-cache", clearing .megatest.cfg-## cache file
sleep $SLEEPYTIME

megatest -step step1 :state end :status 0  # this triggers megatest to rebuild cache, reeval $PATH with /pollution above, counter to user expectation and 1.60/29a behavior


# force cache rebuild
megatest -test-status :state COMPLETED :status PASS

exit 0

