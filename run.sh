#!/bin/sh

podman run \
    --rm \
    --name arti-container \
    --network host \
    --publish 127.0.0.1:9050:9050 \
    --mount type=volume,src=arti,target=/home/arti/.cache/arti \
    -t arti-container
