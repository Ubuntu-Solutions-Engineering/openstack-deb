#!/bin/bash

. /usr/share/conjure/hooklib/common.sh

landscape_exec=/usr/share/openstack/bundles/landscape-dense-maas/configure-landscape
hostname=`$landscape_exec --admin-email "root@example.com" --admin-name "administrator" --system-email "root@example.com" --maas-host "$MAAS_SERVER" --maas-apikey "$MAAS_OAUTH"`

RET=$?
if [ $RET -ne 0 ]; then
    result_bool="false"
    result=$RET
    result_message="Autopilot is still pending, will retry registering when available."
else
    result=0
    result_bool="true"
    result_message="Access Autopilot: http://$hostname/account/standalone/openstack l: root@example.com p: ubuntu123"
fi

exposeResult "$result_message" $result "$result_bool"
exit $RET
