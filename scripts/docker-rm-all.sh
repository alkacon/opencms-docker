#!/bin/bash

echo "=== START DOCKER CLEANUP SCRIPT ==="

echo "Removing all stale containers:"
STALE_CONTAINERS=$(docker ps -a | grep "Exited " | awk '{ print $1; }')
COUNT=$(echo "$STALE_CONTAINERS" | wc -m)

if [ $COUNT -gt 1 ]; then
    docker rm $STALE_CONTAINERS
else
    echo "- No stale containers found."
fi

echo "Removing all stale images that have <none> as name:"

STALE_IMAGES=$(docker images | grep "^<none>" | awk '{ print $3; }')
COUNT=$(echo "$STALE_IMAGES" | wc -m)

if [ $COUNT -gt 1 ]; then
    docker rmi $STALE_IMAGES
else
    echo "- No stale images found."
fi

echo "=== END DOCKER CLEANUP SCRIPT ==="