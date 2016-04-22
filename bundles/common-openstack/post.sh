#!/bin/bash

. /usr/share/conjure-up/hooklib/common.sh
. $SCRIPTPATH/../bundle-common.sh

exposeError() {
    local parent_lineno="$1"
    exposeResult  "Error on or near line ${parent_lineno}, maybe in ${BASH_SOURCE}" 1 "false"
    exit 0
}
trap 'exposeError ${LINENO} ${BASH_SOURCE}' ERR

keystone_status=$(unitStatus keystone 0)
if [ $keystone_status != "active" ]; then
    exposeResult "Waiting for Keystone..." 1 "false"
fi

keystone_address=$(unitAddress keystone 0)

glance_status=$(unitStatus glance 0)
if [ $glance_status != "active" ]; then
    exposeResult "Waiting for Glance..." 1 "false"
else
    debug openstack "(post) importing images for glance"
    mkdir -p $HOME/glance-images || true
    if [ ! -f $HOME/glance-images/xenial-server-cloudimg-amd64-disk1.img ]; then
        wget -qO ~/glance-images/xenial-server-cloudimg-amd64-disk1.img http://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-amd64-disk1.img
    fi
    if [ ! -f $HOME/glance-images/trusty-server-cloudimg-amd64-disk1.img ]; then
        wget -qO ~/glance-images/trusty-server-cloudimg-amd64-disk1.img http://cloud-images.ubuntu.com/trusty/current/trusty-server-cloudimg-amd64-disk1.img
    fi

    . $SCRIPTPATH/novarc
    debug openstack "Connecting to keystone $keystone_address"
    glance image-create --name="trusty" \
           --container-format=bare \
           --disk-format=root-tar \
           --property architecture="x86_64" \
           --visibility=public --file=$HOME/glance-images/trusty-server-cloudimg-amd64-disk1.img >> /dev/null 2>&1
    glance image-create --name="xenial" \
           --container-format=bare \
           --disk-format=root-tar \
           --property architecture="x86_64" \
           --visibility=public --file=$HOME/glance-images/xenial-server-cloudimg-amd64-disk1.img >> /dev/null 2>&1
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
    openstack keypair show ubuntu-keypair >> /dev/null || openstack keypair create --public-key $HOME/.ssh/id_rsa.pub ubuntu-keypair
fi

dashboard_address=$(unitAddress openstack-dashboard 0)
if [ $dashboard_address != "null" ]; then
    exposeResult "Login to Horizon: http://$dashboard_address/horizon l: admin p: openstack" 0 "true"
else
    exposeResult "Waiting for the dashboard to become available..." 1 "false"
fi

