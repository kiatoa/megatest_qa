#!/bin/bash

# We receive the megatest fossil location via $MEGATEST_FOSSIL_FILE
# Create candidates

RUNNAME=$(date +ww%U.%u)

# Make these available to tests (i.e. export them).
export MEGATEST_FOSSIL_FILE=$HOME/fossils/megatest.fossil
export STDTESTS=toprun,testpatt_envvar,testpatt,runconfig-tests,rollup,rerunclean,listruns-tests,itemwait,envvars,dependencies,fullrun

if [[ "$(lsb_release -si)" == "Ubuntu" ]];then
    export INTEG_BRANCH=integ-home
else
    export INTEG_BRANCH=integ-office
fi

function process_one_branch () {
    rm -f branches.txt skip_branches.txt all-branches-nodes.txt

    # first create list of open branches, ignore anything with "$INTEG_BRANCH" in the name.
    #
    echo "Getting list of branch candidates"
    fossil sync -R $MEGATEST_FOSSIL_FILE
    fossil branch list -a -R $MEGATEST_FOSSIL_FILE | tr '*' ' ' |awk '{print $1}'|grep -v "$INTEG_BRANCH" > all-branches.txt
    echo "Done getting branch candidates list"

    # get the wiki list of nodes
    #
    echo "Getting list of already tested nodes"
    fossil wiki export tested_nodes -R $MEGATEST_FOSSIL_FILE > tested_nodes
    cp tested_nodes tested_nodes.orig
    echo "Done getting list of already tested nodes"

    # for each branch get the last node
    for branch in $(cat all-branches.txt);do
	node=$(fossil timeline -t ci  -W 0 "$branch" -R $MEGATEST_FOSSIL_FILE |egrep -v ^=== | tr '[]' '  '| awk '{print $2}'|head -1)
	echo "$branch $node" >> all-branches-nodes.txt
	if grep $node tested_nodes > /dev/null;then
	    echo "$branch $node" >> skip_branches.txt
	else
	    echo "Processing branch $branch"
	    echo "$branch" >> branches.txt
	    echo "$node $branch" >> tested_nodes
	    (cd ..;megatest -run -target $branch/$node -runname $RUNNAME -testpatt commit -run-wait)
	    # clean up.
	    killall mtest dboard -v
	    sleep 10
	    killall mtest dboard -v -9
	    break
	fi
    done

    if diff tested_nodes tested_nodes.orig > /dev/null;then
	echo "Nothing was run"
    else
	echo "Committing changed tested_nodes file"
#	fossil wiki commit tested_nodes tested_nodes -R $MEGATEST_FOSSIL_FILE
    fi
}

mkdir -p integration
(cd integration;process_one_branch )

