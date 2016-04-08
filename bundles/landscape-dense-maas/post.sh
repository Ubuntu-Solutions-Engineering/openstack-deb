#!/bin/bash -ex


./configure-landscape --admin-email "root@example.com" \
                      --admin-name "administrator" \
                      --system-email "root@example.com" \
                      --maas-host "$MAAS_SERVER" \
                      --maas-apikey "$MAAS_OAUTH"


printf '{"message": "%s", "returnCode": %d, "isComplete": %s}' "Registered against autopilot" $? "true"
