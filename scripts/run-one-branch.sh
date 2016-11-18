#!/bin/bash

# We receive the megatest fossil location via $MEGATEST_FOSSIL_FILE
# Create candidates

MEGATEST_FOSSIL_FILE=$HOME/fossils/megatest.fossil
RUNNAME=$(date +ww%U.%u)
STDTESTS=toprun,testpatt_envvar,testpatt,runconfig-tests,rollup,rerunclean,listruns-tests,itemwait,envvars,dependencies,fullrun
if [[ $(lsb_release -si) == "Ubuntu" ];then
    INTEG_BRANCH=integ-home
else
    INTEG_BRANCH=integ-office
fi

function process_one_branch () {
    rm -f branches.txt skip_branches.txt all-branches-nodes.txt

    # first create list of open branches, ignore anything with "$INTEG_BRANCH" in the name.
    #
    fossil branch list -a -R $MEGATEST_FOSSIL_FILE | tr '*' ' ' |awk '{print $1}'|grep -v "$INTEG_BRANCH" > all-branches.txt

    # get the wiki list of nodes
    #
    fossil wiki export tested_nodes -R $MEGATEST_FOSSIL_FILE > tested_nodes
    cp tested_nodes tested_nodes.orig

    # for each branch get the last node
    for branch in $(cat all-branches.txt);do
	node=$(fossil timeline -t ci  -W 0 "$branch" -R $MEGATEST_FOSSIL_FILE |egrep -v ^=== | tr '[]' '  '| awk '{print $2}'|head -1)
	echo "$branch $node" >> all-branches-nodes.txt
	if grep $node tested_nodes > /dev/null;then
	    echo "$branch $node" >> skip_branches.txt
	else
	    echo "$branch" >> branches.txt
	    echo "$node $branch" >> tested_nodes
	    echo "Would run: (cd ..;megatest -run -target $branch/$node -runname $RUNNAME -testpatt $STDTESTS -runwait)"
	    break
	fi
    done

    if diff tested_nodes tested_nodes.orig > /dev/null;then
	echo "Nothing was run"
    else
	echo "Committing changed tested_nodes file"
	# fossil wiki commit tested_nodes tested_nodes -R $MEGATEST_FOSSIL_FILE
    fi
}

mkdir -p integration
(cd integration;process_one_branch )

