#!/bin/bash
wdir="$(cd "$(dirname $0)" && pwd)"
mkdir -p rsa
fname="kc"
yes y | ssh-keygen -q -t rsa -b 4096 -N '' -f "$wdir/rsa/${fname}.pem"
