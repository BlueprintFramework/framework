#!/bin/bash
# 
# This script has been created as part of the Blueprint source code
# and may be intergrated directly into the core in the future. 

sendTelemetry() {
  key=$(cat .blueprint/.storage/telemetry_id);
  if [[ $key == "KEY_NOT_UPDATED" ]]; then exit 1;fi;
  curl --location --silent "http://data.ptero.shop:3481/send/$key/$1" > /dev/null;
}
