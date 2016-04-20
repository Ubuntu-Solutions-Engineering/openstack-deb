#!/bin/bash

. /usr/share/conjure-up/hooklib/common.sh

if [[ $JUJU_PROVIDERTYPE =~ "lxd" ]]; then
    debug openstack "(pre) processing lxd"

    profilename=$(juju switch | cut -d: -f2)
    sed "s/##MODEL##/$profilename/" $SCRIPTPATH/lxd-profile.yaml | lxc profile edit "juju-$profilename"

    RET=$?
    if [ $RET -ne 0 ]; then
        exposeResult "(pre) Failed to update lxd profile" $RET "false"
    else
        exposeResult "(pre) Complete" 0 "true"
    fi

fi
debug openstack "(pre) unknown provider type $JUJU_PROVIDERTYPE"
exposeResult "Unknown provider type" 1 "false"
