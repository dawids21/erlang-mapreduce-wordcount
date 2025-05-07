# Build stage
FROM erlang:27 AS builder

WORKDIR /src

COPY rebar.config rebar.lock ./
COPY _build ./_build
COPY config ./config
COPY apps ./apps

RUN rebar3 as prod clean && rebar3 as prod tar

RUN mkdir /app && tar -xvzf _build/prod/rel/*/*.tar.gz -C /app

# Runtime stage 
FROM debian:12-slim AS runner

RUN apt-get update && \
    apt-get install -y openssl ncurses-bin && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

ENV NAME=mapreduce_wordcount \
    KNOWN_NODES="mapreduce_wordcount@localhost" \
    NODE_DIRECTORY=/app/node \
    PUBLIC_DIRECTORY=/app/public \
    PROCESSING_POWER_MULTIPLIER=1 \
    LOGGER_LEVEL=info \
    INJECT_EXCEPTION=false \
    RELX_OUT_FILE_PATH=/tmp

COPY --from=builder /app /app

ENTRYPOINT [ "/app/bin/mapreduce_wordcount" ]
CMD ["foreground"]