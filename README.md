# DoBotShield

Proxy reverso de segurança com WAF integrado, desenvolvido como Trabalho de Conclusão de Curso em Ciência da Computação. O DoBotShield fica à frente de uma aplicação web legada e filtra o tráfego sem exigir alteração no código da aplicação protegida.

A ideia é simples: em vez de expor a aplicação diretamente na internet, os clientes passam a acessar o DoBot Shield. Ele termina o TLS, inspeciona cada requisição e cada resposta, descarta o que é malicioso e encaminha o restante para a aplicação, que continua funcionando como antes.

---

## O que ele faz

- **Termina TLS (HTTPS)** na frente de aplicações que falam HTTP, sem alterar a aplicação.
- **Inspeciona a requisição** (path, query, headers, corpo e uploads multipart) procurando 12 categorias de ataque. Antes de comparar com as regras, decodifica o payload em camadas (URL até 5 vezes, HTML, Unicode/hex, remoção de comentários, normalização de separadores) para capturar tentativas ofuscadas.
- **Inspeciona a resposta do backend** procurando vazamentos: erro de banco, stack trace, arquivo sensível e script refletido (4 categorias).
- **Bloqueia IPs e CIDRs** (blocklist) antes de qualquer outro processamento.
- **Limita a taxa por IP** (token bucket) e o número de conexões simultâneas.
- **Remove headers que expõem a stack** (`Server`, `X-Powered-By`, `X-AspNet-Version`) e **injeta headers de segurança** (`Strict-Transport-Security`, `X-Frame-Options`, `X-Content-Type-Options`, `Referrer-Policy`, `Permissions-Policy` e CSP opcional).
- **Recupera o IP real** do cliente quando há um proxy confiável na frente e repassa os headers `X-Forwarded-*` para o backend.
- **Bloqueia os métodos TRACE e TRACK.**
- **Modo monitor** para observar sem bloquear, **allowlist** por categoria e rota para abrir exceções pontuais, e **Modo de Treinamento**, que registra cada bloqueio em JSON e gera um relatório HTML didático.

## O que ele não faz

- **Não substitui a validação no backend.** É uma camada adicional, baseada em regex. Ela reduz a superfície de ataque, mas não garante cobertura total; a aplicação continua precisando tratar suas próprias entradas.
- **Não garante cobertura universal.** Na rodada consolidada de 17 e 18 de julho de 2026, o vetor booleano original do SQLMap foi bloqueado após a correção da regra de SQLi. Isso valida esse vetor e as variações cobertas pela regra (`=`, `LIKE`, `~` e operandos com aspas desbalanceadas), mas não prova que toda forma futura de SQLi será detectada.

---

## Como usar

O DoBot Shield é um único binário. O fluxo normal é: gerar o certificado, apontar para a aplicação, escolher o modo do WAF, subir o serviço e redirecionar o tráfego para ele.

### 1. Pré-requisitos

- **Go 1.21+** para compilar, ou Docker para rodar em container.
- Uma aplicação web já no ar, acessível por HTTP ou HTTPS, por exemplo `http://localhost:8080`.

### 2. Gerar o certificado TLS

Em produção, o DoBot Shield atende em HTTPS; portanto, precisa de um par certificado/chave. Para um ambiente de teste, é possível gerar um certificado autoassinado:

```powershell
# Windows (PowerShell)
cd certificado
go run gerar_cert.go            # gera server.crt e server.key no diretório atual
Move-Item server.crt ..\ -Force
Move-Item server.key ..\ -Force
cd ..
```

```bash
# Linux/macOS
cd certificado && go run gerar_cert.go && mv server.crt ../ && mv server.key ../ && cd ..
```

Em produção, use o certificado emitido para o seu domínio e aponte `CERT_FILE` / `KEY_FILE` para os arquivos corretos.

### 3. Apontar para a aplicação

A única configuração realmente obrigatória é a `TARGET_URL`, que representa o endereço interno da aplicação protegida:

```text
TARGET_URL = http://localhost:8080     # para onde o DoBot Shield encaminha
PROXY_PORT = :443                      # porta em que o DoBot Shield escuta
```

A aplicação não muda. Ela continua escutando onde sempre escutou; o DoBot Shield passa a receber o tráfego externo.

### 4. Escolher o modo do WAF

Comece em **monitor** e só depois mude para **block**:

- `WAF_MODE=monitor`: registra o que bloquearia, mas deixa passar. Use por um período inicial para descobrir falsos positivos nas rotas da aplicação.
- `WAF_MODE=block`: passa a bloquear de fato. Requisições maliciosas recebem `400`; vazamentos detectados na resposta viram `502`.
- `WAF_ALLOWLIST`: abre exceções cirúrgicas quando uma rota legítima cai em uma regra. Veja [Allowlist WAF](#allowlist-waf).

### 5. Subir o DoBot Shield

```powershell
# Windows (PowerShell)
$env:TARGET_URL = 'http://localhost:8080'
$env:PROXY_PORT = ':443'
$env:WAF_MODE   = 'monitor'
go build -o dobotshield.exe .
.\dobotshield.exe
```

```bash
# Linux/macOS
export TARGET_URL='http://localhost:8080'
export PROXY_PORT=':443'
export WAF_MODE='monitor'
go build -o dobotshield .
./dobotshield
```

Ao subir, o DoBot Shield imprime um banner com o protocolo, a URL de acesso e o backend para onde encaminha. A partir daí, ele atende em `https://localhost:443` (ou na porta escolhida) e repassa para a `TARGET_URL`.

### 6. Redirecionar o tráfego

Os clientes agora acessam o **DoBot Shield**, não a aplicação diretamente. Em produção, ajuste o DNS e o firewall para que a aplicação só seja alcançável pelo DoBot Shield. Se houver um balanceador ou CDN na frente do DoBot Shield, liste o IP dele em `TRUSTED_PROXIES`; assim, o DoBot Shield confia no `X-Forwarded-For` e registra o IP real do cliente em vez do IP do balanceador.

### Sem TLS (laboratório)

`HTTP_MODE=true` faz o DoBot Shield atender em **HTTP puro**, sem certificado. Serve quando o TLS é terminado por outro componente ou em um teste local rápido.

### Atalho: montar o comando pela interface

Em vez de digitar as variáveis manualmente, abra `admin-config/index.html` em qualquer navegador, preencha o formulário e copie o comando pronto nos formatos PowerShell, Bash ou `.env`. A página valida os campos e não precisa de backend.

---

## Arquitetura (modelo C4)

### Nível 1 — Contexto do sistema

```text
                    Internet
                       |
                  [ Usuário ]
                  (navegador,
                   ferramenta
                   de ataque)
                       |
                       | HTTPS (produção) / HTTP (laboratório)
                       v
              --------------------
              |   DoBotShield    |  <- sistema analisado
              |  (proxy reverso  |
              |   com WAF)       |
              --------------------
                       |
                       | HTTP interno
                       v
              --------------------
              |  Aplicação Web   |
              |  (legado: DVWA,  |
              |   XVWA etc.)     |
              --------------------
```

**DoBotShield** recebe todo o tráfego externo, aplica as políticas de segurança e encaminha apenas as requisições válidas para o sistema legado. A aplicação protegida não precisa ser alterada.

---

### Nível 2 — Containers

No sentido estrito do modelo C4, o caminho de rede do DoBotShield contém um
único contêiner executável: o binário Go. Os blocos `waf/`, `ratelimit/`,
`middleware/`, `blocklist/` e `config/` abaixo são componentes internos desse
mesmo processo. A Admin UI, o log JSON Lines e o gerador de relatório são
artefatos de apoio e não participam do encaminhamento de requisições.

```text
--------------------------------------------------------------------------
|                           DoBotShield                                  |
|                                                                        |
|   ------------------   --------------------   ----------------------   |
|   |   WAF          |   |  Rate Limiter    |   |  Reverse Proxy     |   |
|   | (waf/)         |   | (ratelimit/)     |   | (middleware/)      |   |
|   |                |   |                  |   |                    |   |
|   | Inspeção de    |   | Token bucket     |   | httputil.Reverse   |   |
|   | requisições e  |   | por IP com LRU   |   | Proxy com TLS      |   |
|   | respostas por  |   | e persistência   |   | e headers de       |   |
|   | regex          |   | opcional         |   | segurança          |   |
|   ------------------   --------------------   ----------------------   |
|                                                                        |
|   ------------------   --------------------   ----------------------   |
|   |  Blocklist     |   |  Config          |   |  Admin UI          |   |
|   | (blocklist/)   |   | (config/)        |   | (admin-config/)    |   |
|   |                |   |                  |   |                    |   |
|   | IPs/CIDRs      |   | Leitura de env   |   | Interface HTML     |   |
|   | bloqueados     |   | vars com         |   | estática para      |   |
|   | antes do WAF   |   | defaults         |   | gerar comandos     |   |
|   ------------------   --------------------   ----------------------   |
--------------------------------------------------------------------------
            |                                           |
            v                                           v
     Aplicação legada                           Operador humano
     (HTTP/HTTPS)                               (configura via .env)
```

---

### Nível 3 — Componentes do WAF

```text
----------------------------------------------------
|                   waf/                           |
|                                                  |
|  CheckRequest(r, body)                           |
|    |                                             |
|    +-- analyzePayload(path)                      |
|    +-- analyzePayload(query)                     |
|    +-- analyzePayload(headers selecionados)      |
|    +-- analyzePayload(body)                      |
|    +-- inspectMultipart(r, body)                 |
|         |                                        |
|         v                                        |
|    buildInspectionVariants(input)                |
|    - original                                    |
|    - URL decode (até 5 passes)                   |
|    - HTML decode (até 3 passes)                  |
|    - unicode/hex escape decode                   |
|    - remoção de block comments                   |
|    - normalização de separadores                 |
|    - compactação de payload                      |
|         |                                        |
|         v                                        |
|    patterns.go: 12 categorias de ataque          |
|    XSS | SQLi | CMD_INJ | PATH_TRAVERSAL         |
|    SSRF | XXE | JNDI | NoSQLi | SSTI             |
|    PROTOTYPE_POLLUTION | OPEN_REDIRECT           |
|    HTTP_HEADER_INJECTION                         |
|                                                  |
|  CheckResponse(resp, body)                       |
|    - RESPONSE_SQL_ERROR                          |
|    - RESPONSE_STACK_TRACE                        |
|    - RESPONSE_XSS_PATTERN                        |
|    - RESPONSE_FILE_LEAK                          |
----------------------------------------------------
```

---

### Fluxo de uma requisição

```text
Requisição HTTP/S chegando
        |
        v
[1] Gerar request_id (X-Request-ID)
        |
        v
[2] Extrair IP real (X-Forwarded-For com proxies confiáveis)
        |
        v
[3] Blocklist — IP bloqueado?
        | sim -> 403 Forbidden
        | não
        v
[4] Método proibido? (TRACE/TRACK)
        | sim -> 405 Method Not Allowed
        | não
        v
[5] Rate limit — tokens disponíveis?
        | não -> 429 Too Many Requests (Retry-After: 30)
        | sim
        v
[6] WAF — inspeção de path, query, headers, body e multipart
        | body acima de MAX_BODY_SIZE -> 413 Payload Too Large
        | ameaça detectada (modo block) -> 400 Bad Request
        | ameaça detectada (modo monitor) -> log e continua
        | limpo
        v
[7] Injetar X-Forwarded-For, X-Real-IP, X-Forwarded-Proto
        |
        v
[8] Encaminhar ao backend (httputil.ReverseProxy)
        | backend indisponível -> 502 Bad Gateway
        v
[9] ModifyResponse: remover headers de versão e injetar headers de segurança
        |
        v
[10] Inspeção de resposta (SQL errors, stack traces, file leaks, XSS)
        | ameaça (modo block) -> 502 + JSON
        | limpo
        v
Resposta ao cliente
```

---

## Funcionalidades

| Camada | Recurso | Configuração |
|---|---|---|
| Rede | Terminação TLS (TLS 1.2+, ECDHE, AES-256-GCM) | `CERT_FILE`, `KEY_FILE` |
| Acesso | Blocklist por IP e CIDR | `BLOCKED_IPS` |
| Acesso | Rate limiting (token bucket por IP) | `RATE_LIMIT`, `BURST_LIMIT`, `MAX_CONNS` |
| WAF | Inspeção de requisição (12 categorias) | `ENABLE_WAF`, `WAF_MODE` |
| WAF | Inspeção de resposta (4 categorias) | `ENABLE_RESPONSE_INSPECTION` |
| WAF | Allowlist por categoria e rota | `WAF_ALLOWLIST` |
| WAF | Modo de Treinamento: log estruturado de bloqueios + relatório HTML | `TRAINING_MODE`, `TRAINING_LOG_FILE` |
| Headers | Remoção de headers de versão (`Server`, `X-Powered-By`) | automático |
| Headers | Injeção de headers defensivos (HSTS, X-Frame, CSP etc.) | automático |
| Proxy | IP real de clientes atrás de proxy confiável | `TRUSTED_PROXIES` |
| Proxy | Suporte a WebSocket (inspeciona handshake) | automático |

---

## Variáveis de ambiente

| Variável | Padrão | Descrição |
|---|---|---|
| `TARGET_URL` | `http://localhost:4280` | URL da aplicação protegida |
| `PROXY_PORT` | `:443` | Porta de escuta do DoBot Shield |
| `HTTP_MODE` | `false` | `true` = HTTP puro (laboratório); qualquer outro valor = HTTPS |
| `ENABLE_WAF` | `true` | Liga/desliga o WAF |
| `WAF_MODE` | `block` | `block`, `monitor` ou `off` |
| `ENABLE_RESPONSE_INSPECTION` | `true` | Inspeção de respostas do backend |
| `RESPONSE_INSPECTION_LIMIT` | `1048576` | Limite de bytes por resposta inspecionada |
| `WAF_ALLOWLIST` | vazio | Exceções, por exemplo `SQLi:/api/search,/health` |
| `BLOCKED_IPS` | vazio | IPs/CIDRs bloqueados antes do WAF, por exemplo `1.2.3.4,10.0.0.0/8` |
| `ENABLE_RATE_LIMIT` | `true` | Liga/desliga o rate limiting |
| `RATE_LIMIT` | `10.0` | Requisições por segundo por IP |
| `BURST_LIMIT` | `20` | Pico permitido (token bucket) |
| `MAX_CONNS` | `10` | Conexões simultâneas por IP |
| `MAX_TRACKED_IPS` | `10000` | IPs monitorados em memória |
| `RATE_LIMIT_STATE_FILE` | vazio | Arquivo de persistência do rate limiter |
| `MAX_BODY_SIZE` | `1048576` | Limite do body da requisição em bytes |
| `CERT_FILE` | `server.crt` | Certificado TLS |
| `KEY_FILE` | `server.key` | Chave privada TLS |
| `TRUSTED_PROXIES` | `127.0.0.1,::1` | Proxies confiáveis (CSV de IPs/CIDRs) |
| `INSECURE_SKIP_VERIFY` | `false` | Ignora TLS do backend (apenas em laboratório) |
| `CONTENT_SECURITY_POLICY` | vazio | Header CSP opcional |
| `TRAINING_MODE` | `true` | Registra cada bloqueio em JSON estruturado (Modo de Treinamento) |
| `TRAINING_LOG_FILE` | `logs/training.jsonl` | Arquivo JSON Lines do Modo de Treinamento |

Em `HTTP_MODE`, somente o valor `true` ativa HTTP puro. Campos numéricos inválidos ou menores que o mínimo aceito retornam ao valor-padrão do código.

---

## Modo monitor

Use `WAF_MODE=monitor` para registrar detecções sem bloquear. Esse modo é recomendado antes de ativar `block` em produção.

```text
WAF_DETECT          -> requisição suspeita registrada, encaminhada
WAF_BLOCK           -> requisição bloqueada (modo block)
RESPONSE_WAF_DETECT -> resposta suspeita registrada, encaminhada
RESPONSE_WAF_BLOCK  -> resposta bloqueada (modo block)
IP_BLOCK            -> IP na blocklist, bloqueado antes do WAF
DoS_BLOCK           -> rate limit excedido
```

---

## Allowlist WAF

Exceções cirúrgicas para evitar falsos positivos em rotas específicas:

```text
WAF_ALLOWLIST=SQLi:/api/search,XSS:/editor,/health
```

- `SQLi:/api/search`: libera apenas SQLi nessa rota.
- `/health`: libera qualquer categoria em `/health`.

A comparação é feita por prefixo de caminho: a regra vale para o caminho informado e tudo abaixo dele.

---

## Modo de Treinamento

Com `TRAINING_MODE=true` (padrão), cada requisição barrada gera um registro JSON estruturado em `TRAINING_LOG_FILE` (padrão `logs/training.jsonl`) contendo o payload original, as variantes geradas pelas decodificações, a categoria, a regra acionada, o timestamp e o IP.

O relatório HTML didático (linha do tempo do ataque) é gerado por um utilitário separado, sem backend:

```powershell
gerar_relatorio.bat            # Windows: gera e abre training-report.html
go run ./cmd/report -open      # multiplataforma
```

O registro é totalmente aditivo: nunca altera a decisão do WAF e, em caso de falha de escrita, é silenciosamente desativado. Detalhes completos em [MODO_TREINAMENTO.md](MODO_TREINAMENTO.md).

---

## Categorias de ataque detectadas

**Requisição:** XSS, SQLi, CMD_INJ, PATH_TRAVERSAL, SSRF, XXE, JNDI, NoSQLi, SSTI, PROTOTYPE_POLLUTION, OPEN_REDIRECT, HTTP_HEADER_INJECTION

**Resposta:** RESPONSE_SQL_ERROR, RESPONSE_STACK_TRACE, RESPONSE_XSS_PATTERN, RESPONSE_FILE_LEAK

---

## Compilar e testar

```powershell
# Compilar
go build -o dobotshield.exe .
Get-FileHash .\dobotshield.exe -Algorithm SHA256

# Testes automatizados
$env:GOCACHE = Join-Path (Get-Location) '.gocache'
go test -count=1 ./...
```

---

## Bancada de comparação de WAFs

O projeto traz uma bancada automatizada que mede o DoBotShield contra ModSecurity e Coraza (ambos com OWASP CRS) e contra o cenário sem WAF, usando duas aplicações vulneráveis: DVWA e XVWA. Esse é o experimento que sustenta a validação do TCC. Tudo roda em Docker, orquestrado por scripts `.bat` no Windows; o único pré-requisito é o Docker Desktop.

A composição principal da validação fica em `validacao/docker-compose.lab.yml`. Para cada aplicação há quatro cenários: **sem WAF**, **DoBotShield**, **ModSecurity + CRS** e **Coraza + CRS**.

Seis ferramentas atacam cada cenário com a **mesma chamada**; só muda a URL de destino, para que a diferença nos resultados venha do WAF, não da configuração do teste:

- **testssl.sh**: configuração TLS;
- **OWASP ZAP** (full scan): varredura ativa de vulnerabilidades;
- **SQLMap**: injeção de SQL;
- **XSStrike**: cross-site scripting;
- **Commix**: injeção de comando;
- **wrk**: carga e throughput.



Rodando por etapa (a partir de `validacao/scripts/`):

```powershell
lab_00_setup.bat       # checa o Docker, gera o certificado, sobe o DVWA,
                       # faz login admin/password, define security=low,
                       # captura o cookie e cria o banco do XVWA
lab_01_subir.bat       # sobe todos os containers (aplicações + WAFs)
lab_02_testssl.bat     # testssl.sh
lab_03_zap_isolado.bat # OWASP ZAP, um alvo por vez
lab_04_sqlmap.bat      # SQLMap
lab_05_xsstrike.bat    # XSStrike
lab_06_commix.bat      # Commix
lab_07_wrk.bat         # wrk
lab_99_derrubar.bat    # derruba o lab
```

O ZAP usa a mesma política nos oito destinos e ignora uniformemente a regra
ativa 40026 (DOM XSS), que encerrava o processo Java nesta bancada. XSS
refletido continua coberto pelo ZAP e pelo XSStrike. O `wrk` executa uma vez
por cenário. A bancada chegou a produzir três execuções por engano; para
restabelecer o desenho planejado com `n = 1` sem selecionar pelo desempenho,
foi mantida sistematicamente a primeira execução completa de cada cenário e as
duas posteriores foram excluídas. A entrega contém somente a rodada consolidada;
tentativas interrompidas por falha de infraestrutura não fazem parte dos
resultados.

O SQLMap foi executado sem tamper, com `--technique=B --level=1 --risk=1`,
marcador de resposta por aplicação e atraso de `0.3 s`. Os dois acessos diretos
confirmaram a SQLi booleana; ModSecurity, DoBotShield e Coraza impediram a
confirmação. O tamper `equaltolike` foi removido para avaliar o WAF sem
mascaramento do operador de comparação; a regra corrigida também bloqueia
variantes com `LIKE` e `~`, verificadas em teste ponta a ponta. A configuração
de carga do DoBotShield na bancada foi calibrada em
`RATE_LIMIT=10000`, `BURST_LIMIT=20000` e `MAX_CONNS=500`, sem alterar os
valores-padrão do produto mostrados anteriormente.

Resumo da rodada consolidada:

| Aplicação | Cenário | ZAP HIGH | SQLMap | XSStrike | Commix | wrk req/s | não 2xx/3xx |
|---|---|---:|---|---|---|---:|---:|
| DVWA | sem WAF | 1 | vulnerável | XSS confirmado | injeção confirmada | 5.327,70 | 0 |
| DVWA | ModSecurity | 2 | não injetável | bloqueado | bloqueado | 1.539,92 | 0 |
| DVWA | DoBotShield | 1 | não injetável | bloqueado | bloqueado | 2.299,94 | 0 |
| DVWA | Coraza | 0 | não injetável | bloqueado | bloqueado | 2.039,97 | 0 |
| XVWA | sem WAF | 5 | vulnerável | XSS confirmado | injeção confirmada | 641,58 | 0 |
| XVWA | ModSecurity | 1 | não injetável | bloqueado | bloqueado | 368,64 | 0 |
| XVWA | DoBotShield | 1 | não injetável | bloqueado | bloqueado | 142,34 | 0 |
| XVWA | Coraza | 1 | não injetável | bloqueado | bloqueado | 131,94 | 0 |

Os resultados ficam em `validacao/results/<app>/<cenario>/`, com um log por ferramenta, snapshots de saúde/recursos, relatórios do ZAP e logs dos WAFs. A entrega atual contém resultados para:

- `dvwa/no_waf`, `dvwa/dobotshield`, `dvwa/modsecurity`, `dvwa/coraza`;
- `xvwa/no_waf`, `xvwa/dobotshield`, `xvwa/modsecurity`, `xvwa/coraza`.

O resumo interpretativo está em [validacao/docs/RELATORIO_RESULTADOS.md](validacao/docs/RELATORIO_RESULTADOS.md), e a metodologia completa está em [validacao/docs/METODOLOGIA.txt](validacao/docs/METODOLOGIA.txt).
---

## Estrutura do projeto

```
.
|-- main.go                    Ponto de entrada, TLS e HTTP_MODE
|-- go.mod
|-- .gitignore
|-- Dockerfile                 Imagem do DoBotShield
|
|-- admin-config/              Interface web de configuração (HTML/CSS/JS estático)
|   |-- index.html
|   |-- scripts/               Lógica de validação e geração de comandos
|   |   |-- app.js
|   |   |-- clipboard.js
|   |   |-- config-schema.js
|   |   |-- dom.js
|   |   |-- download.js
|   |   |-- formatters.js
|   |   |-- render.js
|   |   |-- storage.js
|   |   `-- validators.js
|   `-- styles/
|       |-- tokens.css         Design tokens
|       |-- base.css           Estilos base
|       |-- components.css     Componentes da interface
|       `-- report.css         CSS do relatório de treinamento
|
|-- blocklist/
|   |-- blocklist.go           Bloqueio por IP e CIDR
|   `-- blocklist_test.go
|
|-- config/
|   |-- config.go              Leitura de variáveis de ambiente
|   `-- config_test.go
|
|-- middleware/
|   |-- middleware.go          Proxy reverso, handlers, inspeção de req/resp
|   `-- middleware_test.go
|
|-- ratelimit/
|   |-- ratelimit.go           Token bucket com LRU e persistência
|   `-- ratelimit_test.go
|
|-- utils/
|   |-- utils.go               IP real, request ID e logging
|   `-- utils_test.go
|
|-- waf/
|   |-- waf.go                 Inspeção de requisição e resposta
|   |-- patterns.go            Padrões regex por categoria de ataque
|   |-- training.go            Detalhes de bloqueio para o Modo de Treinamento
|   |-- training_test.go
|   `-- waf_test.go
|
|-- traininglog/
|   |-- traininglog.go         Log estruturado (JSON Lines) de bloqueios
|   `-- traininglog_test.go
|
|-- report/                    Agrega o log e gera o training-report.html
|   |-- report.go
|   |-- template.go
|   |-- glossary.go
|   |-- cssloader.go
|   `-- report_test.go
|
|-- cmd/
|   `-- report/                CLI que gera o training-report.html
|       `-- main.go
|
|-- certificado/
|   `-- gerar_cert.go          Gerador de certificado autoassinado
|
|-- validacao/                 Bancada de comparação de WAFs (validação do TCC)
|   |-- docker-compose.demo.yml  Lab de demonstração: DVWA + Mutillidae
|   |-- docker-compose.lab.yml   Bancada de comparação: DVWA + XVWA, 4 cenários
|   |-- docker/                  Dockerfiles da bancada
|   |   |-- coraza/              Coraza + Caddy + CRS
|   |   |-- lab-tools/           Imagem com SQLMap, XSStrike e Commix
|   |   |-- wrk/                 Imagem do wrk
|   |   `-- xvwa/                Imagem do XVWA
|   |-- docs/                    Documentação da bancada
|   |   |-- METODOLOGIA.txt      Metodologia da bancada
|   |   |-- RELATORIO_RESULTADOS.md  Relatório interpretativo dos resultados
|   |   `-- DOS_LOG_GUIDE.md     Guia do teste de carga/DoS
|   |-- helpers/                 Scripts auxiliares (login DVWA, setup XVWA, hook ZAP)
|   |-- results/                 Logs e evidências da bancada de validação
|   |   |-- dvwa/                4 cenários × 6 ferramentas
|   |   |-- xvwa/                4 cenários × 6 ferramentas
|   |   |-- ANALISE_RESULTADOS.json
|   |   |-- RESUMO_RESULTADOS.txt
|   |   `-- METODOLOGIA.txt
|   |-- scripts/                 Scripts .bat/.ps1 do laboratório
|   |   |-- lab_00_setup.bat
|   |   |-- lab_01_subir.bat
|   |   |-- lab_02_testssl.bat
|   |   |-- lab_03_zap.bat / lab_03_zap_isolado.bat
|   |   |-- lab_04_sqlmap.bat
|   |   |-- lab_05_xsstrike.bat
|   |   |-- lab_06_commix.bat
|   |   |-- lab_07_wrk.bat
|   |   |-- lab_0X_*_one.bat       Execuções unitárias usadas pelos runners
|   |   |-- lab_99_derrubar.bat
|   |   `-- lab_lib.bat
|
|-- gerar_relatorio.bat        Gera e abre o training-report.html
`-- MODO_TREINAMENTO.md        Documentação do Modo de Treinamento
```

`training-report.html` é um artefato local gerado sob demanda por
`gerar_relatorio.bat` ou `go run ./cmd/report`; ele não faz parte do estado
versionado desta pasta.
