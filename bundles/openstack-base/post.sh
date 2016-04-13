#!/bin/bash

. /usr/share/conjure/hooklib/common.sh

debug openstack "(post) querying for keystone"
controller_address=$(unitAddress keystone 0)
debug openstack "(post) keystone address: $controller_address"

if [ $controller_address != "null" ]; then
    debug openstack "(post) found controller: $controller_address"
    exposeResult "Found keystone" 0 "false"
else
    exposeResult "Unable to determine keystone address, retrying" 1 "false"
fi
