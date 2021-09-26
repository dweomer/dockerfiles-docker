#!/usr/bin/env bash
set -eux
docker buildx build --platform linux/amd64  --push --tag dweomer/docker:20.10-dind-amd64 --tag dweomer/docker:20-dind-amd64 --build-arg ALPINE_ARCH=x86_64  --target=dockerd --progress=plain --no-cache $(dirname $0)/.
docker buildx build --platform linux/amd64  --push --tag dweomer/docker:20.10-amd64      --tag dweomer/docker:20-amd64      --build-arg ALPINE_ARCH=x86_64  --target=docker  --progress=plain            $(dirname $0)/.

docker buildx build --platform linux/arm64  --push --tag dweomer/docker:20.10-dind-arm64 --tag dweomer/docker:20-dind-arm64 --build-arg ALPINE_ARCH=aarch64 --target=dockerd --progress=plain --no-cache $(dirname $0)/.
docker buildx build --platform linux/arm64  --push --tag dweomer/docker:20.10-arm64      --tag dweomer/docker:20-arm64      --build-arg ALPINE_ARCH=aarch64 --target=docker  --progress=plain            $(dirname $0)/.

docker buildx build --platform linux/arm/v7 --push --tag dweomer/docker:20.10-dind-armv7 --tag dweomer/docker:20-dind-armv7 --build-arg ALPINE_ARCH=armv7   --target=dockerd --progress=plain --no-cache $(dirname $0)/.
docker buildx build --platform linux/arm/v7 --push --tag dweomer/docker:20.10-armv7      --tag dweomer/docker:20-armv7      --build-arg ALPINE_ARCH=armv7   --target=docker  --progress=plain            $(dirname $0)/.

docker buildx build --platform linux/arm/v6 --push --tag dweomer/docker:20.10-dind-armv6 --tag dweomer/docker:20-dind-armv6 --build-arg ALPINE_ARCH=armhf   --target=dockerd --progress=plain --no-cache $(dirname $0)/.
docker buildx build --platform linux/arm/v6 --push --tag dweomer/docker:20.10-armv6      --tag dweomer/docker:20-armv6      --build-arg ALPINE_ARCH=armhf   --target=docker  --progress=plain            $(dirname $0)/.
