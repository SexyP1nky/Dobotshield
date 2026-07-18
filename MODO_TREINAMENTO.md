# Modo de Treinamento — DoBot Shield

O **Modo de Treinamento** registra, para cada requisição (ou resposta) barrada
pelo WAF, um evento JSON estruturado e gera, a partir desses registros, um
relatório HTML didático com a **linha do tempo do ataque**: o que foi tentado,
como o payload foi transformado pelas decodificações e qual regra exata disparou
a defesa.

O objetivo é posicioná-lo, no artigo, como um **diferencial para equipes que
querem aprender sobre ataques web enquanto protegem sistemas legados**: o mesmo
proxy que bloqueia o ataque também serve de material de estudo.

Operacionalmente, o recurso também apoia a calibração de falsos positivos. O
fluxo recomendado é registrar em Modo de Treinamento, observar primeiro com
`WAF_MODE=monitor`, revisar categoria e rota, aplicar uma allowlist restrita
quando necessária e somente então ativar `block`. Na amostra complementar de
18/07/2026, 20 de 100 requisições legítimas ao DVWA foram bloqueadas em duas
rotas didáticas, enquanto o XVWA teve 0 de 100; os eventos permitiram identificar
`RESPONSE_SQL_ERROR` em `/instructions.php` e `RESPONSE_XSS_PATTERN` em
`/security.php`. As evidências estão em
`validacao/results/falsos_positivos/`; o ensaio é exploratório e não representa
uma taxa de produção.

> **Garantia de não-intrusão:** todo o recurso é aditivo. Ele observa o ponto em
> que o WAF já decidiu bloquear e nunca altera essa decisão. Se o registro
> falhar (disco cheio, diretório somente leitura), o logger entra em modo
> degradado e o WAF continua funcionando normalmente.

---

## 1. O que é registrado

Cada bloqueio vira uma linha JSON (formato **JSON Lines**, um objeto por linha)
no arquivo de log. Esquema de cada evento:

| Campo         | Descrição                                                            |
|---------------|----------------------------------------------------------------------|
| `timestamp`   | Data/hora em UTC (RFC3339).                                          |
| `request_id`  | Identificador de correlação com os logs de acesso.                  |
| `ip`          | IP de origem do cliente.                                            |
| `method`      | Método HTTP (apenas na fase de requisição).                        |
| `path`        | Caminho alvo.                                                       |
| `phase`       | `request` (ataque do cliente) ou `response` (vazamento do backend). |
| `action`      | `blocked` (modo block) ou `detected` (modo monitor).               |
| `category`    | Categoria da ameaça: `XSS`, `SQLi`, `CMD_INJ`, `JNDI`, etc.        |
| `location`    | Onde foi encontrada: `Query`, `Body`, `Path`, `Header User-Agent`… |
| `rule`        | **Regra específica** acionada (a própria regex do WAF).            |
| `payload`     | **Payload original** recebido no campo que casou.                  |
| `variants`    | **Variantes geradas** pelo WAF ao decodificar o payload.          |

Exemplo de uma linha (XSS codificado em URL):

```json
{"timestamp":"2026-06-02T14:02:11Z","ip":"203.0.113.10","method":"GET",
 "path":"/vulnerabilities/xss_r/","phase":"request","action":"blocked",
 "category":"XSS","location":"Query","rule":"(?i)<\\s*script",
 "payload":"name=%3Cscript%3Ealert(document.cookie)%3C%2Fscript%3E",
 "variants":["name=%3Cscript%3Ealert(...)%3C%2Fscript%3E",
             "name=<script>alert(document.cookie)</script>"]}
```

As `variants` são exatamente a cadeia de transformações que o motor de inspeção
aplica internamente (decodificação de URL, de entidades HTML, de escapes
`\\uXXXX`/`\\xXX`, remoção de comentários, normalização de separadores), o que
torna visível **como o WAF "enxerga" um ataque ofuscado**.

---

## 2. Configuração

O recurso é controlado por duas variáveis de ambiente (também editáveis pela
**Admin UI**, na seção *Modo de Treinamento*):

| Variável             | Padrão                 | Função                                        |
|----------------------|------------------------|-----------------------------------------------|
| `TRAINING_MODE`      | `true`                 | Liga/desliga o registro estruturado.         |
| `TRAINING_LOG_FILE`  | `logs/training.jsonl`  | Caminho do arquivo de log (deixe vazio para desativar). |

Nos laboratórios versionados, os serviços `dobotshield_*` já definem essas
variáveis e persistem os eventos no host:

- `validacao/docker-compose.demo.yml`: `validacao/logs/training/<app>/`;
- `validacao/docker-compose.lab.yml`: `validacao/logs/training/<app>/`.

Esses logs são artefatos locais de execução e não fazem parte dos resultados
consolidados versionados em `validacao/results/`.

Em uma implantação própria, monte o diretório indicado por
`TRAINING_LOG_FILE` em um volume persistente.

---

## 3. Gerando o relatório HTML

O relatório é produzido por um utilitário **separado** do binário do WAF — ele
não abre portas nem toca no proxy.

**Windows (script pronto):**

```bat
gerar_relatorio.bat
```

**Multiplataforma (Go):**

```bash
go run ./cmd/report                 # lê logs/training.jsonl -> training-report.html
go run ./cmd/report -open           # gera e abre no navegador
go run ./cmd/report -in caminho.jsonl -out relatorio.html
```

Na Admin UI, a seção *Modo de Treinamento* traz o comando e um botão
**“Abrir relatório”** apontando para `../training-report.html`. O link funciona
depois que o relatório tiver sido gerado; o HTML não é versionado nesta pasta.

---

## 4. O que o relatório mostra

- **Resumo:** total de eventos, bloqueados × detectados, requisição × resposta,
  IPs distintos e número de regras acionadas.
- **Distribuição por categoria** e **principais origens (IP)** em barras.
- **Linha do tempo do ataque:** cada evento como um cartão com payload original,
  variantes decodificadas (expansíveis), regra acionada, categoria, localização,
  método/caminho, IP e horário.
- **Filtros client-side** (busca por texto, categoria e fase) — sem backend.

> **Segurança do próprio relatório:** ele é gerado com `html/template`, então
> todo payload de ataque é **escapado** e exibido como texto inerte, nunca
> executado pelo navegador que abrir o arquivo.

---

## 5. Onde isso encaixa na arquitetura

```
Requisição ──► middleware (decisão de bloqueio (inalterada))
                   │  WAF_BLOCK / WAF_DETECT
                   ▼
            waf.DescribeBlock  ── localiza payload + gera variantes
                   ▼
            traininglog.Record ── grava JSON Lines (tolerante a falhas)
                   │
                   ▼
            logs/training.jsonl ──► cmd/report ──► training-report.html
```

Componentes adicionados (nenhuma função crítica do WAF foi modificada em sua
lógica de decisão):

- `traininglog/` — logger JSON Lines thread-safe e tolerante a falhas.
- `waf/training.go` — `DescribeBlock`, que a partir do resultado de
  `CheckRequest` localiza o payload e deriva as variantes.
- `report/` — geração do HTML com `html/template`.
- `cmd/report/` — utilitário de linha de comando.
- Integração mínima e aditiva em `middleware/` e `main.go`.
