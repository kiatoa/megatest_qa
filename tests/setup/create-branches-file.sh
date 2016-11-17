#!/bin/bash

# We receive the megatest fossil location via $MEGATEST_FOSSIL_FILE
# Create candidates

# first create list of open branches
#
fossil branch list -a -R $MEGATEST_FOSSIL_FILE | tr '*' ' '; |awk '{print $1}' > all-branches.txt

# get the wiki list of nodes
#
fossil wiki export tested_nodes -R $MEGATEST_FOSSIL_FILE > tested_nodes

# for each branch get the last node
for branch in $(cat all-branches.txt);do
    node=$(fossil timeline -t ci  -W 0 v1.62|egrep -v ^=== | tr '[]' '  '| awk '{print $2}'|head -1)
    if grep $node tested_nodes;then
	echo $branch >> branches.txt
	echo $node >> tested_nodes
    fi
done



