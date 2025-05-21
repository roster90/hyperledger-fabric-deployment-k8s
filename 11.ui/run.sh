

docker buildx build --platform linux/amd64 -t metafi/hlk-k8s:1.0.1 --load .

docker buildx build --platform linux/amd64,linux/arm64 -t metafi/hlk-k8s:1.0.1 --push .

docker push metafi/hlk-k8s:1.0.1