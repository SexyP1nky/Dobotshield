#!/bin/sh
# Confia no certificado auto-assinado do laboratorio (se montado em /lab-ca),
# para que sqlmap/xsstrike/commix consigam falar TLS com os WAFs sem erros.
if [ -f /lab-ca/server.crt ]; then
    cp /lab-ca/server.crt /usr/local/share/ca-certificates/lab.crt
    update-ca-certificates --fresh >/dev/null 2>&1 || true
    export REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
    export SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
    export CURL_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
fi
exec "$@"
