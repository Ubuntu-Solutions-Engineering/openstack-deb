#!/bin/bash

. /usr/share/conjure/hooklib/common.sh

debug openstack "(post) performing post administrative tasks"
controller_address=$(unitAddress keystone 0)

if [ $controller_address != "null" ]; then
    debug openstack "(post) found controller: $controller_address"
    $SCRIPTPATH/configure-controller.sh
    exposeResult "" 0 "true"
else
    exposeResult "Unable to determine keystone address, retrying" 1 "false"
fi
