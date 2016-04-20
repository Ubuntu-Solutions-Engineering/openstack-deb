. /usr/share/conjure-up/hooklib/common.sh

fail_cleanly() {
    exposeResult "$1" 1 "false"
    exit 0
}

# CEPH
# Configures ceph properties, mainly useful for LXD
config_ceph() {
    debug openstack "(post) setting ceph properties"

    juju set-config ceph use-direct-io=false 2> /dev/null
    RET=$?
    if [ $RET -ne 0 ]; then
        fail_cleanly "(post) could not set ceph use-direct-io"
    fi

    juju set-config ceph-osd use-direct-io=false 2> /dev/null
    RET=$?
    if [ $RET -ne 0 ]; then
        fail_cleanly "(post) could not set ceph-osd use-direct-io"
    fi

    juju set-config ceph-osd osd-devices=/opt/ceph-osd 2> /dev/null
    RET=$?
    if [ $RET -ne 0 ]; then
        fail_cleanly "(post) could not set ceph-osd osd-devices"
    fi

    juju set-config ceph osd-devices=/opt/ceph-osd 2> /dev/null
    RET=$?
    if [ $RET -ne 0 ]; then
        fail_cleanly "(post) could not set ceph osd-devices"
    fi
}

# NEUTRON
# Configures neutron
config_neutron() {
    neutron net-show ext-net || neutron net-create --router:external ext-net 2> /dev/null
    RET=$?
    if [ $RET -ne 0 ]; then
        fail_cleanly "Neutron unable to create external router..."
    fi
    neutron subnet-show ext-subnet || neutron subnet-create ext-net 10.99.0.0/24 \
                                              --gateway 10.99.0.1 \
                                              --allocation-pool start=10.99.0.2,end=10.99.0.254 2> /dev/null
    RET=$?
    if [ $RET -ne 0 ]; then
        fail_cleanly "Neutron unable to create external subnet..."
    fi

    neutron net-show ubuntu-net || neutron net-create ubuntu-net --shared
    RET=$?
    if [ $RET -ne 0 ]; then
        fail_cleanly "Neutron unable to create network..."
    fi

    neutron subnet-show ubuntu-subnet || neutron subnet-create --name ubuntu-subnet --gateway 10.101.0.1 --dns-nameserver 10.99.0.1 ubuntu-net 10.101.0.0/24 2> /dev/null
    RET=$?
    if [ $RET -ne 0 ]; then
        fail_cleanly "Neutron unable to create subnet..."
    fi

     neutron router-show ubuntu-router || neutron router-create ubuntu-router 2> /dev/null
    RET=$?
    if [ $RET -ne 0 ]; then
        fail_cleanly "Neutron unable to create router..."
    fi

    neutron router-interface-add ubuntu-router ubuntu-subnet 2> /dev/null || true
    RET=$?
    if [ $RET -ne 0 ]; then
        fail_cleanly "Neutron unable to add interface to Neutron router and subnet..."
    fi

    neutron router-gateway-set ubuntu-router ext-net 2> /dev/null || true
    RET=$?
    if [ $RET -ne 0 ]; then
        fail_cleanly "Unable to set Neutron gateway to router..."
    fi

    # create pool of at least 5 floating ips
    existingips=$(neutron floatingip-list -f csv | wc -l) # this number will include a header line
    to_create=$((6 - existingips))
    i=0
    while [ $i -ne $to_create ]; do
        neutron floatingip-create ext-net 2> /dev/null
        i=$((i + 1))
    done
    # configure security groups
    neutron security-group-rule-create --direction ingress --ethertype IPv4 --protocol icmp --remote-ip-prefix 0.0.0.0/0 default 2> /dev/null || true
    neutron security-group-rule-create --direction ingress --ethertype IPv4 --protocol tcp --port-range-min 22 --port-range-max 22 --remote-ip-prefix 0.0.0.0/0 default 2> /dev/null || true
    exposeResult "Neutron configured" 0 "true"
}
