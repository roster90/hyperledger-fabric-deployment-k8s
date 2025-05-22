# Hướng dẫn Triển khai Chaincode

## 1. Đóng gói Chaincode

### Bước 1: Tạo package cho Org1
```bash
# Tạo file nén chứa connection.json
tar cfz code.tar.gz connection.json

# Tạo package chaincode dạng external
tar cfz basic-org1.tgz code.tar.gz metadata.json

# Xóa file tạm
rm code.tar.gz
```

### Bước 2: Tạo package cho Org2
```bash
# Sửa connection.json cho org2
# Tạo file nén
tar cfz code.tar.gz connection.json

# Tạo package
tar cfz basic-org2.tgz code.tar.gz metadata.json

# Xóa file tạm
rm code.tar.gz
```

### Bước 3: Tạo package cho Org3
```bash
# Sửa connection.json cho org3
# Tạo file nén
tar cfz code.tar.gz connection.json

# Tạo package
tar cfz basic-org3.tgz code.tar.gz metadata.json

# Xóa file tạm
rm code.tar.gz
```

## 2. Cài đặt Chaincode

### Peer1 (Org1)
```bash
cd /opt/gopath/src/github.com/chaincode/basic/packaging/
peer lifecycle chaincode install basic-org1.tgz
# Package ID: basic:af7247f9da8c7da7d661c9a9ddf19a95bb1a10710dde531f4fc0b85f8615ae1a
```

### Peer2 (Org2)
```bash
cd /opt/gopath/src/github.com/chaincode/basic/packaging/
peer lifecycle chaincode install basic-org2.tgz
# Package ID: basic:70b6347145889605c4b555ed61413b45a8cbdf408ee7941cfc079212ea43b2ef
```

### Peer3 (Org3)
```bash
cd /opt/gopath/src/github.com/chaincode/basic/packaging/
peer lifecycle chaincode install basic-org3.tgz
# Package ID: basic:d63e82f78a88e0d59a565f9a250324ba0b496733f6083a7923d53aa9c89d8022
```

> **Lưu ý**: Để xem danh sách chaincode đã cài đặt:
> ```bash
> peer lifecycle chaincode queryinstalled
> ```

## 3. Phê duyệt Chaincode

### Peer1 (Org1)
```bash
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
```

### Peer2 (Org2)
```bash
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
```

### Peer3 (Org3)
```bash
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
```

> **Kiểm tra trạng thái phê duyệt**:
> ```bash
> peer lifecycle chaincode checkcommitreadiness \
>   --channelID mychannel \
>   --name basic \
>   --version 1.0 \
>   --sequence 1 \
>   --init-required \
>   --output json
> ```

## 4. Commit Chaincode
```bash
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
```

> **Kiểm tra trạng thái commit**:
> ```bash
> peer lifecycle chaincode querycommitted --channelID mychannel
> ```

## 5. Gọi Chaincode

### Khởi tạo Ledger
```bash
peer chaincode invoke -o orderer:7050 \
  --isInit --tls --cafile $ORDERER_CA -C mychannel -n basic \
  --peerAddresses peer0-org1:7051 \
    --tlsRootCertFiles /organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt \
  --peerAddresses peer0-org2:7051 \
    --tlsRootCertFiles /organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt \
  --peerAddresses peer0-org3:7051 \
    --tlsRootCertFiles /organizations/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls/ca.crt \
  -c '{"Args": ["initLedger"]}' --waitForEvent
```

### Query Chaincode
```bash
peer chaincode query -C mychannel -n basic -c '{"Args":["GetAllAssets"]}'
```

### Tạo Asset mới
```bash
peer chaincode invoke -o orderer:7050 \
  --tls --cafile $ORDERER_CA -C mychannel -n basic \
  --peerAddresses peer0-org1:7051 \
    --tlsRootCertFiles /organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt \
  --peerAddresses peer0-org2:7051 \
    --tlsRootCertFiles /organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt \
  --peerAddresses peer0-org3:7051 \
    --tlsRootCertFiles /organizations/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls/ca.crt \
  -c '{"Args": ["CreateAsset", "asset101", "red", "99", "tom", "300"]}' --waitForEvent
```