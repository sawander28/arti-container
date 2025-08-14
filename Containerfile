# build stage
FROM rust:1.89.0-slim-trixie AS builder

RUN apt-get update && \
    apt-get install -y \
    pkg-config \
    libssl-dev \
    libsqlite3-dev && \
    rm -rf /var/lib/apt/lists/*

RUN cargo install arti --features=static-sqlite

# production stage
FROM containers.torproject.org/tpo/tpa/base-images/debian:trixie AS arti

ENV ARTI_CONFIG="${ARTI_CONFIG:-/home/arti/arti.toml}"

WORKDIR "/home/arti"

RUN apt-get update && \
    apt-get install -yq sqlite3 && \
        rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/cargo/bin/arti /usr/local/bin/

RUN groupadd --gid 1000 arti && \
    useradd \
        --home-dir /home/arti \
        --create-home \
        --gid 1000 \
        --uid 1000 \
        arti

COPY arti.toml /home/arti
RUN chown -R arti:arti /home/arti && \
    chmod 640 /home/arti/arti.toml

EXPOSE 9050 1053

USER arti

ENTRYPOINT exec arti proxy -c "$ARTI_CONFIG"
