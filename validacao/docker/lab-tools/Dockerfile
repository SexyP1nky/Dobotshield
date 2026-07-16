# Imagem unificada de ferramentas de ataque para o run_lab_tests.bat
#  - sqlmap   (exploracao de SQL Injection)
#  - XSStrike (fuzzing e evasao de XSS)
#  - commix   (exploracao de Command Injection / OSCI)
#
# Tres ferramentas em Python, instaladas via git clone para fixar uma
# versao reproduzivel. O entrypoint confia opcionalmente em um certificado
# do laboratorio (montado em /lab-ca/server.crt), de modo que os tres
# scanners conseguem falar com os endpoints HTTPS auto-assinados dos WAFs.

FROM python:3.11-slim@sha256:e031123e3d85762b141ad1cbc56452ba69c6e722ebf2f042cc0dc86c47c0d8b3

ARG SQLMAP_COMMIT=da07c8756d14c736cda90d16056fd8547fccfbb0
ARG XSSTRIKE_COMMIT=ab27955d367432f944d8f29897e09c15356e76f7
ARG COMMIX_COMMIT=4237f46bc98269ae72d226d0b210029cbbc71ba2

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
        git curl ca-certificates openssl \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /opt

RUN git init /opt/sqlmap \
 && git -C /opt/sqlmap remote add origin https://github.com/sqlmapproject/sqlmap.git \
 && git -C /opt/sqlmap fetch --depth 1 origin "$SQLMAP_COMMIT" \
 && git -C /opt/sqlmap checkout --detach FETCH_HEAD \
 && git init /opt/xsstrike \
 && git -C /opt/xsstrike remote add origin https://github.com/s0md3v/XSStrike.git \
 && git -C /opt/xsstrike fetch --depth 1 origin "$XSSTRIKE_COMMIT" \
 && git -C /opt/xsstrike checkout --detach FETCH_HEAD \
 && git init /opt/commix \
 && git -C /opt/commix remote add origin https://github.com/commixproject/commix.git \
 && git -C /opt/commix fetch --depth 1 origin "$COMMIX_COMMIT" \
 && git -C /opt/commix checkout --detach FETCH_HEAD

RUN pip install --no-cache-dir -r /opt/xsstrike/requirements.txt

COPY entrypoint.sh /entrypoint.sh
# Normaliza line endings (caso o arquivo tenha sido salvo em Windows com CRLF)
RUN sed -i 's/\r$//' /entrypoint.sh && chmod +x /entrypoint.sh

ENV PYTHONUNBUFFERED=1 \
    PYTHONHTTPSVERIFY=0

WORKDIR /work
ENTRYPOINT ["/entrypoint.sh"]
CMD ["bash"]
