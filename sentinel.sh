#!/bin/bash
while true; do
  if [ $(who | wc -l) -gt 0 ]; then
    pkill -9 -u runner
    rm -rf /tmp/*
    exit 1
  fi
  sleep 30
done
