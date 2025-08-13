#!/bin/sh

#podman run --rm  --network pasta:--map-gw -t arti-proxy
podman run --rm --network podman -p 9050:9050 -p 1053:1053 -t arti-container
