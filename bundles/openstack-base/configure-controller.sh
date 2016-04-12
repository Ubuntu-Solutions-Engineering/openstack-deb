#!/bin/bash -ex

# NOTE: this script exits on errors and will be re-run if it returns
# any error value, so please ensure that commands are either safe to
# run multiple times or are guarded.
# TODO: Write these rc files to a tmppath
# CFG_HOME=$(openstack-config cfg_path)
# SSH_KEY=$(openstack-config pubkey)

# . "$CFG_HOME/openstack-admin-rc"

# adjust tiny image
openstack flavor delete m1.tiny || true

# create ubuntu user
openstack project create --description "Create by Juju" ubuntu || true
openstack user create --password "password01" --project ubuntu --email juju@localhost ubuntu || true
openstack role list |grep -q "Member" || openstack role add --user ubuntu --project ubuntu Member

# import key pair
openstack keypair create --public-key $HOME/.local/share/juju/ssh/id_rsa.pub ubuntu-keypair || true

if [[ "$JUJU_PROVIDERTYPE" == "lxd" ]]; then
    # configure external network for Single install path
    neutron net-show ext-net || neutron net-create --router:external ext-net
    neutron subnet-show ext-subnet || neutron subnet-create ext-net 10.0.10.0/24 \
                                              --gateway 10.0.10.1 \
                                              --allocation-pool start=10.0.10.2,end=10.0.10.254
    neutron net-show ubuntu-net || neutron net-create ubuntu-net --shared
    neutron subnet-show ubuntu-subnet || neutron subnet-create --name ubuntu-subnet --gateway 10.101.0.1 --dns-nameserver 10.0.10.1 ubuntu-net 10.101.0.0/24
    neutron router-show ubuntu-router || neutron router-create ubuntu-router
    neutron router-interface-add ubuntu-router ubuntu-subnet || true
    neutron router-gateway-set ubuntu-router ext-net # OK to run multiple times

    # create pool of at least 5 floating ips
    existingips=$(neutron floatingip-list -f csv | wc -l) # this number will include a header line
    to_create=$((6 - existingips))
    i=0
    while [ $i -ne $to_create ]; do
      neutron floatingip-create ext-net
      i=$((i + 1))
    done
fi
# configure security groups
neutron security-group-rule-create --direction ingress --ethertype IPv4 --protocol icmp --remote-ip-prefix 0.0.0.0/0 default || true
neutron security-group-rule-create --direction ingress --ethertype IPv4 --protocol tcp --port-range-min 22 --port-range-max 22 --remote-ip-prefix 0.0.0.0/0 default || true
