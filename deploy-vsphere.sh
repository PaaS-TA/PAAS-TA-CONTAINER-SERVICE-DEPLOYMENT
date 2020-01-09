#!/bin/bash

# SET VARIABLES
export CAAS_DEPLOYMENT_NAME='paasta-container-service'
export CAAS_BOSH2_NAME='micro-bosh'
export CAAS_BOSH2_UUID=`bosh int <(bosh -e ${CAAS_BOSH2_NAME} environment --json) --path=/Tables/0/Rows/0/uuid`

# K8S Cert check
check_credhub=$(credhub get -n /${CAAS_BOSH2_NAME}/${CAAS_DEPLOYMENT_NAME}/tls-kubernetes 2>&1)
if [[ "$check_credhub" == "You are not currently authenticated. Please log in to continue." ]] || [[ "$check_credhub" == *"connect: connection refuse"* ]]
then
  echo "You are not currently authenticated to CredHub. Please log in to continue."
  exit 1
elif [[ "$check_credhub" == *"connect: no route to"* ]];then
  echo "You are not currently authenticated to CredHub. Please log in to continue."
  exit 1
elif [[ "$check_credhub" == "The request could not be completed because the credential does not exist or you do not have sufficient authorization." ]];then
  echo "No cert tls-kubernetes."
else
  credhub get -n /${CAAS_BOSH2_NAME}/${CAAS_DEPLOYMENT_NAME}/tls-kubernetes -k certificate > temp.crt
  caas_public_ip=$(cat manifests/paasta-container-service-vars-vsphere.yml | grep caas_master_public_url | grep -v '#' | sed 's/"//g' | awk '{printf "%s\n",$2}')
  ip_addresses=$(openssl x509 -noout -text -in temp.crt | grep ${caas_public_ip})
  rm -f temp.crt
  if [[ "$ip_addresses" == *"${caas_public_ip}"* ]];then
    echo "Already have cert 'tls-kubernetes' with same IP address"
  else
    #echo "Need to delete cert already exist"
    credhub delete -n /${CAAS_BOSH2_NAME}/${CAAS_DEPLOYMENT_NAME}/tls-kubernetes
  fi
fi

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
