#!/bin/bash

. /usr/share/conjure-up/hooklib/common.sh

debug openstack "Running post-bootstrap for a Autopilot install"

exposeResult "Post bootstrap complete" 0 "true"
