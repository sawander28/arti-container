# build stage
FROM rust:1.89.0-slim-trixie AS builder

RUN apt-get update && \
    apt-get install -y \
    pkg-config \
    libssl-dev \
    libsqlite3-dev \
    && rm -rf /var/lib/apt/lists/*

RUN cargo install arti --features=static-sqlite

# production stage
FROM containers.torproject.org/tpo/tpa/base-images/debian:trixie AS arti

# UID and GID might be read-only values, so use non-conflicting ones
ARG CONTAINER_UID="${CONTAINER_UID:-1000}"
ARG CONTAINER_GID="${CONTAINER_GID:-1000}"

ENV ARTI_CONFIG="${ARTI_CONFIG:-/home/arti/arti.toml}"

RUN apt-get update && \
    apt-get install -y \
    sqlite3

COPY --from=builder /usr/local/cargo/bin/arti /usr/local/bin/

RUN groupadd -r -g ${CONTAINER_GID} arti && \
    useradd --no-log-init -u ${CONTAINER_UID} -g arti arti && \
    mkdir -p /home/arti && chown arti:arti /home/arti

RUN mkdir -p /home/arti
COPY arti.toml /home/arti/arti.toml
RUN chown -R arti:arti /home/arti
RUN chmod 640 /home/arti/arti.toml

EXPOSE 9050

VOLUME ["/home/arti"]

USER arti

ENTRYPOINT exec arti -c /home/arti/arti.toml proxy
