# Two stages: a static musl build, then a bare Alpine runtime with the binary.
# Crate versions are pinned in Cargo.toml; the registry is resolved at build time.
FROM rust:1-alpine AS build
RUN apk add --no-cache musl-dev
WORKDIR /app
COPY Cargo.toml ./
COPY src ./src
RUN cargo build --release

FROM alpine:3.21
COPY --from=build /app/target/release/app /usr/local/bin/app
CMD ["app"]
