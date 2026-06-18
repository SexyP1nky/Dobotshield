#!/usr/bin/env python3
# 

#  dvwa_login.py  --  Login automatico no DVWA + nivel de seguranca "low"
#
#  Roda dentro de um container python:3-alpine conectado a rede do lab.
#  Usa apenas a stdlib (urllib / http.cookiejar / re).
#
#  Fluxo:
#    1) Opcional: GET /setup.php -> POST create_db (cria/reseta as tabelas do
#       DVWA; usado apenas no lab_00_setup). Passe --no-setup para renovar
#       cookie sem tocar no banco.
#    2) GET  /login.php   -> POST login admin/password (com user_token CSRF)
#    3) GET  /security.php-> POST security=low
#    4) confirma sessao e imprime o cookie em stdout no formato:
#           PHPSESSID=<hex>;security=low
#       (sem espacos; pronto para --cookie / Cookie: header dos scanners)
#
#  stdout = APENAS o cookie (capturado pelo .bat).
#  stderr = diagnostico (login_ok, cookies obtidos).
#  Saida != 0  => falha; o .bat aborta a etapa autenticada para nao rodar
#                 ferramenta contra DVWA sem sessao valida.
# 

import http.cookiejar
import re
import sys
import urllib.parse
import urllib.request

args = [arg for arg in sys.argv[1:] if arg]
SKIP_SETUP = '--no-setup' in args
args = [arg for arg in args if arg != '--no-setup']
BASE = args[0] if args else 'http://dvwa:80'

jar = http.cookiejar.CookieJar()
opener = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(jar))
opener.addheaders = [('User-Agent', 'Mozilla/5.0 (compatible; DoBotShieldLabBot/1.0)')]


def get(path):
    return opener.open(BASE + path, timeout=20).read().decode('utf-8', 'ignore')


def post(path, data):
    body = urllib.parse.urlencode(data).encode()
    return opener.open(BASE + path, body, timeout=20).read().decode('utf-8', 'ignore')


def token(html):
    """Extrai o user_token (CSRF) do HTML, tolerando variacoes de versao do DVWA."""
    patterns = (
        r"name=['\"]user_token['\"][^>]*?value=['\"]([^'\"]+)",
        r"user_token['\"][^>]*?value=['\"]([^'\"]+)",
        r"value=['\"]([0-9a-fA-F]{32})['\"][^>]*name=['\"]user_token",
    )
    for pat in patterns:
        m = re.search(pat, html, re.I | re.S)
        if m:
            return m.group(1)
    return ''


def main():
    import time
    max_retries = 5
    for attempt in range(1, max_retries + 1):
        # 1) cria/reseta o banco apenas no setup inicial. Scanners usam
        # --no-setup para renovar sessao sem alterar o estado do DVWA.
        if not SKIP_SETUP:
            try:
                html = get('/setup.php')
                post('/setup.php', {'create_db': 'Create / Reset Database',
                                    'user_token': token(html)})
            except Exception as e:
                sys.stderr.write('aviso: create_db falhou no intento %d: %s\n' % (attempt, e))
        elif attempt == 1:
            sys.stderr.write('setup_skip=true\n')

        # 2) login admin/password
        html = get('/login.php')
        post('/login.php', {'username': 'admin', 'password': 'password',
                            'Login': 'Login', 'user_token': token(html)})

        # 3) nivel de seguranca = low
        html = get('/security.php')
        post('/security.php', {'security': 'low', 'seclev_submit': 'Submit',
                              'user_token': token(html)})

        # 4) confirma sessao autenticada
        home = get('/index.php')
        authed = 'logout' in home.lower()
        
        if authed:
            break
        
        sys.stderr.write('aviso: login_ok=False no intento %d. Aguardando DB...\n' % attempt)
        time.sleep(3)

    names = {c.name for c in jar}
    if not authed:
        sys.stderr.write('ERRO: Nao foi possivel autenticar no DVWA apos %d tentativas.\n' % max_retries)
        sys.exit(2)

    if not any(c.name == 'PHPSESSID' for c in jar):
        sys.stderr.write('ERRO: PHPSESSID nao obtido.\n')
        sys.exit(2)

    cookie = ';'.join('%s=%s' % (c.name, c.value) for c in jar)
    if 'security' not in names:
        cookie = (cookie + ';security=low') if cookie else 'security=low'

    sys.stderr.write('login_ok=%s  cookies=%s\n' % (authed, ','.join(sorted(names))))
    # stdout = APENAS o cookie (com newline, p/ captura via for /f no .bat)
    print(cookie)


if __name__ == '__main__':
    try:
        main()
    except Exception as e:
        sys.stderr.write('ERRO: %s\n' % e)
        sys.exit(1)
