# syntax=docker/dockerfile:1.3-labs
ARG DOCKER=dweomer/docker:20-dind
ARG PLUGIN=plugins/docker
FROM ${PLUGIN} AS drone
FROM ${DOCKER} AS plugin
COPY --from=drone /bin/drone-docker /bin/
RUN set -eux \
 && ln -vs /usr/bin/docker* /usr/local/bin/
ENV DOCKER_HOST="unix:///var/run/docker.sock"
ENTRYPOINT ["dockerd-entrypoint.sh", "drone-docker"]
