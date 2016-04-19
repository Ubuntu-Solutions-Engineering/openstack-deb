#!/bin/bash

. /usr/share/conjure-up/hooklib/common.sh
. $SCRIPTPATH/../bundle-common.sh

if [[ $JUJU_PROVIDERTYPE =~ "lxd" ]]; then
    . $SCRIPTPATH/novarc

    # debug openstack "(post) setting osd-devices for ceph"
    # config_ceph
    debug openstack "(post) configuring neutron"
    config_neutron
fi

dashboard_address=$(unitAddress openstask-dashboard 0)
if [ $dashboard_address != "null" ]; then
    exposeResult "Login to Horizon: http://$dashboard_address/horizon l: admin p: openstack" 0 "true"
else
    exposeResult "Waiting for the dashboard to become available..." 1 "false"
fi

