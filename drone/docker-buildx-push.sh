#!/usr/bin/env bash
set -eux

declare -x PLATFORM=linux/amd64
declare -x PLUGIN=plugins/docker:linux-amd64
declare -x DOCKER=dweomer/docker:20-dind-amd64
docker buildx build --no-cache --progress=plain --push \
	--platform ${PLATFORM} \
	--build-arg DOCKER=${DOCKER} \
	--build-arg PLUGIN=${PLUGIN} \
	--tag dweomer/drone-plugins-docker:linux-amd64 \
$(dirname $0)/.

declare -x PLATFORM=linux/arm64
declare -x PLUGIN=plugins/docker:linux-arm64
declare -x DOCKER=dweomer/docker:20-dind-arm64
docker buildx build --no-cache --progress=plain --push \
	--platform ${PLATFORM} \
	--build-arg DOCKER=${DOCKER} \
	--build-arg PLUGIN=${PLUGIN} \
	--tag dweomer/drone-plugins-docker:linux-arm64 \
$(dirname $0)/.

declare -x PLATFORM=linux/arm/v7
declare -x PLUGIN=plugins/docker:linux-arm
declare -x DOCKER=dweomer/docker:20-dind-armv7
docker buildx build --no-cache --progress=plain --push \
	--platform ${PLATFORM} \
	--build-arg DOCKER=${DOCKER} \
	--build-arg PLUGIN=${PLUGIN} \
	--tag dweomer/drone-plugins-docker:linux-arm \
$(dirname $0)/.
