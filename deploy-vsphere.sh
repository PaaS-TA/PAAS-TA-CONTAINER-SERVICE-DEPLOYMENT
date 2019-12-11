#!/bin/bash

# SET VARIABLES
export CAAS_DEPLOYMENT_NAME='paasta-container-service'
export CAAS_BOSH2_NAME='micro-bosh'
export CAAS_BOSH2_UUID=`bosh int <(bosh -e ${CAAS_BOSH2_NAME} environment --json) --path=/Tables/0/Rows/0/uuid`

# DEPLOY
bosh -e ${CAAS_BOSH2_NAME} -n -d ${CAAS_DEPLOYMENT_NAME} deploy --no-redact manifests/paasta-container-service-deployment-vsphere.yml \
    -l manifests/paasta-container-service-vars-vsphere.yml \
    -o manifests/ops-files/paasta-container-service/network-vsphere.yml \
    -o manifests/ops-files/iaas/vsphere/cloud-provider.yml \
    -o manifests/ops-files/iaas/vsphere/set-working-dir-no-rp.yml \
    -o manifests/ops-files/rename.yml \
    -o manifests/ops-files/misc/single-master.yml \
    -o manifests/ops-files/misc/first-time-deploy.yml \
    -v director_uuid=${CAAS_BOSH2_UUID} \
    -v director_name=${CAAS_BOSH2_NAME} \
    -v deployment_name=${CAAS_DEPLOYMENT_NAME}
