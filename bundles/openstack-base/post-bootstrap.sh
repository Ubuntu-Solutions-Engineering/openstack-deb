#!/bin/bash -ex

cat lxd-profile.yaml | lxc profile edit juju-default
printf '{"message": "%s", "returnCode": %d, "isComplete": %s}' "Post bootstrap complete" 0 "true"
