#!/bin/bash -ex

PROFILE="$2"
FILENAME="$1"

cat $PROFILE | lxc profile edit $FILENAME
