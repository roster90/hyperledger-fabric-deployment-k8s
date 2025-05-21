- trong dự án lớn thì tách couchDB thành deployment và service riêng



-excute vào pod peer-cli : chạy tạo App chanel
 ./scripts/createAppChannel.sh

 - join peer vào channel

 - trong pod peer cli 1, 2,3
peer channel join -b ./channel-artifacts/mychannel.block 
