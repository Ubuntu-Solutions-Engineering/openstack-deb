#!/bin/bash

. /usr/share/conjure-up/hooklib/common.sh

if [[ $JUJU_PROVIDERTYPE =~ "lxd" ]]; then
    debug openstack "(post-bootstrap) processing lxd"

    profilename=$(juju switch | cut -d: -f2)
    sed "s/##MODEL##/$profilename/" $SCRIPTPATH/lxd-profile.yaml | lxc profile edit "juju-$profilename"

    RET=$?
    if [ $RET -ne 0 ]; then
        exposeResult "(post-bootstrap) Failed to udate lxd profile" $RET "false"
    else
        exposeResult "(post-bootstrap) Complete" 0 "true"
    fi
else
    debug openstack "(post-bootstrap) unknown provider type $JUJU_PROVIDERTYPE"

    exposeResult "Unknown provider type" 1 "false"
fi
