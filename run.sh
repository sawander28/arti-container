#!/bin/sh

podman run \
    --rm \
    --name arti-container \
    --network podman \
    -p 9050:9050 \
    -p 1053:1053 \
    -t arti-container
