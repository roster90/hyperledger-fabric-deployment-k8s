chmod +x scripts/ -R
mkdir organizations
cp -rf  fabric-ca/ ./organizations/ 


(cấp quyền để có thể ghi cert )
chmod 777 organizations/ -R

- run các container cấp cert kubectl 