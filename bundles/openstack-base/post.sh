#!/bin/bash

. /usr/share/conjure/hooklib/common.sh


if [[ $JUJU_PROVIDERTYPE =~ "lxd" ]]; then
    debug openstack "(post) setting osd-devices for ceph"
    juju set-config ceph "osd-devices=/opt/ceph-osd"
    juju set-config ceph-osd "osd-devices=/opt/ceph-osd"
fi

dashboard_address=$(unitAddress openstask-dashboard 0)
if [ $dashboard_address != "null" ]; then
    exposeResult "Login to Horizon: http://$dashboard_address/horizon l: admin p: openstack" 0 "true"
else
    exposeResult "Waiting for the dashboard to become available..." 1 "false"
fi
