#!/usr/bin/env bash

set -euo pipefail
# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
RESET='\033[0m'

TRANSFER_URL="https://channel.mifos.gazelle.test/channel/transfer"

function usage() {
  cat <<EOF
Usage: $0 [-p <payer_msisdn>] [-r <payee_msisdn>] [-t <tenant_id>] [-d <payee_dfsp_id>]

  -p  Payer MSISDN (default: 0413356886)       [optional]
  -r  Payee MSISDN (default: 0495822412)       [optional]
  -t  Platform-TenantId (default: greenbank)   [optional]
  -d  X-PayeeDFSP-ID (default: bluebank)       [optional]
  -h  Show this help message
EOF
}

# Defaults
payer_msisdn="0413356886"
payee_msisdn="0495822412"
tenant_id="greenbank"
payee_dfsp_id="bluebank"

# Parse options
while getopts ":p:r:t:d:h" opt; do
  case $opt in
    p) payer_msisdn="$OPTARG" ;;
    r) payee_msisdn="$OPTARG" ;;
    t) tenant_id="$OPTARG" ;;
    d) payee_dfsp_id="$OPTARG" ;;
    h) usage; exit 0 ;;
    \?) echo "Invalid option: -$OPTARG" >&2; usage; exit 1 ;;
    :) echo "Option -$OPTARG requires an argument." >&2; usage; exit 1 ;;
  esac
done

# Prompt for amount with validation
while true; do
  read -rp "Enter amount to transfer (0–500): " amount
  if [[ "$amount" =~ ^[0-9]+$ ]] && (( amount >= 0 && amount <= 500 )); then
    break
  else
    echo "❌ Invalid amount. Please enter a number between 0 and 500."
  fi
done

# Generate unique correlation ID
correlation_id=$(uuidgen)

# Build JSON payload
json_payload=$(cat <<EOF
{
  "payer": {
    "partyIdInfo": {
      "partyIdType": "MSISDN",
      "partyIdentifier": "$payer_msisdn"
    }
  },
  "payee": {
    "partyIdInfo": {
      "partyIdType": "MSISDN",
      "partyIdentifier": "$payee_msisdn"
    }
  },
  "amount": {
    "amount": $amount,
    "currency": "USD"
  }
}
EOF
)

# Perform cURL POST and capture HTTP status
echo "📤 Sending transfer request..."
response=$(curl -sk -w "\n%{http_code}" -X POST "$TRANSFER_URL" \
  -H "Platform-TenantId: $tenant_id" \
  -H "X-PayeeDFSP-ID: $payee_dfsp_id" \
  -H "X-CorrelationID: $correlation_id" \
  -H "Content-Type: application/json" \
  -H "Accept: */*" \
  -d "$json_payload")

# Parse response
http_body=$(echo "$response" | sed '$d')
http_code=$(echo "$response" | tail -n1)

# Check status
# Print result inline with status code
if [[ "$http_code" == "200" ]]; then
  echo -n "✅ Transfer successful (HTTP $http_code): "
  echo "$http_body"
else
  echo -n "❌ Transfer failed (HTTP $http_code): "
  echo "$http_body"
  echo -e "${RED} Note: for payments to be processed successfully Mifos Gazelle needs to be fully deployed and running  ${RESET}" 
  echo -e "${RED}       and the hosts added to your hosts file as documented in the MIFOS-GAZELLE-README.md under docs directory ${RESET}"
  exit 1
fi
