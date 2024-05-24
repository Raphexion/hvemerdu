#!/usr/bin/env bash

set -e

curl --header "Content-Type: application/json" \
     --request POST \
     --data "{\"code\":\"${1}\"}" \
     https://hvemerdu.dk/v1/unsafe-acks
