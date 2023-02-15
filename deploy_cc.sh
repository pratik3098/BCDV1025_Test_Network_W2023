#!/bin/bash 
set -e

PEER_BINARY=/usr/local/bin/peer
CURR_DIR=$PWD
CC_CHANNEL=$1
CC_NAME=basic
CC_VER=1.0

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




peer lifecycle chaincode package ${CC_NAME}.tar.gz --path ../asset-transfer-basic/chaincode-javascript/ --lang node --label ${CC_NAME}_${CC_VER}


export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051


peer lifecycle chaincode install ${CC_NAME}.tar.gz 


peer lifecycle chaincode  queryinstalled


export CC_PACKAGE_ID=$(peer lifecycle chaincode  queryinstalled | grep Package | cut -d ',' -f1 | cut -d ' ' -f3)

peer lifecycle chaincode approveformyorg --name $CC_NAME --version ${CC_VER} --package-id $CC_PACKAGE_ID --sequence 1 --waitForEvent  --channelID $CC_CHANNEL --channel-config-policy Channel/Application/LifecycleEndorsement -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com   --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem"


peer lifecycle chaincode checkcommitreadiness --channelID ${CC_CHANNEL} --name ${CC_NAME} --version ${CC_VER} --sequence 1 --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" --output json


peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID ${CC_CHANNEL} --name ${CC_NAME} --version ${CC_VER} --sequence 1 --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt"



## Repeat the same steps for Org2


