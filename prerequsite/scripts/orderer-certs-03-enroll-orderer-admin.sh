#!/bin/sh

echo "===> Tạo thư mục người dùng"
mkdir -p /organizations/ordererOrganizations/example.com/users/Admin@example.com

export FABRIC_CA_CLIENT_HOME=/organizations/ordererOrganizations/example.com/users/Admin@example.com

echo "===> Enroll ordererAdmin"
fabric-ca-client enroll \
  -u https://ordererAdmin:ordererAdminpw@ca-orderer:10054 \
  --caname ca-orderer \
  --tls.certfiles /organizations/fabric-ca/ordererOrg/tls-cert.pem

cp /organizations/ordererOrganizations/example.com/msp/config.yaml \
   /organizations/ordererOrganizations/example.com/users/Admin@example.com/msp/config.yaml