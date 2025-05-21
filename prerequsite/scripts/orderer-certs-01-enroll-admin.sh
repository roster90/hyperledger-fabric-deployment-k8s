#!/bin/sh

echo "===> Bước 1: Enroll Admin để lấy MSP"

# Tạo thư mục gốc cho tổ chức orderer
mkdir -p /organizations/ordererOrganizations/example.com/admin

# Thiết lập biến môi trường FABRIC_CA_CLIENT_HOME
export FABRIC_CA_CLIENT_HOME=/organizations/ordererOrganizations/example.com/admin

# Enroll admin để lấy chứng chỉ
fabric-ca-client enroll \
  -u https://admin:adminpw@ca-orderer:10054 \
  --caname ca-orderer \
  --tls.certfiles /organizations/fabric-ca/ordererOrg/tls-cert.pem

# Tạo file config.yaml cho NodeOUs
mkdir -p /organizations/ordererOrganizations/example.com/msp
cat <<EOF > /organizations/ordererOrganizations/example.com/msp/config.yaml
NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/ca-orderer-10054-ca-orderer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/ca-orderer-10054-ca-orderer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/ca-orderer-10054-ca-orderer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/ca-orderer-10054-ca-orderer.pem
    OrganizationalUnitIdentifier: orderer
EOF