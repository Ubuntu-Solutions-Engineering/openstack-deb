. /usr/share/conjure-up/hooklib/common.sh

fail_cleanly() {
    exposeResult "$1" 1 "false"
}

# NEUTRON
# Configures neutron
config_neutron() {
    debug openstack "adding ext-net"
    neutron net-show ext-net >> /dev/null || neutron net-create --router:external ext-net >> /dev/null
    RET=$?
    if [ $RET -ne 0 ]; then
        fail_cleanly "Neutron unable to create external router..."
    fi
    debug openstack "adding ext-subnet"
    neutron subnet-show ext-subnet >> /dev/null || neutron subnet-create --name ext-subnet ext-net 10.99.0.0/24 \
                                              --gateway 10.99.0.1 \
                                              --allocation-pool start=10.99.0.2,end=10.99.0.254 >> /dev/null
    RET=$?
    if [ $RET -ne 0 ]; then
        fail_cleanly "Neutron unable to create external subnet..."
    fi

    debug openstack "adding ubuntu-net"
    neutron net-show ubuntu-net >> /dev/null || neutron net-create ubuntu-net --shared >> /dev/null
    RET=$?
    if [ $RET -ne 0 ]; then
        fail_cleanly "Neutron unable to create network..."
    fi

    debug openstack "adding ubuntu-subnet"
    neutron subnet-show ubuntu-subnet >> /dev/null || neutron subnet-create --name ubuntu-subnet \
                                                 --gateway 10.101.0.1 \
                                                 --dns-nameserver 10.99.0.1 ubuntu-net 10.101.0.0/24 >> /dev/null
    RET=$?
    if [ $RET -ne 0 ]; then
        fail_cleanly "Neutron unable to create subnet..."
    fi

    debug openstack "adding ubuntu-router"
    neutron router-show ubuntu-router >> /dev/null || neutron router-create ubuntu-router >> /dev/null
    RET=$?
    if [ $RET -ne 0 ]; then
        fail_cleanly "Neutron unable to create router..."
    fi

    debug openstack "adding ubuntu router interface"
    neutron router-interface-add ubuntu-router ubuntu-subnet 2> /dev/null || true
    RET=$?
    if [ $RET -ne 0 ]; then
        fail_cleanly "Neutron unable to add interface to Neutron router and subnet..."
    fi

    debug openstack "setting router gateway"
    neutron router-gateway-set ubuntu-router ext-net >> /dev/null || true
    RET=$?
    if [ $RET -ne 0 ]; then
        fail_cleanly "Unable to set Neutron gateway to router..."
    fi

    # create pool of at least 5 floating ips
    debug openstack "creating floating ips"
    existingips=$(neutron floatingip-list -f csv | wc -l) # this number will include a header line
    to_create=$((6 - existingips))
    i=0
    while [ $i -ne $to_create ]; do
        neutron floatingip-create ext-net >> /dev/null
        i=$((i + 1))
    done
    # configure security groups

    debug openstack "setting security roles"
    neutron security-group-rule-create --direction ingress --ethertype IPv4 --protocol icmp --remote-ip-prefix 0.0.0.0/0 default 2> /dev/null || true
    neutron security-group-rule-create --direction ingress --ethertype IPv4 --protocol tcp --port-range-min 22 --port-range-max 22 --remote-ip-prefix 0.0.0.0/0 default 2> /dev/null || true
    debug openstack "neutron configured!"
}
