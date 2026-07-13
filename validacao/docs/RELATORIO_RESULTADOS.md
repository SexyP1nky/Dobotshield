# Relatório de Resultados — Bancada DoBotShield vs ModSecurity vs Coraza vs sem-WAF

Comparação de 6 ferramentas contra 2 aplicações vulneráveis (DVWA e XVWA), cada uma
em 4 cenários: **sem WAF (no_waf)**, **ModSecurity+CRS**, **DoBotShield**, **Coraza+CRS**.
Entrada idêntica por ferramenta dentro de cada app; só muda o destino (IP:porta).

O relatório é construído **exclusivamente a partir dos logs** (`results/<app>/<cenario>/`):
respostas HTTP, payloads enviados e veredito de cada ferramenta. Não há juízo de valor
sobre os WAFs — apenas o que os logs registram e o mecanismo que explica cada resultado.

## Procedência dos dados (importante)
- **testssl, SQLMap, XSStrike, Commix, wrk e ZAP/DVWA**: logs da bateria original
  (instância do lab com IPs 172.18.0.2–0.7).
- **ZAP/XVWA**: re-rodada com o *seed* do hook (`zap_hook.py`) numa instância nova do
  lab (IPs 172.18.0.7–0.10). Imagens e dados das apps são os mesmos; a comparação se mantém.
- **ZAP/DVWA — modsecurity**: log de uma re-rodada parcial; o comportamento do scan no
  DVWA é idêntico ao original (o seed do hook só atua no XVWA, condicionado a `/xvwa`).
- **DoBotShield (12/07/2026)**: as doze execuções das seis ferramentas em DVWA/XVWA
  foram reexecutadas seletivamente após as correções do laboratório. Os 36 artefatos
  dos cenários de referência foram preservados. Também se executaram quatro ataques
  manuais (`;echo`/`;sleep`) e seis casos benignos focalizados. Não foi produzido
  manifesto SHA-256.

---

## 1. testssl (TLS/SSL)

| Cenário | TLS ofertado | Protocolos legados | Certificado | Vulns de cripto |
|---|---|---|---|---|
| no_waf (DVWA/XVWA) | **nenhum** (porta 80, HTTP puro) | — | — | — |
| ModSecurity | TLS 1.2 + 1.3 | SSLv2/v3, TLS 1.0/1.1 **não ofertados** | self-signed **ECDSA P-256 / SHA256**, **SAN ausente** | nenhuma |
| DoBotShield | TLS 1.2 + 1.3 | SSLv2/v3, TLS 1.0/1.1 **não ofertados** | self-signed **RSA 2048 / SHA256** (com SAN) | nenhuma |
| Coraza | TLS 1.2 + 1.3 | SSLv2/v3, TLS 1.0/1.1 **não ofertados** | self-signed **RSA 2048 / SHA256** (com SAN) | nenhuma |

**Comparação / motivo:**
- **no_waf** não tem o que comparar: os logs registram *"doesn't seem to be a TLS/SSL
  enabled server"* e *TLS 1.0/1.1/1.2/1.3 not offered* — a app é servida em HTTP puro na
  porta 80. testssl encerra sem análise de TLS (RC=10 nessses dois alvos), por ausência de TLS.
- **Os 3 WAFs** terminam a varredura TLS completa e, nos logs, **nenhum** apresenta
  vulnerabilidade de cripto: Heartbleed, CCS, Ticketbleed, ROBOT, POODLE, SWEET32, FREAK,
  DROWN, LOGJAM, CRIME → todos *"not vulnerable (OK)"*. Todos oferecem só TLS 1.2/1.3 e
  desabilitam protocolos legados.
- **Diferença factual entre os WAFs**: o ModSecurity apresenta um certificado **ECDSA
  P-256** com **SAN ausente** (*"subjectAltName (SAN) missing (NOT ok)"*), enquanto
  DoBotShield e Coraza apresentam o certificado **RSA 2048 com SAN**. Os três certificados
  são **self-signed** (*"Chain of trust NOT ok (self signed)"*, *sem CRL/OCSP*) — esperado
  no lab. A única observação negativa exclusiva é o SAN ausente do ModSecurity.

---

## 2. ZAP (DAST full-scan)

Critério: alertas **HIGH** com o payload (`attack`) e a evidência (`evidence`) registrados
no `zap_report.json`. O que distingue exploit real de artefato é a **evidência concreta**
(ex.: `root:x:0:0`, `<title>Google</title>`, script refletido) versus evidência vazia ou
que é apenas o código de erro da resposta.

### DVWA (scan autenticado)
| Cenário | HIGH | Achados HIGH (payload → evidência) |
|---|---|---|
| no_waf | **6** | XSS Refletido `'"<scrIpt>alert(1)</scRipt>` (refletido); XSS DOM `<script>alert(5397)</script>`; Path Traversal `page=/etc/passwd` → `root:x:0:0`; OS Command Injection `ip=ZAP&cat /etc/passwd&` → `root:x:0:0`; SQLi `id=ZAP' OR '1'='1' --`; SQLi-MySQL `username='` → `error in your SQL syntax` |
| ModSecurity | **1** | SQLi-MySQL `username='` → `error in your SQL syntax` (no form de login) |
| DoBotShield | **1** | Spring4Shell → **evidência = `HTTP/1.1 400 Bad Request`** |
| Coraza | **0** | — |

### XVWA (scan com seed do hook)
| Cenário | HIGH | Achados HIGH (payload → evidência) |
|---|---|---|
| no_waf | **6** | XSS Refletido `item=</div><scrIpt>alert(1)</scRipt>`; XSS DOM `oNcliCk=alert(5397)`; Path Traversal `file=/etc/passwd` → `root:x:0:0`; RFI `file=http://www.google.com/` → `<title>Google</title>`; OS Command Injection `target=127.0.0.1&cat /etc/passwd&` → `root:x:0:0`; SSRF |
| ModSecurity | **1** | RFI `file=http://www.google.com/` → `<title>Google</title>` |
| DoBotShield | **1** | Spring4Shell → **evidência = `HTTP/1.1 400 Bad Request`** |
| Coraza | **1** | RFI `file=http://www.google.com/` → `<title>Google</title>` |

**Comparação / motivo:**
- **no_waf** (ambas apps): os 6 HIGH têm **evidência concreta** — o conteúdo de `/etc/passwd`
  (`root:x:0:0`), o título do Google retornado pelo `include()` (RFI), e o `<script>`
  refletido sem filtragem. São exploits confirmados, não suspeitas.
- **ModSecurity e Coraza**: bloqueiam XSS, Path Traversal, OS Command Injection e SSRF
  (esses HIGH **desaparecem**). Em ambos, **passa apenas a RFI no XVWA**
  (`file=http://www.google.com/` → `<title>Google</title>`): o payload é uma URL externa
  "limpa" e a resposta provou que o include externo executou. No DVWA, o ModSecurity ainda
  deixa passar **um `'` isolado** no campo `username` do login, que dispara erro MySQL
  visível (`error in your SQL syntax`) — payload curto demais para casar as regras de SQLi
  do CRS naquele endpoint. O Coraza no DVWA não apresenta esse HIGH (0).
- **DoBotShield**: na reexecução seletiva, DVWA e XVWA produziram o mesmo único alerta
  HIGH, Spring4Shell, cuja evidência é literalmente `HTTP/1.1 400 Bad Request`.
  Essa evidência documenta a resposta de bloqueio e não prova execução no backend.
- **Observação de cobertura no DoBotShield/XVWA**: o ZAP só conseguiu registrar os
  parâmetros `target` e `item`; os seeds GET com `file`/`target` levaram **400** já na
  semeadura, então parâmetros como `file` (RFI/Path Traversal) nem chegaram a ser testados.

> Divergência relevante entre ferramentas: o ZAP não confirmou exploração SQLi, mas o
> **SQLMap confirma SQLi booleano** no DoBotShield (ver seção 3).
> O motivo está no tipo de payload — detalhado abaixo.

---

## 3. SQLMap (SQL Injection — boolean-based, `--technique=B`)

| App | Cenário | Endpoint/param | Veredito | Payload confirmador | Respostas registradas |
|---|---|---|---|---|---|
| DVWA | no_waf | sqli `id` (GET) | **VULNERÁVEL** | `id=1' AND 8544=8544 AND 'wUrq'='wUrq` | 20 req, limpo |
| DVWA | no_waf | sqli_blind `id` | não-injetável* | — | 404 × 7 |
| DVWA | ModSecurity | sqli `id` | **BLOQUEADO** | — | **403 × 704** |
| DVWA | DoBotShield | sqli_blind `id` | **VULNERÁVEL** | `id=1' AND 5172=5172 AND 'Sudj'='Sudj` | **502 × 1 + 400 × 2** |
| DVWA | Coraza | sqli `id` | **BLOQUEADO** | — | **403 × 704** |
| XVWA | no_waf | sqli `item` (POST) | **VULNERÁVEL** | `item=1 AND 2951=2951` | 13 req, limpo |
| XVWA | ModSecurity | sqli `item` | **BLOQUEADO** | — | **403 × 704** |
| XVWA | DoBotShield | sqli `item` | **VULNERÁVEL** | `item=1 AND 3672=3672` | **502 × 1 + 400 × 1** |
| XVWA | Coraza | sqli `item` | **BLOQUEADO** | — | **403 × 704** |

\* DVWA `sqli_blind`: a string-oráculo padronizada `--string=Surname` não está na resposta
desse endpoint (*"such a string is not within the target URL raw response"*) + 404 → SQLMap
não consegue diferenciar verdadeiro/falso e marca não-injetável. É limitação do oráculo
escolhido, não do WAF (ocorre até no no_waf).

**Comparação / motivo:**
- **no_waf**: a injeção booleana confirma em poucas requisições (13–20), sem ruído. A app
  responde 200 e o par verdadeiro/falso é nítido.
- **ModSecurity e Coraza**: **bloqueiam 100% com exatamente `403 × 704`** — número idêntico
  nos dois, nas duas apps, porque rodam o **mesmo conjunto CRS**: cada payload booleano casa
  uma regra e recebe 403 antes de chegar ao banco. SQLMap percorre todas as variantes MySQL
  (~4 min) e conclui não-injetável.
- **DoBotShield**: **deixa a injeção booleana passar** nas duas apps. Ele responde
  **502/400** a parte dos payloads, mas **não impede** a técnica: o boolean-blind
  só precisa distinguir verdadeiro de falso, e pares suficientes passam. Por isso o
  DoBotShield aparece como VULNERÁVEL aqui, ao contrário do ZAP (seção 2): o ZAP usa
  payloads de erro/`OR 1=1`/UNION que o DoBotShield derruba com 502/400, sem evidência
  limpa; o SQLMap usa só diferença booleana, que sobrevive ao ruído.

---

## 4. XSStrike (XSS refletido)

Endpoint: DVWA `xss_r?name`, XVWA `reflected_xss?item`. Critério: payloads com *Efficiency*
(eficácia da reflexão) registrada — `Efficiency 100` = reflexão sem filtragem.

| App | Cenário | WAF detectado (fingerprint do XSStrike) | Reflexão | Payloads com sucesso |
|---|---|---|---|---|
| DVWA | no_waf | nenhum | sim | **3071/3071 com Efficiency 100** |
| DVWA | ModSecurity | "Amazon Web…" | sim (probe) | **0** (3072 gerados, nenhum passou) |
| DVWA | DoBotShield | "ChinaCache" | sim (probe) | **0** |
| DVWA | Coraza | "Amazon Web…" | sim (probe) | **0** |
| XVWA | no_waf | nenhum | sim | centenas com Efficiency **91–100** |
| XVWA | ModSecurity | "Amazon Web…" | sim (probe) | **0** |
| XVWA | DoBotShield | "ChinaCache" | sim (probe) | **0** |
| XVWA | Coraza | "Amazon Web…" | sim (probe) | **0** |

Exemplos de payload que funcionaram (no_waf):
- DVWA: `<d3V/+/onPOINTeREnTer%0d=%0dconfirm()>v3dm0s`, `<hTmL%0dOnpOIntErenTeR+=+(prompt)`
- XVWA: `<D3V%0doNmouseovEr%09=%09[8].find(confirm)>v3dm0s`, `<A/+/ONmouseoVer%0a=%0aconfirm()>v3dm0s`

**Comparação / motivo:**
- **no_waf**: o XSStrike não detecta WAF e os payloads refletem. No DVWA a reflexão é **crua
  (Efficiency 100 em todos os 3071)** — nada é filtrado. No XVWA a Efficiency fica em **91–96**
  na maioria (a app aplica codificação parcial), mas ainda alta o bastante para haver XSS.
- **Os 3 WAFs**: o XSStrike até detecta a reflexão de um *probe* benigno
  (`Reflections found: 1`), mas ao disparar os **3072 payloads reais com event-handlers**
  (`onpointerenter`, `onmouseover`, `%0d/%09` etc.), **nenhum** registra Efficiency →
  todos bloqueados. A diferença entre os WAFs aqui é só o **nome da fingerprint** que o
  XSStrike chuta a partir das respostas (ModSecurity/Coraza → "Amazon Web Services";
  DoBotShield → "ChinaCache") — são rótulos heurísticos do XSStrike, **não** identificação
  real do produto. No resultado prático (payloads passando), os três são equivalentes: zero.

---

## 5. Commix (OS Command Injection)

Endpoint: DVWA `exec` POST `ip`, XVWA `cmdi` GET `target`. Critério: técnica *classic
command injection* (results-based) e o que o servidor respondeu na fase de teste.

| App | Cenário | Veredito | Detalhe dos logs |
|---|---|---|---|
| DVWA | no_waf | **INJETÁVEL** | `ip` via classic cmdi — payload `127.0.0.1;echo ZNBZAC$((12+38))$(echo ZNBZAC)ZNBZAC` |
| DVWA | ModSecurity | **BLOQUEADO** | HTTP **403** no teste básico → "ignore 403? N" → *Skipping further testing* |
| DVWA | DoBotShield | **BLOQUEADO** | HTTP **400** ("Unable to connect… 400 Bad Request") → "ignore 400? N" → skip |
| DVWA | Coraza | **BLOQUEADO** | HTTP **403** → skip |
| XVWA | no_waf | **INJETÁVEL** | `target` via classic cmdi — payload `127.0.0.1;echo EHSFSR$((39+90))$(echo EHSFSR)EHSFSR` |
| XVWA | ModSecurity | **BLOQUEADO** | HTTP **403** → skip |
| XVWA | DoBotShield | **BLOQUEADO** | HTTP **400** → skip |
| XVWA | Coraza | **BLOQUEADO** | HTTP **403** → skip |

**Comparação / motivo:**
- **no_waf**: o Commix confirma a injeção pelo *marker* aritmético — ele anexa
  `;echo <MARK>$((a+b))$(echo <MARK>)<MARK>` e verifica se a soma foi **avaliada** na
  resposta (prova de execução de comando, OS Unix-like). Confirmado, recusa o pseudo-shell
  e encerra (sem flood/enumeração).
- **Os 3 WAFs**: o Commix **não consegue injetar** em nenhum. A diferença factual é só o
  **código de bloqueio**: **ModSecurity e Coraza respondem 403**; **DoBotShield responde
  400** (e já na fase passiva acusa *"Unable to connect… 400"*). Em todos, o Commix pergunta
  *"ignore HTTP code? [y/N]"* (padrão **N** no modo batch) e pula o alvo — o payload nunca
  passa pela borda.

---

## 6. Testes manuais e falsos positivos focalizados

O arquivo `results/manual_regression/07_manual_cmdi_false_positives.json` registra dez
casos adicionais no DoBotShield. `;echo` e `;sleep` foram enviados contra DVWA e XVWA:
os quatro ataques retornaram HTTP 400 com `X-DoBotShield-Action: Blocked-WAF`. As seis
requisições benignas retornaram HTTP 200 com ação `Forwarded`; portanto, não se observou
falso positivo nesse corpus. O conjunto é pequeno e intencionalmente focalizado, não uma
estimativa populacional da taxa de falsos positivos.

---

## 7. wrk (carga: 12 threads, 400 conexões, 30s)

| App | Cenário | Requests/s | Total req | Non-2xx/3xx | Latência média |
|---|---|---|---|---|---|
| DVWA | no_waf | 7.209 | 216.932 | 0 | 658 ms |
| DVWA | ModSecurity | 2.255 | 67.875 | 0 | 173 ms |
| DVWA | DoBotShield | 42.408,74 | 1.276.551 | **1.276.234 (~100%)** | 11,01 ms |
| DVWA | Coraza | 3.073 | 92.512 | 0 | 619 ms |
| XVWA | no_waf | 744 | 22.380 | 0 | 222 ms |
| XVWA | ModSecurity | 450 | 13.543 | 0 (2.686 read errors) | 821 ms |
| XVWA | DoBotShield | 36.749,62 | 1.105.899 | **1.105.581 (~100%)** | 13,33 ms |
| XVWA | Coraza | 131 | 3.936 | 0 | 2,67 s |

**Comparação / motivo — atenção ao que cada número significa:**
- **no_waf**: **100% das respostas são 2xx** — é a vazão bruta da aplicação servindo
  conteúdo direto (DVWA 7.209 req/s; XVWA 744 req/s, app mais pesada).
- **ModSecurity e Coraza**: também servem **2xx** (proxy real para a app **após inspecionar
  cada requisição**), por isso a vazão cai em relação ao no_waf (ModSec 2.255/450; Coraza
  3.073/131). Sob carga no XVWA o Coraza fica especialmente lento (131 req/s, latência 2,67 s).
- **DoBotShield**: ~**100% das respostas são non-2xx** (1,1–1,3 milhão), com **11–13 ms** de
  latência e ~37–42k req/s. Esse número alto **não é vazão de aplicação**: é **rejeição na
  borda** (rate-limit), respondendo rápido sem encaminhar ao backend. Comparar o "50k req/s"
  do DoBotShield com o "7k req/s 2xx" do no_waf seria comparar coisas diferentes — um é
  rejeição, o outro é conteúdo servido.

---

## 8. Quadro consolidado por cenário

| Ataque \ Cenário | no_waf | ModSecurity | DoBotShield | Coraza |
|---|---|---|---|---|
| **SQLi** (SQLMap, boolean) | injeta | **403 bloqueia** | **injeta** (502/400 atrapalham, não impedem) | **403 bloqueia** |
| **SQLi/erro** (ZAP) | confirma (evidência) | 1 caso (`'` no login DVWA) | bloqueia (artefatos 400) | bloqueia |
| **XSS** (XSStrike) | reflete (Eff. 91–100) | 0 passam | 0 passam | 0 passam |
| **OS cmdi** (Commix) | injeta | **403** | **400** | **403** |
| **XSS/Path Trav/RFI/cmdi/SSRF** (ZAP) | 6 HIGH c/ evidência | bloqueia (passa só RFI no XVWA) | 1 alerta Spring4Shell/400 por app, sem prova de execução | bloqueia (passa só RFI no XVWA) |
| **TLS** (testssl) | sem TLS (HTTP) | TLS 1.2/1.3, sem vulns (cert ECDSA, SAN ausente) | TLS 1.2/1.3, sem vulns (cert RSA-2048) | TLS 1.2/1.3, sem vulns (cert RSA-2048) |
| **Carga 2xx servido** (wrk) | maior (app direta) | reduzida, serve 2xx | ~100% non-2xx (rejeição na borda) | reduzida, serve 2xx |

### Síntese factual (sem juízo de valor)
- **SQLi booleano**: bloqueado por ModSecurity e Coraza (403); **passa** no DoBotShield e no no_waf.
- **XSS e OS command injection**: bloqueados pelos três WAFs; só passam no no_waf.
- **RFI via URL externa** (`file=http://www.google.com/`): passou no ModSecurity e no Coraza
  (XVWA); no DoBotShield o parâmetro foi barrado (400) antes do teste.
- **Códigos de bloqueio**: ModSecurity e Coraza usam **403**; DoBotShield usa **400/502**.
  Esses códigos não impedem o SQLi booleano do SQLMap e podem acionar alertas diferenciais
  no ZAP; por isso, alerta e exploração foram tratados separadamente.
- **TLS**: equivalente entre os três WAFs (1.2/1.3, sem vulnerabilidades); diferença só no
  tipo de certificado self-signed do lab.
- **Ferramentas que percorreram o fluxo completo sem erro**: SQLMap, XSStrike, Commix e wrk
  (8/8). testssl 8/8 (os 2 no_waf saem RC=10 por não haver TLS na porta 80). ZAP 8/8 RC=0
  (XVWA com o seed do hook).
