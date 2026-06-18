# ============================================================================
#  zap_hook.py  --  Hook do zap-full-scan.py para a bancada DoBotShield.
#
#  Passado via:  zap-full-scan.py ... --hook=/zap/hooks/zap_hook.py
#
#  Objetivo: impedir que o spider/active-scan do ZAP "quebre a aplicacao" ou
#  sabote a propria sessao ao varrer URLs perigosas. Excluimos de proxy,
#  spider e active scan os caminhos:
#     - logout            -> DVWA: encerraria a sessao autenticada (cookie).
#     - setup / action=do -> XVWA (/xvwa/setup/) e DVWA (setup.php):
#                            recriariam/zerariam o banco de dados.
#     - security.php       -> DVWA: alteraria o nivel de seguranca durante o scan.
#
#  Com isso o scan autenticado do DVWA navega as paginas internas sem se
#  deslogar, e o scan do XVWA nao reseta o banco no meio da bateria.
#
#  As exclusoes sao criticas: se a API mudar e alguma delas falhar, o scan deve
#  abortar em vez de seguir com risco de tocar em reset/logout.
#
#  AUTENTICACAO (DVWA): o cookie de sessao chega pela variavel de ambiente
#  DVWA_COOKIE e e injetado em TODA requisicao via uma regra de Replacer criada
#  AQUI pela API do ZAP (zap.replacer.add_rule). Isso e o que mantem o scan
#  AUTENTICADO. Tentar criar a regra por "-config replacer.rules..." na linha de
#  comando NAO funciona nesta versao do ZAP (a config e aceita mas a extensao
#  nao a aplica). No XVWA a variavel vem vazia -> nenhuma regra e criada.
# ============================================================================

import os
import time

EXCLUDES = [
    r".*logout.*",
    r".*setup.*",
    r".*action=do.*",
    r".*security\.php.*",
    # DVWA: a pagina CSRF troca a SENHA do admin. Numa varredura AUTENTICADA, o
    # active-scan submete o formulario e muda a senha -> as ferramentas seguintes
    # (sqlmap/xsstrike/commix) nao conseguem mais renovar o cookie (login falha).
    # Excluir mantem a sessao/bateria intactas (perda: o ZAP nao testa o CSRF).
    r".*/vulnerabilities/csrf.*",
]

# ============================================================================
#  SEED do XVWA (Ponto 1 da analise 2026-06-06)
#  ---------------------------------------------------------------------------
#  Sem isso, o spider do ZAP entra em /xvwa/ mas NAO submete os formularios
#  (postForm vem desligado por padrao) -> o active-scan fica sem parametros para
#  fuzzar e o XVWA gera pouquissimos alertas (so cabecalhos da home). Aqui, SO
#  quando o alvo e o XVWA, nos:
#    1) ligamos a submissao/parse de formularios no spider (postForm/processForm)
#       para ele descobrir os parametros POST sozinho (sqli 'item', stored_xss
#       'name'/'msg', xpath 'search', ssrf 'img_url', ...);
#    2) semeamos explicitamente as URLs vulneraveis (e os pontos GET ja com um
#       parametro de exemplo: cmdi 'target', reflected_xss/idor 'item', ssti
#       'name', fi/redirect/php_object) para garantir que o active-scan tenha
#       pontos de injecao concretos mesmo que a submissao de form falhe.
#
#  As MESMAS rotas (relativas) sao usadas nos 4 cenarios do XVWA (no_waf + os 3
#  WAFs); so muda o host:porta (derivado do proprio alvo). O DVWA NAO entra aqui
#  (o bloco e condicionado a "/xvwa" no alvo) -> permanece exatamente como antes.
#  Tudo aqui e best-effort (nao-fatal): falha de seed nao aborta o scan.
# ============================================================================

# Paginas dos modulos (o spider, com postForm ligado, submete os forms POST).
XVWA_SEED_PATHS = [
    "instruction.php",
    "vulnerabilities/sqli/",
    "vulnerabilities/sqli_blind/",
    "vulnerabilities/xpath/",
    "vulnerabilities/reflected_xss/",
    "vulnerabilities/stored_xss/",
    "vulnerabilities/dom_xss/",
    "vulnerabilities/cmdi/",
    "vulnerabilities/fi/",
    "vulnerabilities/fileupload/",
    "vulnerabilities/idor/",
    "vulnerabilities/ssrf_xspa/",
    "vulnerabilities/ssti/",
    "vulnerabilities/formula_injection/",
    "vulnerabilities/php_object_injection/",
    "vulnerabilities/redirect/",
    "vulnerabilities/sessionflaws/",
    "vulnerabilities/crypto/",
    "vulnerabilities/missfunc/",
]

# Pontos GET ja com um valor de exemplo: registra o parametro no historico para
# o active-scan fuzzar, mesmo que o spider nao submeta o form correspondente.
XVWA_SEED_GET = [
    "vulnerabilities/reflected_xss/?item=test",
    "vulnerabilities/cmdi/?target=127.0.0.1",
    "vulnerabilities/idor/?item=1",
    "vulnerabilities/ssti/?name=test",
    "vulnerabilities/fi/?file=test.php",
    "vulnerabilities/redirect/?url=http://example.com",
    "vulnerabilities/php_object_injection/?r=test",
]


def _apply(fn, *args):
    try:
        fn(*args)
    except Exception as exc:  # noqa: BLE001 - falha fechada por seguranca
        raise RuntimeError("%s falhou: %s" % (getattr(fn, "__name__", fn), exc)) from exc


def _inject_session_cookie(zap):
    cookie = os.environ.get("DVWA_COOKIE", "").strip()
    if not cookie:
        print("[zap_hook] DVWA_COOKIE vazio -> scan sem cookie (esperado no XVWA).")
        return
    # Idempotente caso o daemon ja tenha a regra (re-uso de container).
    try:
        zap.replacer.remove_rule("SessionCookie")
    except Exception:  # noqa: BLE001 - inexistente na 1a vez
        pass
    # add_rule(description, enabled, matchtype, matchregex, matchstring,
    #          replacement, initiators). REQ_HEADER 'Cookie' -> injeta/forca o
    # header Cookie em todas as requisicoes (inclui as do spider e do ascan).
    _apply(zap.replacer.add_rule, "SessionCookie", True, "REQ_HEADER", False,
           "Cookie", cookie, "")
    print("[zap_hook] cookie de sessao DVWA injetado via Replacer (REQ_HEADER Cookie).")


def _soft(label, fn, *args):
    """Best-effort: registra e segue se falhar (seed e enriquecimento, nao critico)."""
    try:
        fn(*args)
        return True
    except Exception as exc:  # noqa: BLE001 - seed nao deve abortar o scan
        print("[zap_hook] (aviso) %s falhou: %s" % (label, exc))
        return False


def _seed_xvwa(zap, target):
    if "/xvwa" not in target.lower():
        return  # DVWA (ou qualquer outro alvo) -> nao mexe; comportamento original.

    base = target if target.endswith("/") else target + "/"
    print("[zap_hook] XVWA detectado -> ligando submissao de forms e semeando URLs vulneraveis.")

    # 1) Spider passa a parsear e SUBMETER formularios (descobre params POST).
    _soft("spider.post_form",    zap.spider.set_option_post_form, True)
    _soft("spider.process_form", zap.spider.set_option_process_form, True)
    _soft("spider.handle_params", zap.spider.set_option_handle_parameters, "USE_ALL")
    _soft("spider.max_children", zap.spider.set_option_max_children, 0)

    # 2) Semeia as paginas dos modulos (entram na arvore p/ spider/ascan).
    seeded = 0
    for path in XVWA_SEED_PATHS:
        if _soft("access %s" % path, zap.core.access_url, base + path):
            seeded += 1
    # 3) Semeia pontos GET ja com parametro de exemplo (alvo direto do ascan).
    for q in XVWA_SEED_GET:
        if _soft("access %s" % q, zap.core.access_url, base + q):
            seeded += 1
    print("[zap_hook] XVWA: %d/%d URLs semeadas." % (seeded, len(XVWA_SEED_PATHS) + len(XVWA_SEED_GET)))
    # Pequena folga para o passive-scan processar o que foi semeado.
    time.sleep(2)


def zap_started(zap, target):
    print("[zap_hook] aplicando exclusoes de URL (logout/setup/security) ...")
    for rx in EXCLUDES:
        _apply(zap.core.exclude_from_proxy, rx)
        _apply(zap.spider.exclude_from_scan, rx)
        _apply(zap.ascan.exclude_from_scan, rx)
    _inject_session_cookie(zap)
    _seed_xvwa(zap, target)
    return zap, target
