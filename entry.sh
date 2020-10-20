#!/bin/bash

SIMULATION_ID="${1}"
S3_BUCKET_ARN="${2}"

aws s3 cp "s3://${S3_BUCKET_ARN}/${SIMULATION_ID}.dat" ./ && \
./model "${SIMULATION_ID}.dat" "${SIMULATION_ID}.csv" && \
cat "${SIMULATION_ID}.csv"
