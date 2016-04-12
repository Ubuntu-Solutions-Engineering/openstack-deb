#!/bin/bash

. /usr/share/conjure/hooklib/common.sh

if [[ $JUJU_PROVIDERTYPE =~ "lxd" ]]; then
    debug openstack "(post) processing lxd"

    controller_address=$(unitAddress keystone 0)
    debug openstack "(post) found controller: $controller_address"

    # configOpenrc admin password admin http://$controller_address:5000/v2.0 RegionOne
    # configOpenrc ubuntu password admin http://$controller_address:5000/v2.0 RegionOne

    exposeResult "Post complete" 0 "true"

elif [[ $JUJU_PROVIDERTYPE =~ "maas" ]]; then
    debug openstack "(post) processing MAAS selection"

    exposeResult "Post complete" 0 "true"
else
    debug openstack "(post) unknown provider type $JUJU_PROVIDERTYPE"

    exposeResult "Unknown provider type" 1 "false"
fi
