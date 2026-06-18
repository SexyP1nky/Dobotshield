# Imagem unificada de ferramentas de ataque para o run_lab_tests.bat
#  - sqlmap   (exploracao de SQL Injection)
#  - XSStrike (fuzzing e evasao de XSS)
#  - commix   (exploracao de Command Injection / OSCI)
#
# Tres ferramentas em Python, instaladas via git clone para fixar uma
# versao reproduzivel. O entrypoint confia opcionalmente em um certificado
# do laboratorio (montado em /lab-ca/server.crt), de modo que os tres
# scanners conseguem falar com os endpoints HTTPS auto-assinados dos WAFs.

FROM python:3.11-slim

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
        git curl ca-certificates openssl \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /opt

RUN git clone --depth 1 https://github.com/sqlmapproject/sqlmap.git    /opt/sqlmap   \
 && git clone --depth 1 https://github.com/s0md3v/XSStrike.git         /opt/xsstrike \
 && git clone --depth 1 https://github.com/commixproject/commix.git    /opt/commix

RUN pip install --no-cache-dir -r /opt/xsstrike/requirements.txt

COPY entrypoint.sh /entrypoint.sh
# Normaliza line endings (caso o arquivo tenha sido salvo em Windows com CRLF)
RUN sed -i 's/\r$//' /entrypoint.sh && chmod +x /entrypoint.sh

ENV PYTHONUNBUFFERED=1 \
    PYTHONHTTPSVERIFY=0

WORKDIR /work
ENTRYPOINT ["/entrypoint.sh"]
CMD ["bash"]
