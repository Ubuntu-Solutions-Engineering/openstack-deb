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

    if [[ $JUJU_PROVIDERTYPE =~ "lxd" ]]; then
        imagetype=root.tar.xz
        diskformat=raw
        imagesuffix="-lxd"
    else
        imagetype=disk1.img
        diskformat=root-tar
        imagesuffix=""
    fi

    mkdir -p $HOME/glance-images || true
    if [ ! -f $HOME/glance-images/xenial-server-cloudimg-amd64-$imagetype ]; then
        debug openstack "(post) downloading xenial image..."
        wget -qO ~/glance-images/xenial-server-cloudimg-amd64-$imagetype https://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-amd64-$imagetype
    fi
    if [ ! -f $HOME/glance-images/trusty-server-cloudimg-amd64-$imagetype ]; then
        debug openstack "(post) downloading trusty image..."
        wget -qO ~/glance-images/trusty-server-cloudimg-amd64-$imagetype https://cloud-images.ubuntu.com/trusty/current/trusty-server-cloudimg-amd64-$imagetype
    fi

    . $SCRIPTPATH/novarc
    if ! glance image-list --property-filter name="trusty$imagesuffix" | grep -q "trusty$imagesuffix" ; then
        debug openstack "(post) importing trusty$imagesuffix"
        if ! glance image-create --name="trusty$imagesuffix" \
               --container-format=bare \
               --disk-format=$diskformat \
               --property architecture="x86_64" \
               --visibility=public --file=$HOME/glance-images/trusty-server-cloudimg-amd64-$imagetype > /dev/null 2>&1; then
            exposeResult "Waiting for Glance image import..." 1 "false"
        fi
    fi
    if ! glance image-list --property-filter name="xenial$imagesuffix" | grep -q "xenial$imagesuffix" ; then
        debug openstack "(post) importing xenial$imagesuffix"
        if ! glance image-create --name="xenial$imagesuffix" \
               --container-format=bare \
               --disk-format=$diskformat \
               --property architecture="x86_64" \
               --visibility=public --file=$HOME/glance-images/xenial-server-cloudimg-amd64-$imagetype > /dev/null 2>&1; then
            exposeResult "Waiting for Glance image import..." 1 "false"
        fi
    fi
fi


if [[ $JUJU_PROVIDERTYPE =~ "lxd" ]]; then

    if [ ! -f $HOME/.ssh/id_rsa.pub ]; then
        debug openstack "(post) adding keypair"
        if ! ssh-keygen -N '' -f $HOME/.ssh/id_rsa; then
            debug openstack "(post) Error attempting to create $HOME/.ssh/id_rsa.pub to be added OpenStack"
        fi

    fi
    . $SCRIPTPATH/novarc
    if ! openstack keypair show ubuntu-keypair > /dev/null 2>&1; then
        if ! openstack keypair create --public-key $HOME/.ssh/id_rsa.pub ubuntu-keypair > /dev/null 2>&1; then
            exposeResult "Adding SSH Keypair..." 1 "false"
        fi
    fi

    config_neutron
fi

dashboard_address=$(unitAddress openstack-dashboard 0)
if [ $dashboard_address != "null" ]; then
    exposeResult "Login to Horizon: http://$dashboard_address/horizon l: admin p: openstack" 0 "true"
else
    exposeResult "Waiting for the dashboard to become available..." 1 "false"
fi

