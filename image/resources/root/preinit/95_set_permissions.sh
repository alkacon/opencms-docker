#!/bin/bash

echo "Making sure user opencms is the owner of the container base dir"
chown -R ${RUN_AS_USER}:${RUN_AS_USER} $CONTAINER_BASE
