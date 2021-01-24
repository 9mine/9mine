#!/bin/sh

stdbuf -o0 -i0 nc -ul 172.24.172.227 8888 | stdbuf -o0 -i0 nc -ul 172.24.172.227 7777
