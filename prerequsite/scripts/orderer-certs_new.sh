#!/bin/sh
set -eu

echo "===> Thiết lập thư mục gốc cho CA client admin"
export FABRIC_CA_CLIENT_HOME=/organizations/ordererOrganizations/example.com/admin
mkdir -p "$FABRIC_CA_CLIENT_HOME"

CA_TLS_CERT=/organizations/fabric-ca/ordererOrg/tls-cert.pem

if [ ! -f "$CA_TLS_CERT" ]; then
  echo "❌ Không tìm thấy TLS cert: $CA_TLS_CERT"
  exit 1
fi

echo "===> Enroll Admin để lấy MSP"
fabric-ca-client enroll \
  -u https://admin:adminpw@ca-orderer:10054 \
  --caname ca-orderer \
  --tls.certfiles "$CA_TLS_CERT"

if [ ! -f "$FABRIC_CA_CLIENT_HOME/msp/signcerts/cert.pem" ]; then
  echo "❌ Enroll admin thất bại: Không tìm thấy cert.pem"
  exit 1
fi

echo "===> Ghi config.yaml cho NodeOUs"

# Tạo thư mục msp nếu chưa có
mkdir -p /organizations/ordererOrganizations/example.com/msp  # <-- thêm dòng này

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

echo "===> Đăng ký orderer nodes và admin"
for name in orderer orderer2 orderer3 orderer4 orderer5; do
  fabric-ca-client register \
    --caname ca-orderer \
    --id.name "$name" \
    --id.secret ordererpw \
    --id.type orderer \
    --tls.certfiles "$CA_TLS_CERT" || echo "⚠️  $name đã được đăng ký từ trước"
done

fabric-ca-client register \
  --caname ca-orderer \
  --id.name ordererAdmin \
  --id.secret ordererAdminpw \
  --id.type admin \
  --tls.certfiles "$CA_TLS_CERT" || echo "⚠️  ordererAdmin đã được đăng ký từ trước"

echo "===> Tạo thư mục người dùng"
mkdir -p /organizations/ordererOrganizations/example.com/users/Admin@example.com

echo "===> Enroll ordererAdmin"
export FABRIC_CA_CLIENT_HOME=/organizations/ordererOrganizations/example.com/users/Admin@example.com
fabric-ca-client enroll \
  -u https://ordererAdmin:ordererAdminpw@ca-orderer:10054 \
  --caname ca-orderer \
  --tls.certfiles "$CA_TLS_CERT"

cp /organizations/ordererOrganizations/example.com/msp/config.yaml \
   /organizations/ordererOrganizations/example.com/users/Admin@example.com/msp/config.yaml

echo "===> Enroll các orderer node (MSP và TLS)"
for name in orderer orderer2 orderer3 orderer4 orderer5; do
  echo "-> Enroll $name (MSP + TLS)"
  ORDERER_DIR=/organizations/ordererOrganizations/example.com/orderers/${name}.example.com
  export FABRIC_CA_CLIENT_HOME=/organizations/ordererOrganizations/example.com

  mkdir -p "$ORDERER_DIR"

  # Enroll MSP
  fabric-ca-client enroll \
    -u https://$name:ordererpw@ca-orderer:10054 \
    --caname ca-orderer \
    -M "$ORDERER_DIR/msp" \
    --csr.hosts "$name.example.com" \
    --csr.hosts localhost \
    --tls.certfiles "$CA_TLS_CERT"

  cp /organizations/ordererOrganizations/example.com/msp/config.yaml \
     "$ORDERER_DIR/msp/config.yaml"

  # Enroll TLS
  fabric-ca-client enroll \
    -u https://$name:ordererpw@ca-orderer:10054 \
    --caname ca-orderer \
    -M "$ORDERER_DIR/tls" \
    --enrollment.profile tls \
    --csr.hosts "$name.example.com" \
    --csr.hosts localhost \
    --tls.certfiles "$CA_TLS_CERT"

  # Copy TLS files
  cp "$ORDERER_DIR/tls/tlscacerts/"* "$ORDERER_DIR/tls/ca.crt"
  cp "$ORDERER_DIR/tls/signcerts/"* "$ORDERER_DIR/tls/server.crt"
  cp "$ORDERER_DIR/tls/keystore/"* "$ORDERER_DIR/tls/server.key"

  # Copy vào msp/tlscacerts
  mkdir -p "$ORDERER_DIR/msp/tlscacerts"
  cp "$ORDERER_DIR/tls/tlscacerts/"* "$ORDERER_DIR/msp/tlscacerts/tlsca.example.com-cert.pem"

  # Copy vào org msp
  mkdir -p /organizations/ordererOrganizations/example.com/msp/tlscacerts
  cp "$ORDERER_DIR/tls/tlscacerts/"* /organizations/ordererOrganizations/example.com/msp/tlscacerts/tlsca.example.com-cert.pem

done

echo "✅ Tạo chứng chỉ orderer thành công"