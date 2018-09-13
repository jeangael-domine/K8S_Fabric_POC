#!/bin/bash +x

CHANNEL_NAME=$1
: ${CHANNEL_NAME:="mychannel"}

export CONFIG_PATH=$PWD
export FABRIC_CFG_PATH=$PWD

## Generates Org certs
function generateCerts (){
	cryptogen generate --config=./cluster-config.yaml	
}

function generateChannelArtifacts() {
	if [ ! -d channel-artifacts ]; then
		mkdir channel-artifacts
	fi

	configtxgen -profile TwoOrgsOrdererGenesis -outputBlock ./channel-artifacts/genesis.block
# 	$CONFIGTXGEN -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID $CHANNEL_NAME
#	$CONFIGTXGEN -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org1MSP
# 	$CONFIGTXGEN -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org2MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org2MSP
# 	$CONFIGTXGEN -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org3MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org3MSP
	
	chmod -R 777 ./channel-artifacts && chmod -R 777 ./crypto-config

	cp ./channel-artifacts/genesis.block ./crypto-config/ordererOrganizations/*

	cp -r ./crypto-config /opt/share/ && cp -r ./channel-artifacts /opt/share/
	#/opt/share mouts the remote /opt/share from nfs server
}

function generateK8sYaml (){
	python3.5 transform/generate.py
}

function clean () {
	rm -rf /opt/share/crypto-config/*
	rm -rf crypto-config
}

clean
generateCerts
generateChannelArtifacts
generateK8sYaml
