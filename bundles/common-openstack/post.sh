#!/bin/bash

. /usr/share/conjure-up/hooklib/common.sh
. $SCRIPTPATH/../bundle-common.sh

keystone_status=$(unitStatus keystone 0)
if [ $keystone_status != "active" ]; then
    exposeResult "Waiting for Keystone..." 1 "false"
fi

glance_status=$(unitStatus glance 0)
if [ $glance_status != "active" ]; then
    exposeResult "Waiting for Glance..." 1 "false"
else
    debug openstack "(post) importing images for glance"
    mkdir -p ~/glance-images
    wget -qO ~/images/trusty-server-cloudimg-amd64-disk1.img  http://cloud-images.ubuntu.com/trusty/current/trusty-server-cloudimg-amd64-disk1.img
    wget -qO ~/images/xenial-server-cloudimg-amd64-disk1.img  http://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-amd64-disk1.img
    glance image-create --name="trusty" \
           --container-format=bare \
           --disk-format=root-tar \
           --property architecture="x86_64" \
           --visibility=public < ~/images/trusty-server-cloudimg-amd64-disk1.img 2> /dev/null
    glance image-create --name="xenial" \
           --container-format=bare \
           --disk-format=root-tar \
           --property architecture="x86_64" \
           --visibility=public < ~/images/xenial-server-cloudimg-amd64-disk1.img 2> /dev/null
fi


if [[ $JUJU_PROVIDERTYPE =~ "lxd" ]]; then
    debug openstack "(post) setting credentials"

    . $SCRIPTPATH/novarc

    debug openstack "(post) configuring neutron"
    config_neutron

    debug openstack "(post) adding keypair"
    if [ ! -f $HOME/.ssh/id_rsa.pub ]; then
        debug openstack "(post) Error attempting add $HOME/.ssh/id_rsa.pub to OpenStack, maybe it still need to be created with ssh-keygen?"
    fi
    openstack keypair create --public-key $HOME/.ssh/id_rsa.pub ubuntu-keypair || true
fi

dashboard_address=$(unitAddress openstack-dashboard 0)
if [ $dashboard_address != "null" ]; then
    exposeResult "Login to Horizon: http://$dashboard_address/horizon l: admin p: openstack" 0 "true"
else
    exposeResult "Waiting for the dashboard to become available..." 1 "false"
fi

