#!/bin/sh

podman logs arti-container
podman container ps -a

sudo ss -lnp | grep 9050
sudo ss -lnp | grep 1053

curl --proxy socks5h://127.0.0.1:9050 https://check.torproject.org/api/ip

nc -zv 127.0.0.1 9050
