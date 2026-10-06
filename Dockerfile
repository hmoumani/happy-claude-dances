# syntax=docker/dockerfile:1.7

FROM golang:1.24-alpine AS build
WORKDIR /src
ENV CGO_ENABLED=0 GOOS=linux

COPY go.mod go.sum* ./
RUN go mod download

COPY p1 ./p1

RUN go build -trimpath -ldflags="-s -w" -o /out/ioc ./p1/cmd/ioc


FROM alpine:3.20 AS runtime
RUN apk add --no-cache ca-certificates tzdata wget \
    && addgroup -S ioc && adduser -S -G ioc ioc
WORKDIR /app
COPY --from=build /out/ioc /app/ioc
# Bake the demo target into the image so `make up` works out of the box
# without requiring the evaluator to adjust Docker Desktop file sharing.
# Dev workflow uses TARGET_PATH on the host instead.
COPY p1/demo /app/target
USER ioc
EXPOSE 8080
ENTRYPOINT ["/app/ioc"]
