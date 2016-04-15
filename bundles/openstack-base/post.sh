#!/bin/bash

. /usr/share/conjure/hooklib/common.sh


if [[ $JUJU_PROVIDERTYPE =~ "lxd" ]]; then
    debug openstack "(post) setting osd-devices for ceph"
    juju set-config ceph "osd-devices=/opt/ceph-osd" || \
        { exposeResult "Unable to set ceph device yet, retrying.." 1 "false"; exit 1; }

    juju set-config ceph-osd "osd-devices=/opt/ceph-osd" || \
        { exposeResult "Unable to set ceph device yet, retrying.." 1 "false"; exit 1; }

    $SCRIPTPATH/neutron-ext-net -g 192.168.21.1 \
                                -c 192.168.21.0/24 \
                                -f 192.168.21.100:192.168.21.200 ext_net || \
        { exposeResult "Unable to create ext-net, retrying.." 1 "false"; exit 1; }

    $SCRIPTPATH/neutron-tenant-net -t admin -r provider-router admin_net 10.5.5.0/24 || \
        { exposeResult "Unable to create admin-net, retrying.." 1 "false"; exit 1; }
fi

dashboard_address=$(unitAddress openstask-dashboard 0)
if [ $dashboard_address != "null" ]; then
    exposeResult "Login to Horizon: http://$dashboard_address/horizon l: admin p: openstack" 0 "true"
    exit 0
else
    exposeResult "Waiting for the dashboard to become available..." 1 "false"
    exit 1
fi
