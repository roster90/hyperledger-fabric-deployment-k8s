

## nfs server: (143.198.24.143)


Sudo apt update


sudo apt install nfs-kernel-server


sudo mkdir -p /mnt/nfs_share
sudo chown -R nobody:nogroup /mnt/nfs_share/
sudo chmod 777 /mnt/nfs_share/


echo "/mnt/nfs_share *(rw,sync,no_subtree_check,insecure)" | sudo tee -a /etc/exports
/mnt/nfs_share	Đường dẫn thư mục sẽ được chia sẻ qua NFS
*	Cho phép mọi client truy cập (có thể thay bằng IP cụ thể như 192.168.1.0/24 để tăng bảo mật)
rw	Cho phép đọc và ghi
sync	Ghi đồng bộ, đảm bảo dữ liệu ghi xong mới trả kết quả
no_subtree_check	Không kiểm tra thư mục con (tăng hiệu năng)
insecure	Cho phép client kết nối từ cổng không chuẩn (non-privileged port)

sudo exportfs -a
sudo systemctl restart nfs-kernel-server
sudo exportfs -v

## NFS client Ubuntu ( client)
sudo apt update
sudo apt install nfs-common
sudo mkdir /mnt/nfs_clientshare

sudo mount 143.198.24.143:/mnt/nfs_share /mnt/nfs_clientshare


## NFS client MacOS 
#Set up client  //local machine ( mount nfs drive to local)

mkdir nfs_clientshare
sudo mount -o nolock -t nfs 143.198.24.143:/mnt/nfs_share ./nfs_clientshare