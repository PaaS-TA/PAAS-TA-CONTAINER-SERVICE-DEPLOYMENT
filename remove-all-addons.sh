#!/bin/bash

director_name='micro-bosh'

bosh -e ${director_name} update-runtime-config manifests/ops-files/paasta-container-service/remove-all-addons.yml
