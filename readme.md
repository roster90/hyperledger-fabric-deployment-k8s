- tạo nfs server để chửa các resource dùng chung của network
chmod +x scripts/ -R
mkdir organizations
cp -rf  fabric-ca/ ./organizations/ 


(cấp quyền để có thể ghi cert )
chmod 777 organizations/ -R

- run các container cấp cert kubectl  (2.ca)

- chạy các job tao cert (3.certifcates)
- chạy các job tạo genesis, channel (4.artifacts)
- chạy các deployment service (5.orderer)
- tạo configMap (6.configmap)
- Chạy các node Peer (7.peers)
- chạy tạo App channel trong các peer, join peer vào channel, update channel (7) 

- chain code (8)

- 10 ui : run ./scripts/ccp.sh


