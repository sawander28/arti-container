ARG IMAGE_TAG=bookworm
FROM docker.io/rust:slim-${IMAGE_TAG} AS build

# Install dependencies
RUN apt-get update && \
    apt-get install -y \
    pkg-config \
    libssl-dev \
    libsqlite3-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Arti
RUN cargo install arti --features=onion-service-service

FROM containers.torproject.org/tpo/tpa/base-images/debian:${IMAGE_TAG} AS arti

ENV APP="arti"
ENV APP_BASE="/srv/"

# UID and GID might be read-only values, so use non-conflicting ones
ARG ARTI_USER="arti"
ARG CONTAINER_UID="${CONTAINER_UID:-1000}"
ARG CONTAINER_GID="${CONTAINER_GID:-1000}"

ENV ARTI_CONFIG="${ARTI_CONFIG:-/srv/arti/configs/onionservice.toml}"

RUN apt-get update && \
    apt-get install -y \
    sqlite3

COPY --from=build /usr/local/cargo/bin/arti /usr/local/bin/

RUN groupadd -r -g ${CONTAINER_GID} ${ARTI_USER} && \
    useradd --no-log-init -u ${CONTAINER_UID} -g ${ARTI_USER} ${ARTI_USER} && \
    mkdir -p /home/${ARTI_USER} && chown ${ARTI_USER}: /home/${ARTI_USER}

RUN mkdir -p ${APP_BASE}/${APP}/configs
COPY onionservice.toml ${APP_BASE}/${APP}/configs
RUN chown -R ${ARTI_USER}: ${APP_BASE}/${APP}
RUN chmod 640 ${APP_BASE}/${APP}/configs/onionservice.toml

USER ${ARTI_USER}

ENTRYPOINT exec arti proxy -c ${ARTI_CONFIG}
