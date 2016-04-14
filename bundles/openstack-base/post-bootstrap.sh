#!/bin/bash

. /usr/share/conjure/hooklib/common.sh

if [[ $JUJU_PROVIDERTYPE =~ "lxd" ]]; then
    debug openstack "(post-bootstrap) processing lxd"

    profilename=$(juju switch | cut -d: -f2)
    sed "s/##MODEL##/$profilename/" $SCRIPTPATH/lxd-profile.yaml | lxc profile edit "juju-$profilename"

    RET=$?
    if [ $RET -ne 0 ]; then
        exposeResult "Failed" $RET "false"
    else
        exposeResult "Post bootstrap complete" 0 "true"
    fi
else
    debug openstack "(post-bootstrap) unknown provider type $JUJU_PROVIDERTYPE"

    exposeResult "Unknown provider type" 1 "false"
fi
