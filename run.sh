#!/bin/sh

podman run \
    --rm \
    --name arti-container \
    --network podman \
    -p 127.0.0.1:9050:9050 \
    -p 127.0.0.1:1053:1053 \
    -t arti-container
