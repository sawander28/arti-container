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
ARG ARTI_UID=1000
ARG ARTI_GID=1000
ARG ARTI_USER=arti
ARG ARTI_GROUP=arti

ENV ARTI_CONFIG="${ARTI_CONFIG:-/home/arti/arti.toml}"

RUN apt-get update && \
    apt-get install -y sqlite3

COPY --from=builder /usr/local/cargo/bin/arti /usr/local/bin/

RUN groupadd -gid "${ARTI_GID}" "${ARTI_GROUP}" && \
    useradd \
        --home-dir "/home/${ARTI_USER}" \
        --create-home \
        --gid "${ARTI_GID}" \
        --uid "${ARTI_UID}" \
        "${ARTI_USER}

COPY arti.toml /home/${ARTI_USER}/arti.toml
RUN chmod 640 /home/${ARTI_USER}/arti.toml

EXPOSE 9050 1053

USER "${ARTI_UID}:${ARTI_GID}"

WORKDIR "/home/${ARTI_USER}"

ENTRYPOINT ["arti proxy"]
