#!/bin/bash

SIMULATION_ID="${1}"
S3_BUCKET_ARN="${2}"

INPUT_FILE="${SIMULATION_ID}.dat"
OUTPUT_FILE="${SIMULATION_ID}.csv"

aws s3 cp "s3://${S3_BUCKET_ARN}/${INPUT_FILE}" ./ && \
./model "${INPUT_FILE}" "${OUTPUT_FILE}" && \
aws s3 cp "${OUTPUT_FILE}" "s3://${S3_BUCKET_ARN}/${OUTPUT_FILE}"