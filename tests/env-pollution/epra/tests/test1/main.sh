#!/usr/bin/env bash

# Run your step here
echo Got here!


#start_step step1
megatest -step step1 :state start :status n/a

#logpro $MT_TEST_RUN_DIR/run_${MT_TEST_NAME}.logpro $MT_TEST_RUN_DIR/run_${MT_TEST_NAME}.html < $MT_TEST_RUN_DIR/run_${MT_TEST_NAME}.log >& /dev/null

# mutate env var which is eval'ed in runconfigs.config
echo "before PATH=$PATH"
export PATH=/pollution:$PATH
# force cache cleaning
echo "after PATH=$PATH"
rm $MT_RUN_AREA_HOME/lt/$MT_TARGET/$MT_RUNNAME/.megatest.cfg*
sleep $SLEEPYTIME
megatest -step step1 :state end :status 0
# force cache rebuild
megatest -test-status :state COMPLETED :status PASS
exit 0

