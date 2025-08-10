#!/bin/sh

iptables -t nat -A OUTPUT -m owner --uid-owner arti -j RETURN
iptables -t nat -A OUTPUT -p tcp --syn -j REDIRECT --to-port 9050

iptables -t nat -A OUTPUT -p udp -dport 53 -j REDIRECT --to-port 1053
