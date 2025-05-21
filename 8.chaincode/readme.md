-- đóng gói chain code 
tar cfz code.tar.gz connection.json    ==> tạo một file nén code.tar.gz chứa file connection.json
( kiểm tra lại connection.json cho đúng với org)
tar cfz basic-org1.tgz code.tar.gz metadata.json    ==> tạo package chaincode dạng external Đưa code.tar.gz (mã chaincode hoặc connection profile)

sau đó xoá code.tar.gz

rm code.tar.gz

+ sửa connection.json ( -> org2)

tar cfz code.tar.gz connection.json 
tar cfz basic-org2.tgz code.tar.gz metadata.json 

rm code.tar.gz

+ sửa connection.json ( -> org3)

tar cfz code.tar.gz connection.json 
tar cfz basic-org2.tgz code.tar.gz metadata.json 

rm code.tar.gz

-- cài đặt chain code 

excute vào peer cli để cài đặt chaincode
- peer1-cli
cd /opt/gopath/src/github.com/chaincode/
cd basic/packaging/

peer lifecycle chaincode install basic-org1.tgz
==> Package ID: basic:af7247f9da8c7da7d661c9a9ddf19a95bb1a10710dde531f4fc0b85f8615ae1a,

- peer2-cli: 
cd /opt/gopath/src/github.com/chaincode/
cd basic/packaging/

peer lifecycle chaincode install basic-org2.tgz
==> Chaincode code package identifier: basic:70b6347145889605c4b555ed61413b45a8cbdf408ee7941cfc079212ea43b2ef

- peer3-cli: 
cd /opt/gopath/src/github.com/chaincode/
cd basic/packaging/

peer lifecycle chaincode install basic-org3.tgz
==> Chaincode code package identifier: basic:d63e82f78a88e0d59a565f9a250324ba0b496733f6083a7923d53aa9c89d8022


+ muốn lấy lại các chain code đã cài  đặt có thể dùng query: 
peer lifecycle chaincode queryinstalled

- create chaincode and deployment
 folder 9

- approve chain code 

peer-cli 1, : run command

peer lifecycle chaincode approveformyorg \
  --channelID mychannel \
  --name basic \
  --version 1.0 \
  --init-required \
  --package-id basic:af7247f9da8c7da7d661c9a9ddf19a95bb1a10710dde531f4fc0b85f8615ae1a \
  --sequence 1 \
  -o orderer:7050 \
  --tls \
  --cafile $ORDERER_CA





==> xác minh approve

peer lifecycle chaincode checkcommitreadiness \
  --channelID mychannel \
  --name basic \
  --version 1.0 \
  --sequence 1 \
  --init-required \
  --output json



cli 2

peer lifecycle chaincode approveformyorg \
  --channelID mychannel \
  --name basic \
  --version 1.0 \
  --init-required \
  --package-id basic:70b6347145889605c4b555ed61413b45a8cbdf408ee7941cfc079212ea43b2ef \
  --sequence 1 \
  -o orderer:7050 \
  --tls \
  --cafile $ORDERER_CA


peer-cli3:

peer lifecycle chaincode approveformyorg \
  --channelID mychannel \
  --name basic \
  --version 1.0 \
  --init-required \
  --package-id basic:d63e82f78a88e0d59a565f9a250324ba0b496733f6083a7923d53aa9c89d8022 \
  --sequence 1 \
  -o orderer:7050 \
  --tls \
  --cafile $ORDERER_CA


--- commit chain code
peer lifecycle chaincode commit \
  --channelID mychannel \
  --name basic \
  --version 1.0 \
  --sequence 1 \
  --init-required \
  --tls \
  --peerAddresses peer0-org1:7051 \
    --tlsRootCertFiles /organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt \
  --peerAddresses peer0-org2:7051 \
    --tlsRootCertFiles /organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt \
  --peerAddresses peer0-org3:7051 \
    --tlsRootCertFiles /organizations/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls/ca.crt \
  -o orderer:7050 \
  --tls \
  --cafile $ORDERER_CA



peer lifecycle chaincode querycommitted --channelID mychannel


-- transaction invocation



-----init initLedger command -------
peer chaincode invoke -o orderer:7050 \

--isInit --tls --cafile $ORDERER_CA -C mychannel -n basic \
 --peerAddresses peer0-org1:7051 \
    --tlsRootCertFiles /organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt \
  --peerAddresses peer0-org2:7051 \
    --tlsRootCertFiles /organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt \
  --peerAddresses peer0-org3:7051 \
    --tlsRootCertFiles /organizations/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls/ca.crt \
-c '{"Args": ["initLedger"]}' --waitForEvent



-- query chain code

peer chaincode query -C mychannel -n basic -c '{"Args":["GetAllAssets"]}'




--- test invoke command: create assets 
peer chaincode invoke -o orderer:7050 \
--tls --cafile $ORDERER_CA -C mychannel -n basic \
 --peerAddresses peer0-org1:7051 \
    --tlsRootCertFiles /organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt \
  --peerAddresses peer0-org2:7051 \
    --tlsRootCertFiles /organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt \
  --peerAddresses peer0-org3:7051 \
    --tlsRootCertFiles /organizations/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls/ca.crt \
-c '{"Args": ["CreateAsset", "asset101", "red", "99", "tom", "300"]}' --waitForEvent