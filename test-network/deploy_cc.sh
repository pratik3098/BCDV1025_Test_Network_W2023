#!/bin/bash 
set -e

PEER_BINARY=/usr/local/bin/peer
CURR_DIR=$PWD
CC_CHANNEL=$1
CC_NAME=basic

if [ -f "$PEER_BINARY" ]; then
    echo "Peer binary already exists."
else 
    cp ../bin/peer /usr/local/bin/
fi


chmod 777 $PEER_BINARY


npm install -g n

n install stable 

cd ../asset-transfer-basic/chaincode-javascript/

npm install

cd $CURR_DIR

export PATH=${PWD}/../bin:$PATH

export FABRIC_CFG_PATH=$PWD/../config/




peer lifecycle chaincode package $CC_NAME.tar.gz --path ../asset-transfer-basic/chaincode-javascript/ --lang node --label $CC_NAME_1.0


export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051


peer lifecycle chaincode install $CC_NAME.tar.gz 


peer lifecycle chaincode  queryinstalled


export CC_PACKAGE_ID=${CC_NAME}_1.0:63b006c30c10da8011464e4749e3c5a235ac8eb22e0d71ceb9078f401deef8c7


peer lifecycle chaincode approveformyorg --name $CC_NAME --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 --waitForEvent  --channelID $CC_CHANNEL --channel-config-policy Channel/Application/LifecycleEndorsements -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com   --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem"


peer lifecycle chaincode checkcommitreadiness --channelID $CC_CHANNEL --name $CC_NAME --version 1.0 --sequence 1 --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" --output json







## Steps for Org2 Approvals

export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_ADDRESS=localhost:9051

