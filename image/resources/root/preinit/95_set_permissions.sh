#!/bin/bash

echo "Making sure user opencms is the owner of the container base dir"
chown -R ${OPENCMS_USER}:${OPENCMS_USER} $CONTAINER_BASE
