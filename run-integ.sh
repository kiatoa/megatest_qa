#!/bin/bash

if ! ssh-add -L;then
  echo "You need to have an ssh agent!"
  echo "You should also run this under screen"
  exit
fi

while true;do 
  echo "Starting an integ run"
  flock --nonblock --verbose run-one.lock ./scripts/run-one-branch.sh
  echo "sleeping for five minutes $(date)"
  sleep 5m
done
