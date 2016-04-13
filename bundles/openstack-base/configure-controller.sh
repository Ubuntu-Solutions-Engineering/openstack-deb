#!/bin/bash -e

. /usr/share/conjure/hooklib/common.sh

. $SCRIPTPATH/novarc

# remove tiny image
openstack flavor delete m1.tiny || true

# import key pair
openstack keypair create --public-key $HOME/.local/share/juju/ssh/id_rsa.pub ubuntu-keypair || true

# security
neutron security-group-rule-create --direction ingress --ethertype IPv4 --protocol icmp --remote-ip-prefix 0.0.0.0/0 default || true
neutron security-group-rule-create --direction ingress --ethertype IPv4 --protocol tcp --port-range-min 22 --port-range-max 22 --remote-ip-prefix 0.0.0.0/0 default || true

