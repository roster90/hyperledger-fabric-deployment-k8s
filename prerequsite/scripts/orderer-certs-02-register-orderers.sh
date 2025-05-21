#!/bin/sh

set -e

# Biến môi trường dùng cho admin khi gọi fabric-ca-client
export FABRIC_CA_CLIENT_HOME=/organizations/ordererOrganizations/example.com/admin

ORG_DIR=/organizations/ordererOrganizations/example.com

echo "===> 🔐 Đăng ký orderer nodes và admin"

# Danh sách các node orderer
ORDERERS="orderer orderer2 orderer3 orderer4 orderer5"

# Đăng ký từng orderer
for ord in $ORDERERS; do
  echo "🔹 Đăng ký $ord"
  if fabric-ca-client register --caname ca-orderer \
    --id.name $ord \
    --id.secret ordererpw \
    --id.type orderer \
    --tls.certfiles /organizations/fabric-ca/ordererOrg/tls-cert.pem; then
    echo "✅  $ord đăng ký thành công"
  else
    echo "⚠️  $ord đã được đăng ký từ trước"
  fi
  echo ""
done

# Đăng ký ordererAdmin
echo "🔹 Đăng ký ordererAdmin"
if fabric-ca-client register --caname ca-orderer \
  --id.name ordererAdmin \
  --id.secret ordererAdminpw \
  --id.type admin \
  --tls.certfiles /organizations/fabric-ca/ordererOrg/tls-cert.pem; then
  echo "✅  ordererAdmin đăng ký thành công"
else
  echo "⚠️  ordererAdmin đã được đăng ký từ trước"
fi

# Enroll ordererAdmin để lấy chứng chỉ MSP
echo ""
echo "===> 📥 Enroll ordererAdmin"

ORDERER_ADMIN_DIR=$ORG_DIR/users/Admin@example.com
mkdir -p "$ORDERER_ADMIN_DIR"

export FABRIC_CA_CLIENT_HOME=$ORDERER_ADMIN_DIR

fabric-ca-client enroll \
  -u https://ordererAdmin:ordererAdminpw@ca-orderer:10054 \
  --caname ca-orderer \
  -M $ORDERER_ADMIN_DIR/msp \
  --tls.certfiles /organizations/fabric-ca/ordererOrg/tls-cert.pem

# Copy cấu hình OU
cp $ORG_DIR/msp/config.yaml $ORDERER_ADMIN_DIR/msp/config.yaml

echo ""
echo "✅  Hoàn tất enroll admin và đăng ký các orderer node"