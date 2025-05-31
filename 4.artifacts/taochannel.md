- sau khi chạy jonb tạo channel thì sẽ tạo ra các file out (channel.tx)
 


 ==> tạo channel từ channel
peer channel create \
  -o orderer:7050 \
  -c thoaitest2 \
  -f /channel-artifacts/thoaitest2.tx \
  --outputBlock /channel-artifacts/thoaitest2.block \
  --tls \
  --cafile /organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt


peer channel join -b /channel-artifacts/thoaitest2.block


configtxgen   -profile TwoOrgsChannel   -outputAnchorPeersUpdate ./channel-artifacts/Org3MSPanchors.tx   -channelID thoaitest   -asOrg Org3MSP

==== muốn update peer join vào channel ví dụ peer 3 ( khi update job thiếu)

peer channel update \
  -o orderer:7050 \
  --ordererTLSHostnameOverride orderer.example.com \
  -c thoaitest \
  -f ./channel-artifacts/Org3MSPanchors.tx \
  --tls \
  --cafile /organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt