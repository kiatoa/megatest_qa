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

if [[ $SLEEPYTIME == 1 ]]; then
    echo for iter 1, exit immediately
    megatest -test-status :state COMPLETED :status PASS
    megatest -step step1 :state end :status 0
    exit 0
else
    touch $MT_RUN_AREA_HOME/kickoff # trigger test clean/restart
    sleep 5  # during this pause, ./wait_kickoff will simulate user running "megatest -target $TARGET -runname $RUNNAME -run -testpatt $TESTPATT -clean-cache", clearing .megatest.cfg-## cache file
    sleep $SLEEPYTIME
    megatest -test-status :state COMPLETED :status PASS
    megatest -step step1 :state end :status 0
    exit 0
fi



