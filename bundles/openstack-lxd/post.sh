#!/bin/bash

. /usr/share/conjure-up/hooklib/common.sh
. $SCRIPTPATH/../bundle-common.sh

keystone_status=$(unitStatus keystone 0)
if [ $keystone_status != "active" ]; then
    exposeResult "Waiting for Keystone..." 1 "false"
fi

# if [[ $JUJU_PROVIDERTYPE =~ "lxd" ]]; then
#     debug openstack "(post) setting credentials"

#     . $SCRIPTPATH/novarc

#     debug openstack "(post) configuring neutron"
#     config_neutron
# fi

dashboard_address=$(unitAddress openstack-dashboard 0)
if [ $dashboard_address != "null" ]; then
    exposeResult "Login to Horizon: http://$dashboard_address/horizon l: admin p: openstack" 0 "true"
else
    exposeResult "Waiting for the dashboard to become available..." 1 "false"
fi

