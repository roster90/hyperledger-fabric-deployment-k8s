# External Builder và Launcher trong Hyperledger Fabric 2.x

Trong Hyperledger Fabric 2.x, External Builder và Launcher là một cơ chế cho phép bạn tùy biến quá trình build và chạy chaincode, đặc biệt hữu ích khi bạn triển khai chaincode bằng các công cụ hoặc môi trường ngoài Docker (ví dụ: chạy chaincode như một process riêng – "chaincode as external service").

## 1. Tại sao cần External Builder/Launcher?

Mặc định, Fabric sử dụng Docker để build và chạy chaincode. Nhưng trong môi trường như Kubernetes, bạn có thể muốn:

- Không dùng Docker-in-Docker (DIND)
- Kiểm soát tốt hơn môi trường runtime (debug, log, perf)
- Tự quản lý quá trình build chaincode (Go, Java, Node.js hoặc ngôn ngữ khác)
- Triển khai chaincode như một microservice riêng biệt (external chaincode service)

## 2. External Builder là gì?

External Builder là một plugin tùy biến để định nghĩa cách:

- **Detect**: xác định một source code có hợp lệ không
- **Build**: cách build mã nguồn đó
- **Release**: cách tạo ra artifact mà Fabric peer hiểu được

## 3. External Launcher là gì?

Launcher chỉ định cách Fabric peer chạy chaincode.

Với chaincode kiểu "external" (chaincode chạy bên ngoài peer), launcher sẽ không dùng Docker mà sẽ:

- Tạo một connection đến service chaincode đang chạy qua gRPC
- Dùng các biến môi trường để truyền thông tin về chaincode ID, peer, v.v.

Chaincode cần implement giao thức gRPC (shim.ChaincodeServer) để nói chuyện với peer.

## 4. Cấu hình External Builder/Launcher

Trong `core.yaml` của peer:

```yaml
chaincode:
  externalBuilders:
    - name: myBuilder
      path: /builders/myBuilder
      environmentWhitelist:
        - GOPROXY
        - GOCACHE
  runtime:
    type: external
```

Với chaincode kiểu external, khi deploy bạn chỉ cần chỉ định `"type": "external"` trong `metadata.json`.

## 5. Chaincode as external service

Khi dùng chaincode như service:

- Peer không build/không launch chaincode
- Bạn phải tự build, deploy và start chaincode như một service có gRPC server
- Peer chỉ kết nối qua gRPC tới địa chỉ `CHAINCODE_SERVER_ADDRESS` mà bạn đã export

## 6. Quy trình tổng quát

1. Bạn package chaincode có `metadata.json` chứa `"type": "external"`
2. Peer gọi detect → nếu pass, gọi build và release
3. Bạn deploy chaincode như service (bên ngoài peer)
4. Chaincode và peer kết nối qua gRPC (theo `CHAINCODE_SERVER_ADDRESS`)

## 7. Use case tiêu biểu

- Chaincode viết bằng Rust, Python, hoặc ngôn ngữ không hỗ trợ chính thức
- Debug chaincode trực tiếp bằng IDE
- Deploy chaincode trong Kubernetes Pod độc lập (theo kiến trúc microservice)