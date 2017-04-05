#!/bin/bash

echo "Test run directory created in $(pwd)"
echo "tom and bob should be created in /tmp/$USER."
echo "fred should be created under the normal runs dir"
echo

if [[ $PROVIDER == 'tom' || $PROVIDER == 'bob' ]];then
    if $(pwd | grep '/tmp' > /dev/null);then
        echo PASS
    else
        echo FAIL
    fi
else
    if $(pwd | grep '/tmp' > /dev/null);then
        echo FAIL
    else
        echo PASS
    fi
fi