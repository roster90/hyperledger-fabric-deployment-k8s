Có 2 loại gọi hàm trong chaincode:
Query (chỉ đọc) => Trả về dữ liệu, không thay đổi blockchain => GetAsset("asset1")
Invoke (ghi) => Thực hiện thay đổi, sinh ra transaction → được commit CreateAsset("asset1", "blue", "Tom")

Cách hoạt động của 1 Transaction Invocation
	1.	Client SDK hoặc peer chaincode invoke:
	•	Gửi yêu cầu đến 1 hoặc nhiều peer để simulate.
	2.	Peer:
	•	Chạy hàm trong chaincode → kiểm tra endorsement policy.
	•	Nếu đúng policy → trả về proposal response (endorsement).
	3.	Client gửi đến Orderer:
	•	Orderer xếp hàng và phân phát transaction cho các peer qua block.
	4.	Peer commit:
	•	Mỗi peer xác thực lại → nếu hợp lệ thì ghi vào ledger.