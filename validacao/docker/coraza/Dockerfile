# Coraza WAF via Caddy
# Terceiro WAF usado na comparacao academica.
# Coraza e uma implementacao moderna em Go do motor WAF compativel com OWASP CRS,
# menos madura que o ModSecurity mas com arquitetura mais simples.

FROM caddy:builder@sha256:ffa8572dfe784332cce850b255926465b5a71c947af60e6b4b17bf6adca4fedb AS builder

RUN xcaddy build \
    --with github.com/corazawaf/coraza-caddy/v2@v2.5.0

FROM caddy:latest@sha256:af5fdcd76f2db5e4e974ee92f96ee8c0fc3edb55bd4ba5032547cbf3f65e486d

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
COPY Caddyfile /etc/caddy/Caddyfile

EXPOSE 443

CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
