#!/bin/bash -ex

cat lxd-profile.yaml | lxc profile edit juju-default
printf '{"message": "%s", "returnCode": %d, "postStatus": %s}' "Post bootstrap complete" 0 true
