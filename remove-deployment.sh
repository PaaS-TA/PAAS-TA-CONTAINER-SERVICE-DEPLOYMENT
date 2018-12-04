#!/bin/bash

# SET VARIABLES
export CAAS_DEPLOYMENT_NAME='paasta-container-service'
export CAAS_BOSH2_NAME='micro-bosh'

# DELETE DEPLOYMENT
bosh -e ${CAAS_BOSH2_NAME} -n delete-deployment -d ${CAAS_DEPLOYMENT_NAME} --force
