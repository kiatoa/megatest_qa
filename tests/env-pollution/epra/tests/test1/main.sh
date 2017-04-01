#!/usr/bin/env bash

# Run your step here
echo Got here!


#start_step step1
megatest -step step1 :state start :status n/a

#logpro $MT_TEST_RUN_DIR/run_${MT_TEST_NAME}.logpro $MT_TEST_RUN_DIR/run_${MT_TEST_NAME}.html < $MT_TEST_RUN_DIR/run_${MT_TEST_NAME}.log >& /dev/null

if [[ $FAIR == FAIR ]]; then 
   echo Good.  FAIR is set as per runconfig
else
  echo Bad.  Runconfig-driven setting of FAIR is polluted.
  megatest -test-status :state COMPLETED :status FAIL
fi

export FAIR=FOWL
sleep $SLEEPYTIME

if [[ $FAIR == FOWL ]]; then 
  megatest -test-status :state COMPLETED :status PASS
  megatest -step step1 :state end :status 0
  exit 0
else
    megatest -test-status :state COMPLETED :status FAIL
    megatest -step step1 :state end :status 1
    exit 1
fi

