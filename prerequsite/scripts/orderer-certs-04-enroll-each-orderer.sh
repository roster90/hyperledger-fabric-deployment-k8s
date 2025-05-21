#!/bin/sh

for i in 1 2 3 4 5; do
  host="orderer${i}.example.com"
  dir="/organizations/ordererOrganizations/example.com/orderers/${host}"

  echo "===> Tạo thư mục cho $host"
  mkdir -p ${dir}

  echo "===> Enroll $host để lấy MSP"
  fabric-ca-client enroll \
    -u https://orderer:ordererpw@ca-orderer:10054 \
    --caname ca-orderer \
    -M ${dir}/msp \
    --csr.hosts ${host} \
    --csr.hosts localhost \
    --csr.hosts ca-orderer \
    --csr.hosts orderer${i} \
    --tls.certfiles /organizations/fabric-ca/ordererOrg/tls-cert.pem

  cp /organizations/ordererOrganizations/example.com/msp/config.yaml ${dir}/msp/config.yaml

  echo "===> Enroll TLS cho $host"
  fabric-ca-client enroll \
    -u https://orderer:ordererpw@ca-orderer:10054 \
    --caname ca-orderer \
    -M ${dir}/tls \
    --enrollment.profile tls \
    --csr.hosts ${host} \
    --csr.hosts localhost \
    --csr.hosts ca-orderer \
    --csr.hosts orderer${i} \
    --tls.certfiles /organizations/fabric-ca/ordererOrg/tls-cert.pem

  cp ${dir}/tls/tlscacerts/* ${dir}/tls/ca.crt
  cp ${dir}/tls/signcerts/*  ${dir}/tls/server.crt
  cp ${dir}/tls/keystore/*   ${dir}/tls/server.key

  mkdir -p ${dir}/msp/tlscacerts
  cp ${dir}/tls/tlscacerts/* ${dir}/msp/tlscacerts/tlsca.example.com-cert.pem

  mkdir -p /organizations/ordererOrganizations/example.com/msp/tlscacerts
  cp ${dir}/tls/tlscacerts/* /organizations/ordererOrganizations/example.com/msp/tlscacerts/tlsca.example.com-cert.pem
done