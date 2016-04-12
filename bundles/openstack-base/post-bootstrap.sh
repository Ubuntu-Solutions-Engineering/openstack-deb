#!/bin/bash

if [ $JUJU_PROVIDERTYPE == "lxd" ]; then
    cat lxd-profile.yaml | lxc profile edit juju-default

    RET=$?
    if [ $RET -ne 0 ]; then
        printf '{"message": "%s", "returnCode": %d, "isComplete": %s}' "Failed" $RET "false"
    else
        printf '{"message": "%s", "returnCode": %d, "isComplete": %s}' "Post bootstrap complete" 0 "true"
    fi
fi
