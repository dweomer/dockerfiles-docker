# syntax=docker/dockerfile:1.3-labs
ARG ALPINE_IMAGE=alpine:3.14
ARG ALPINE_MIRROR="https://dl-cdn.alpinelinux.org/alpine"
ARG DOCKER_VERSION="20.10"
ARG ROOTFS=/scratch
FROM ${ALPINE_IMAGE} AS alpine

RUN set -eux \
 && apk --no-cache add \
    bash \
 && echo '. /etc/os-release' > /etc/profile.d/alpine-release.sh \
 && echo 'export VERSION_ID' >> /etc/profile.d/alpine-release.sh \
 && chmod +x /etc/profile.d/alpine-release.sh
SHELL ["/usr/bin/env", "bash","-c"]

FROM alpine AS init-docker
ARG ALPINE_MIRROR
ARG ALPINE_ARCH
ARG DOCKER_VERSION
ARG ROOTFS
RUN set -eux \
 && source /etc/profile.d/alpine-release.sh \
 && apk add \
        --allow-untrusted \
        --arch ${ALPINE_ARCH=$(apk --print-arch)} \
        --initdb \
        --root "${ROOTFS}" \
        --repository "${ALPINE_MIRROR}/v${VERSION_ID%.*}/main" \
        --repository "${ALPINE_MIRROR}/v${VERSION_ID%.*}/community" \
    ca-certificates \
    docker-cli~=${DOCKER_VERSION} \
    docker-cli-buildx \
    openssh-client \
 && apk --no-cache --root ${ROOTFS} stats

RUN <<EOF
    if [ ! -e "${ROOTFS}/etc/nsswitch.conf" ]; then
        echo 'hosts: files dns' > /etc/nsswitch.conf
    fi
EOF

ARG DOCKER_MODPROBE="https://raw.githubusercontent.com/docker-library/docker/a5154f6c2a1201211ae8792dcf1d4956439597db/20.10/modprobe.sh"
ARG DOCKER_ENTRYPOINT="https://raw.githubusercontent.com/docker-library/docker/a5154f6c2a1201211ae8792dcf1d4956439597db/20.10/docker-entrypoint.sh"
ADD "${DOCKER_MODPROBE}" ${ROOTFS}/usr/local/bin/modprobe
ADD "${DOCKER_ENTRYPOINT}" ${ROOTFS}/usr/local/bin/docker-entrypoint.sh
RUN set -eux \
 && chmod -v +x ${ROOTFS}/usr/local/bin/{modprobe,docker-entrypoint.sh}
RUN cat <<EOF > /sbin/clean.sh && chmod -v +x /sbin/clean.sh
#!/usr/bin/env bash
rm -rvf \
    ${ROOTFS}/{dev,proc,src,sys,tmp,var} \
    ${ROOTFS}/etc/apk \
    ${ROOTFS}/etc/logrotate.d \
    ${ROOTFS}/etc/netw* \
    ${ROOTFS}/etc/udhcpd.conf \
    ${ROOTFS}/lib/apk \
    "${@}"
EOF

FROM init-docker AS prep-docker
ARG ROOTFS
RUN set -eux \
 && clean.sh

FROM scratch AS docker
ARG ROOTFS
COPY --from=prep-docker ${ROOTFS}/ /
ARG DOCKER_TLS_CERTDIR=/certs
ENV DOCKER_TLS_CERTDIR="${DOCKER_TLS_CERTDIR}"
RUN set -eux \
 && mkdir -vp ${DOCKER_TLS_CERTDIR}/client \
 && chmod -v 1777 ${DOCKER_TLS_CERTDIR} ${DOCKER_TLS_CERTDIR}/client
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["sh"]

FROM init-docker AS init-dockerd
ARG ALPINE_MIRROR
ARG ALPINE_ARCH
ARG DOCKER_VERSION
ARG ROOTFS

ARG DOCKER_DIND="https://raw.githubusercontent.com/docker/docker/37498f009d8bf25fbb6199e8ccd34bed84f2874b/hack/dind"
ARG DOCKERD_ENTRYPOINT="https://raw.githubusercontent.com/docker-library/docker/a5154f6c2a1201211ae8792dcf1d4956439597db/20.10/dind/dockerd-entrypoint.sh"
ADD "${DOCKER_DIND}" ${ROOTFS}/usr/local/bin/dind
ADD "${DOCKERD_ENTRYPOINT}" ${ROOTFS}/usr/local/bin/dockerd-entrypoint.sh
RUN set -eux \
 && chmod -v +x ${ROOTFS}/usr/local/bin/{dind,dockerd-entrypoint.sh}

RUN set -eux \
 && source /etc/profile.d/alpine-release.sh \
 && apk add \
        --allow-untrusted \
        --arch ${ALPINE_ARCH=$(apk --print-arch)} \
        --root "${ROOTFS}" \
        --repository "${ALPINE_MIRROR}/v${VERSION_ID%.*}/main" \
        --repository "${ALPINE_MIRROR}/v${VERSION_ID%.*}/community" \
        alpine-baselayout \
		btrfs-progs \
        docker-engine~=${DOCKER_VERSION} \
		e2fsprogs \
		e2fsprogs-extra \
		iptables \
		openssl \
		pigz \
		shadow-uidmap \
		xfsprogs \
		xz \
 && apk --no-cache --root ${ROOTFS} stats

RUN <<EOF
set -eux
source /etc/profile.d/alpine-release.sh
for tar in ${ROOTFS}/var/cache/apk/APKINDEX.*.tar.gz; do
    mkdir ${tar%*.tar.gz}
    tar xzf ${tar} -C ${tar%*.tar.gz}
done
if grep 'T:ZFS' -H ${ROOTFS}/var/cache/apk/APKINDEX.*/APKINDEX; then
    apk add \
        --allow-untrusted \
        --arch ${ALPINE_ARCH=$(apk --print-arch)} \
        --root "${ROOTFS}" \
        --repository "${ALPINE_MIRROR}/v${VERSION_ID%.*}/main" \
        --repository "${ALPINE_MIRROR}/v${VERSION_ID%.*}/community" \
        zfs
fi
EOF

FROM init-dockerd AS prep-dockerd
ARG ROOTFS
RUN set -eux \
 && apk --no-cache --root ${ROOTFS} stats \
 && clean.sh

FROM scratch AS dockerd
ARG ROOTFS
COPY --from=prep-dockerd ${ROOTFS}/ /
ARG DOCKER_TLS_CERTDIR=/certs
ENV DOCKER_TLS_CERTDIR="${DOCKER_TLS_CERTDIR}"
RUN set -eux \
 && mkdir -vp ${DOCKER_TLS_CERTDIR}/client \
 && chmod -v 1777 ${DOCKER_TLS_CERTDIR} ${DOCKER_TLS_CERTDIR}/client \
 && addgroup -S dockremap \
 && adduser -S -G dockremap dockremap \
 && echo 'dockremap:165536:65536' >> /etc/subuid \
 && echo 'dockremap:165536:65536' >> /etc/subgid

VOLUME /var/lib/docker
EXPOSE 2375 2376

ENTRYPOINT ["dockerd-entrypoint.sh"]
CMD []
