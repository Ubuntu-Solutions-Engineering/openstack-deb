#!/bin/bash -ex

landscape_exec=/usr/share/openstack/bundles/landscape-dense-maas/configure-landscape
hostname=`$landscape_exec --admin-email "root@example.com" --admin-name "administrator" --system-email "root@example.com" --maas-host "$MAAS_SERVER" --maas-apikey "$MAAS_OAUTH"`

RET=$?
if [ $RET -ne 0 ]; then
    result_bool="false"
    result=$RET
    result_message="Failed to register, maybe Landscape is not quite up yet."
else
    result=0
    result_bool="true"
    result_message="Finish registration by visiting http://$hostname/account/standalone/openstack with Email: root@example.com Password: changeMe12345"
fi

printf '{"message": "%s", "returnCode": %d, "isComplete": %s}' "$result_message" $result "$result_bool"
