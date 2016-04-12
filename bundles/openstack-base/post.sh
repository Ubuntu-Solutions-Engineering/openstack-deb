#!/bin/bash

. /usr/share/openstack/bundles/common.sh

debug "Creating directory $HOME/.local/share/openstack for additional storage."
mkdir -p $HOME/.local/share/openstack

controller_address=$(unitAddress keystone 0)
configOpenrc admin password admin http://$controller_address:5000/v2.0 RegionOne > $HOME/.local/share/openstack/admin-openrc
configOpenrc ubuntu password admin http://$controller_address:5000/v2.0 RegionOne > $HOME/.local/share/openstack/ubuntu-openrc

printf '{"message": "%s", "returnCode": %d, "isComplete": %s}' "Post processing complete" 0 "true"
