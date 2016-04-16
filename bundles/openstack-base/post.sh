#!/bin/bash

. /usr/share/conjure/hooklib/common.sh


if [[ $JUJU_PROVIDERTYPE =~ "lxd" ]]; then
    debug openstack "(post) setting osd-devices for ceph"
    juju set-config ceph "osd-devices=/opt/ceph-osd" 2> /dev/null
    RET=$?
    if [ $RET -ne 0 ]; then
        exposeResult "Unable to set ceph device yet, retrying.." $RET "false"
        exit 0
    fi

    juju set-config ceph-osd "osd-devices=/opt/ceph-osd" 2> /dev/null
    RET=$?
    if [ $RET -ne 0 ];then
        exposeResult "Unable to set ceph device yet, retrying.." $RET "false"
        exit 0
    fi
fi

dashboard_address=$(unitAddress openstask-dashboard 0)
if [ $dashboard_address != "null" ]; then
    exposeResult "Login to Horizon: http://$dashboard_address/horizon l: admin p: openstack" 0 "true"
    exit 0
else
    exposeResult "Waiting for the dashboard to become available..." 1 "false"
    exit 0
fi
