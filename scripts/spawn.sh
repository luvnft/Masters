#!/bin/bash
set -euo pipefail
pushd $(dirname "$0")/..

: "${RPC_URL:?Environment variable RPC_URL must be set}"

export WORLD_ADDRESS=$(cat ./manifests/dev/manifest.json | jq -r '.world.address')

# export ACTIONS_ADDRESS=$(cat ./manifests/deployments/KATANA.json | jq -r '.contracts[] | select(.name == "warpack_masters::systems::actions::actions" ).address')
export ACTIONS_ADDRESS='0x591fe4c5c0987dfd20e14e82875494699eda1e47c68c98801df329424e1bb03'


echo "---------------------------------------------------------------------------"
echo world : $WORLD_ADDRESS
echo " "
echo actions : $ACTIONS_ADDRESS
echo "---------------------------------------------------------------------------"

sozo execute --world $WORLD_ADDRESS $ACTIONS_ADDRESS spawn -c 0x616c696365,0 --wait --rpc-url $RPC_URL \
	--account-address 0x24564a69b21a2683b82b0211644577213644b1d832b50b444df2c40e0f5253b \
	--private-key 0x7957b76cecb7995b071c16120243268a64e6fa8cf5310d30400b56d7de97adc
