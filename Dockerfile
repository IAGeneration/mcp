# Stage 1: compile
FROM golang:1.24-alpine AS builder
WORKDIR /src
# grab modules
COPY go.mod go.sum ./
RUN go mod download
# Copy the rest of the code
COPY . .
# compile 
RUN go build -o /bin/swagger-mcp main.go

# Stage 2: runtime image
FROM alpine:3.17
RUN apk add --no-cache ca-certificates
WORKDIR /app
# Copy the compiled binary
COPY --from=builder /bin/swagger-mcp .
# add our launcher script
# COPY entrypoint.sh .
# RUN chmod +x entrypoint.sh

#ENTRYPOINT [ "swagger-mcp" ]
# Default to running the script
ENTRYPOINT ["sh","-c", "\
  /app/swagger-mcp \
    --specUrl https://api.futurandco.tv/openapi.json \
    --baseUrl https://api.futurandco.tv \
    --security bearer \
    --sse \
    --sseAddr :3777 \
    --sseUrl http://0.0.0.0:3777 \
    --sseHeaders Authorization & \
  /app/swagger-mcp \
    --specUrl https://models.futurandco.tv/docs/json \
    --baseUrl https://models.futurandco.tv \
    --security bearer \
    --sse \
    --sseAddr :3778 \
    --sseUrl http://0.0.0.0:3778 \
    --sseHeaders Authorization & \
  wait\
"]