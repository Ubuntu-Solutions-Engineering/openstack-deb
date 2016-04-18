#!/bin/bash

. /usr/share/conjure-up/hooklib/common.sh

if [[ $JUJU_PROVIDERTYPE =~ "lxd" ]]; then
    debug openstack "(pre) processing lxd"
    exposeResult "Post complete" 0 "true"

elif [[ $JUJU_PROVIDERTYPE =~ "maas" ]]; then
    debug openstack "(pre) processing MAAS selection"

    exposeResult "Post complete" 0 "true"
else
    debug openstack "(pre) unknown provider type $JUJU_PROVIDERTYPE"

    exposeResult "Unknown provider type" 1 "false"
fi
