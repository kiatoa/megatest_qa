#!/usr/bin/env bash

# Run your step here
echo Got here!

#start_step step1
megatest -step step1 :state start :status n/a

# mutate env var which is eval'ed in runconfigs.config
echo "before PATH=$PATH"
export PATH=/pollution:$PATH

# force cache cleaning
echo "after PATH=$PATH"


touch kickoff # trigger test clean/restart
sleep 10
sleep $SLEEPYTIME
#mv -v $MT_RUN_AREA_HOME/lt/$MT_TARGET/$MT_RUNNAME/.megatest.cfg* $MT_TEST_RUN_DIR/.
megatest -step step1 :state end :status 0


# force cache rebuild
megatest -test-status :state COMPLETED :status PASS

exit 0

