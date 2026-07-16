FROM golang:1.21-alpine@sha256:2414035b086e3c42b99654c8b26e6f5b1b1598080d65fd03c7f499552ff4dc94 AS builder

WORKDIR /build

COPY go.mod ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o dobotshield .

# ----

FROM alpine:3.19@sha256:6baf43584bcb78f2e5847d1de515f23499913ac9f12bdf834811a3145eb11ca1

RUN apk --no-cache add ca-certificates tzdata

WORKDIR /app

COPY --from=builder /build/dobotshield ./dobotshield

EXPOSE 80

# HTTP_MODE=true: desativa TLS para uso em laboratorio Docker.
# Para producao, remova esta variavel e monte server.crt e server.key.
ENV HTTP_MODE=true

CMD ["./dobotshield"]
