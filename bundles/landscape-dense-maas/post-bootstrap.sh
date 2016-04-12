#!/bin/bash

. /usr/share/conjure/hooklib/common.sh

debug openstack "Running post-bootstrap for a Autopilot install"

exposeResult "Post bootstrap complete" 0 "true"
