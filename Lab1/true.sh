
CONFIG_FILE="$1"
readarray -t SUBNETS < <(jq -c '.subnets[]' "$CONFIG_FILE")


for SUBNET in "${SUBNETS[@]}"; do   
    echo $SUBNET

done