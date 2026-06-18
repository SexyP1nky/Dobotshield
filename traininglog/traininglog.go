// Package traininglog registra, de forma estruturada (JSON Lines), cada
// requisicao ou resposta barrada pelo WAF. Esses registros alimentam o
// "Modo de Treinamento": um relatorio HTML que mostra, para fins didaticos,
// o que foi tentado contra a aplicacao legada e como o DoBot Shield reagiu.
//
// O logger e deliberadamente tolerante a falhas: qualquer problema de escrita
// apenas o coloca em modo degradado e e ignorado pelo restante do sistema.
// Registrar um evento de treinamento NUNCA pode interromper o processamento
// de uma requisicao nem alterar a decisao de seguranca do WAF.
package traininglog

import (
	"bufio"
	"bytes"
	"encoding/json"
	"log"
	"os"
	"path/filepath"
	"sync"
	"unicode/utf8"
)

// Event descreve um unico bloqueio (ou deteccao em modo monitor) em formato
// estruturado. As tags JSON definem o esquema gravado em disco e lido pelo
// gerador de relatorios.
type Event struct {
	Timestamp string   `json:"timestamp"`            // RFC3339 em UTC
	RequestID string   `json:"request_id,omitempty"` // correlacao com os logs de acesso
	IP        string   `json:"ip"`                   // origem do cliente
	Method    string   `json:"method,omitempty"`     // metodo HTTP (apenas fase de requisicao)
	Path      string   `json:"path,omitempty"`       // caminho alvo
	Phase     string   `json:"phase"`                // "request" ou "response"
	Action    string   `json:"action"`               // "blocked" ou "detected"
	Category  string   `json:"category"`             // categoria da ameaca (XSS, SQLi, ...)
	Location  string   `json:"location,omitempty"`   // onde foi encontrada (Query, Body, Header ...)
	Rule      string   `json:"rule"`                 // regra especifica (regex/identificador) acionada
	Payload   string   `json:"payload"`              // payload original recebido
	Variants  []string `json:"variants,omitempty"`   // variantes geradas apos as decodificacoes do WAF
}

// Limites de tamanho para impedir que payloads gigantes inflem o arquivo de
// log ou o relatorio. Sao generosos o bastante para fins didaticos.
const (
	maxPayloadBytes = 8 * 1024
	maxRuleBytes    = 2 * 1024
	maxVariantBytes = 4 * 1024
	maxVariants     = 16
)

const truncationMark = "...(truncado)"

// Logger grava eventos em um arquivo no formato JSON Lines (um JSON por linha).
// E seguro para uso concorrente.
type Logger struct {
	mu       sync.Mutex
	file     *os.File
	path     string
	enabled  bool
	degraded bool
}

// New abre (ou cria) o arquivo de log no caminho informado, criando os
// diretorios necessarios. Em caso de erro, devolve um logger em modo degradado
// que silenciosamente descarta eventos — nunca um nil ou um panic.
func New(path string) *Logger {
	l := &Logger{path: path}
	if path == "" {
		l.degraded = true
		return l
	}

	if dir := filepath.Dir(path); dir != "" && dir != "." {
		if err := os.MkdirAll(dir, 0o755); err != nil {
			log.Printf("traininglog: nao foi possivel criar o diretorio %q: %v", dir, err)
			l.degraded = true
			return l
		}
	}

	file, err := os.OpenFile(path, os.O_CREATE|os.O_WRONLY|os.O_APPEND, 0o644)
	if err != nil {
		log.Printf("traininglog: nao foi possivel abrir %q para escrita: %v", path, err)
		l.degraded = true
		return l
	}

	l.file = file
	l.enabled = true
	return l
}

// Enabled informa se o logger esta operacional (habilitado e sem falhas).
func (l *Logger) Enabled() bool {
	if l == nil {
		return false
	}
	l.mu.Lock()
	defer l.mu.Unlock()
	return l.enabled && !l.degraded && l.file != nil
}

// Record serializa e grava um evento. Qualquer falha apenas marca o logger
// como degradado; o chamador nao precisa (nem deve) tratar erros aqui.
func (l *Logger) Record(ev Event) {
	if l == nil {
		return
	}

	l.mu.Lock()
	defer l.mu.Unlock()

	if !l.enabled || l.degraded || l.file == nil {
		return
	}

	data, err := json.Marshal(sanitize(ev))
	if err != nil {
		return
	}
	data = append(data, '\n')

	if _, err := l.file.Write(data); err != nil {
		log.Printf("traininglog: falha ao gravar evento, registro desativado: %v", err)
		l.degraded = true
	}
}

// Close libera o arquivo subjacente. Seguro de chamar mais de uma vez.
func (l *Logger) Close() error {
	if l == nil {
		return nil
	}
	l.mu.Lock()
	defer l.mu.Unlock()

	l.enabled = false
	if l.file == nil {
		return nil
	}
	err := l.file.Close()
	l.file = nil
	return err
}

// sanitize aplica os limites de tamanho sem mutar as fatias do chamador.
func sanitize(ev Event) Event {
	ev.Payload = truncate(ev.Payload, maxPayloadBytes)
	ev.Rule = truncate(ev.Rule, maxRuleBytes)

	if len(ev.Variants) > 0 {
		limit := len(ev.Variants)
		if limit > maxVariants {
			limit = maxVariants
		}
		variants := make([]string, limit)
		for i := 0; i < limit; i++ {
			variants[i] = truncate(ev.Variants[i], maxVariantBytes)
		}
		ev.Variants = variants
	}

	return ev
}

// truncate corta a string em no maximo max bytes, respeitando o limite de runas
// UTF-8, e acrescenta uma marca indicando o corte.
func truncate(s string, max int) string {
	if len(s) <= max {
		return s
	}

	cut := max
	for cut > 0 && !utf8.RuneStart(s[cut]) {
		cut--
	}
	return s[:cut] + truncationMark
}

// Load le todos os eventos de um arquivo JSON Lines. Linhas em branco ou
// corrompidas sao ignoradas para que um registro malformado nao inviabilize o
// relatorio inteiro.
func Load(path string) ([]Event, error) {
	file, err := os.Open(path)
	if err != nil {
		return nil, err
	}
	defer file.Close()

	var events []Event
	scanner := bufio.NewScanner(file)
	// Acomoda payloads/variantes proximos dos limites definidos acima.
	scanner.Buffer(make([]byte, 0, 64*1024), 2*1024*1024)

	for scanner.Scan() {
		line := bytes.TrimSpace(scanner.Bytes())
		if len(line) == 0 {
			continue
		}
		var ev Event
		if err := json.Unmarshal(line, &ev); err != nil {
			continue
		}
		events = append(events, ev)
	}

	if err := scanner.Err(); err != nil {
		return events, err
	}
	return events, nil
}

// 
// Logger global (padrao). Permite que o middleware registre eventos sem alterar
// assinaturas existentes. Funciona de forma analoga ao pacote log padrao.
// 

var (
	defaultMu     sync.RWMutex
	defaultLogger *Logger
)

// Configure (re)inicializa o logger global. Quando enabled e falso, o registro
// fica desligado e Record vira uma operacao nula.
func Configure(enabled bool, path string) {
	defaultMu.Lock()
	defer defaultMu.Unlock()

	if defaultLogger != nil {
		_ = defaultLogger.Close()
		defaultLogger = nil
	}
	if !enabled {
		return
	}
	defaultLogger = New(path)
}

// Enabled informa se o logger global esta operacional.
func Enabled() bool {
	defaultMu.RLock()
	defer defaultMu.RUnlock()
	return defaultLogger.Enabled()
}

// Record grava um evento usando o logger global.
func Record(ev Event) {
	defaultMu.RLock()
	logger := defaultLogger
	defaultMu.RUnlock()
	logger.Record(ev)
}

// CloseDefault encerra o logger global (usado no encerramento da aplicacao).
func CloseDefault() error {
	defaultMu.Lock()
	defer defaultMu.Unlock()
	if defaultLogger == nil {
		return nil
	}
	err := defaultLogger.Close()
	defaultLogger = nil
	return err
}
