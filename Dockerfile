# _____________Stage 1: Building the Go binary_________________
FROM golang:1.24-alpine AS builder

RUN go install github.com/danishjsheikh/swagger-mcp@latest

# ______________Stage 2: runtime image________________________
FROM debian:bookworm-slim AS base

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
        ca-certificates \
        unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Bun
RUN curl -fsSL https://bun.sh/install | bash
ENV BUN_INSTALL=/root/.bun
ENV PATH=$BUN_INSTALL/bin:$PATH

WORKDIR /app

# Copy Hello endpoint script and its dependency manifests
COPY bunjs ./bunjs

WORKDIR /app/bunjs
# Install Bun dependencies
RUN bun install --no-save

# Copying the Go binary
COPY --from=builder /go/bin/swagger-mcp /usr/local/bin/swagger-mcp

WORKDIR /app

EXPOSE 3777 3778 3000

# Lanching 3 process in one container
ENTRYPOINT ["sh","-c", "\
  /usr/local/bin/swagger-mcp \
    --specUrl https://api.futurandco.tv/openapi.json \
    --baseUrl https://api.futurandco.tv \
    --security bearer \
    --sse \
    --sseAddr :3777 \
    --sseUrl https://mcp.api.futurandco.tv \
    --sseHeaders Authorization & \
  /usr/local/bin/swagger-mcp \
    --specUrl https://models.futurandco.tv/docs/json \
    --baseUrl https://models.futurandco.tv \
    --security bearer \
    --sse \
    --sseAddr :3778 \
    --sseUrl https://mcp.models.futurandco.tv \
    --sseHeaders Authorization & \
  bun run bunjs/hello.js & \
  wait\
"]