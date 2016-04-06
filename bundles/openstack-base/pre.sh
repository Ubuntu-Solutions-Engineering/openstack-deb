#!/bin/bash -ex

cat lxd-profile.yaml | lxc profile edit juju-default
echo '{"message": "Pre processing complete...", "returnCode": 0}'
