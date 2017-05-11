#!/bin/sh

if [[ $NUM == "2" ]]; then
    echo "FAIL since 2"
    exit 1
else
    echo "PASS"
    exit 0
fi
