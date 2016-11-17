#!/bin/bash

# We receive the megatest fossil location via $MEGATEST_FOSSIL_FILE
# Create candidates

rm -f branches.txt skip_branches.txt all-branches-nodes.txt

# first create list of open branches, ignore anything with "trunk" in the name.
#
fossil branch list -a -R $MEGATEST_FOSSIL_FILE | tr '*' ' ' |awk '{print $1}'|grep -v trunk > all-branches.txt

# get the wiki list of nodes
#
fossil wiki export tested_nodes -R $MEGATEST_FOSSIL_FILE > tested_nodes

# for each branch get the last node
for branch in $(cat all-branches.txt);do
    node=$(fossil timeline -t ci  -W 0 "$branch" -R $MEGATEST_FOSSIL_FILE |egrep -v ^=== | tr '[]' '  '| awk '{print $2}'|head -1)
    echo "$branch $node" >> all-branches-nodes.txt
    if grep $node tested_nodes > /dev/null;then
	echo "$branch $node" >> skip_branches.txt
    else
	echo "$branch" >> branches.txt
	echo "$node $branch" >> tested_nodes
    fi
done

# fossil wiki commit tested_nodes tested_nodes -R $MEGATEST_FOSSIL_FILE 
