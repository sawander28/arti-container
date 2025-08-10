# build stage
FROM rust:1.89.0-slim-bookworm AS builder

RUN apt-get update && \
    apt-get install -y git \
    pkg-config \
    libssl-dev \
    libsqlite3-dev \
    && rm -rf /var/lib/apt/lists/*

RUN cd /srv && git clone https://gitlab.torproject.org/tpo/core/arti.git \
    --depth 1 -b arti-v1.4.6
RUN mkdir -p /srv/arti &&  cd /srv/arti && \
        cargo build --release -p arti

# production stage
FROM debian:bookworm AS arti

# UID and GID might be read-only values, so use non-conflicting ones
ARG CONTAINER_UID="${CONTAINER_UID:-1000}"
ARG CONTAINER_GID="${CONTAINER_GID:-1000}"

RUN apt-get update && \
    apt-get install -y \
    sqlite3

COPY --from=builder /srv/arti/target/release/arti /usr/local/bin/

RUN groupadd -r -g ${CONTAINER_GID} arti && \
    useradd --no-log-init -u ${CONTAINER_UID} -g arti arti && \
    mkdir -p /home/arti && chown arti:arti /home/arti

RUN mkdir -p /home/arti
COPY arti.toml /home/arti/arti.toml
RUN chown -R arti:arti /home/arti
RUN chmod 640 /home/arti/arti.toml

EXPOSE 9050 1053

VOLUME ["/home/arti"]

USER arti

ENTRYPOINT exec arti -c /home/arti/arti.toml proxy
