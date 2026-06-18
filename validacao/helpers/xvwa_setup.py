#!/usr/bin/env python3
# ============================================================================
#  xvwa_setup.py  --  Cria/popula o banco do XVWA (equivalente ao create_db
#                     do DVWA). O XVWA NAO exige autenticacao.
#
#  Roda dentro de um container python:3-alpine conectado a rede do lab.
#  Usa apenas a stdlib (urllib).
#
#  Fluxo:
#    GET <BASE>/xvwa/setup/?action=do
#       -> a pagina de setup do XVWA executa cleanup()+criacao das tabelas
#          quando recebe o parametro action (qualquer valor).
#    Faz retry ate o MySQL do container LAMP estar pronto.
#
#  stdout = "ok" ou "fail".
#  stderr = diagnostico.
#  Saida 0 em sucesso, 2 em falha (o .bat apenas avisa e segue).
# ============================================================================
import sys
import time
import urllib.request

BASE = sys.argv[1] if len(sys.argv) > 1 else 'http://xvwa:80'
URL = BASE.rstrip('/') + '/xvwa/setup/?action=do'

req = urllib.request.Request(URL, headers={
    'User-Agent': 'Mozilla/5.0 (compatible; DoBotShieldLabBot/1.0)'
})

ok = False
for attempt in range(1, 13):
    try:
        resp = urllib.request.urlopen(req, timeout=20)
        html = resp.read().decode('utf-8', 'ignore').lower()
        # Sinais de falha de conexao do MySQL (container LAMP ainda subindo).
        db_not_ready = ('can\'t connect' in html or 'access denied' in html or
                        'connection refused' in html or 'mysqli' in html and 'error' in html)
        if resp.status == 200 and not db_not_ready:
            ok = True
            sys.stderr.write('xvwa_setup: setup acionado com sucesso (intento %d)\n' % attempt)
            break
        sys.stderr.write('xvwa_setup: banco ainda nao pronto (intento %d)\n' % attempt)
    except Exception as e:
        sys.stderr.write('xvwa_setup: erro no intento %d: %s\n' % (attempt, e))
    time.sleep(3)

print('ok' if ok else 'fail')
sys.exit(0 if ok else 2)
