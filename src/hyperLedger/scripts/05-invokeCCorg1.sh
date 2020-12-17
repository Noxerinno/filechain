

ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/myapp.com/orderers/orderer0.myapp.com/tls/MyCertificate.crt
CORE_PEER_LOCALMSPID="Org1MSP"
# En este certificado me contecto al peer
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/tlsca.org1.example.com.crt.pem
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
CORE_PEER_ADDRESS=${IP_PEER}:7051
CHANNEL_NAME=channel1
CORE_PEER_TLS_ENABLED=false

peer chaincode invoke -o orderer0.myapp.com:7050   -C $CHANNEL_NAME -n mycontract2 -c '{"Args":["invoke","a","b","10"]}' >&log.txt
cat log.txt
