#!/bin/bash

# Redirect all shell output to openstack logger
exec 1> >(logger -s -t openstack) 2>&1
