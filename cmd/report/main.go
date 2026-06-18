// Comando report: gera o relatorio HTML do "Modo de Treinamento" do DoBot Shield
// a partir do log estruturado (JSON) de ataques barrados.
//
// Uso:
//
//	go run ./cmd/report                         # le logs/training.jsonl -> training-report.html
//	go run ./cmd/report -in caminho.jsonl -out relatorio.html
//	go run ./cmd/report -open                   # abre o relatorio no navegador ao final
//
// E um utilitario separado do binario principal do WAF: nao abre portas, nao
// exige backend e nao toca em nenhuma funcao do proxy.
package main

import (
	"flag"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"sort"

	"dobotshield/report"
	"dobotshield/traininglog"
)

func main() {
	defaultIn := os.Getenv("TRAINING_LOG_FILE")
	if defaultIn == "" {
		defaultIn = filepath.Join("logs", "training.jsonl")
	}

	in := flag.String("in", defaultIn, "arquivo de log JSON Lines do Modo de Treinamento")
	out := flag.String("out", "training-report.html", "arquivo HTML de saida")
	open := flag.Bool("open", false, "abrir o relatorio no navegador ao final")
	flag.Parse()

	if err := run(*in, *out, *open); err != nil {
		fmt.Fprintf(os.Stderr, "erro: %v\n", err)
		os.Exit(1)
	}
}

func run(in, out string, open bool) error {
	events, err := traininglog.Load(in)
	if err != nil {
		if os.IsNotExist(err) {
			return fmt.Errorf("log de treinamento nao encontrado em %q. "+
				"Suba o WAF com TRAINING_MODE=true e gere trafego de ataque primeiro", in)
		}
		return fmt.Errorf("lendo %q: %w", in, err)
	}

	file, err := os.Create(out)
	if err != nil {
		return fmt.Errorf("criando %q: %w", out, err)
	}
	defer file.Close()

	if err := report.Generate(events, in, file); err != nil {
		return fmt.Errorf("gerando relatorio: %w", err)
	}
	if err := file.Close(); err != nil {
		return fmt.Errorf("finalizando %q: %w", out, err)
	}

	abs, _ := filepath.Abs(out)
	printSummary(events, abs)

	if open {
		if err := openInBrowser(abs); err != nil {
			fmt.Fprintf(os.Stderr, "aviso: nao foi possivel abrir o navegador: %v\n", err)
		}
	}
	return nil
}

func printSummary(events []traininglog.Event, outPath string) {
	categories := map[string]int{}
	blocked, detected := 0, 0
	for _, ev := range events {
		categories[ev.Category]++
		switch ev.Action {
		case "blocked":
			blocked++
		case "detected":
			detected++
		}
	}

	fmt.Println("Relatorio do Modo de Treinamento gerado.")
	fmt.Printf("  Eventos:     %d (%d bloqueados, %d detectados)\n", len(events), blocked, detected)
	fmt.Printf("  Categorias:  %s\n", formatCategories(categories))
	fmt.Printf("  Arquivo:     %s\n", outPath)
}

func formatCategories(categories map[string]int) string {
	if len(categories) == 0 {
		return "(nenhuma)"
	}
	type kv struct {
		name  string
		count int
	}
	pairs := make([]kv, 0, len(categories))
	for name, count := range categories {
		pairs = append(pairs, kv{name, count})
	}
	sort.Slice(pairs, func(i, j int) bool {
		if pairs[i].count != pairs[j].count {
			return pairs[i].count > pairs[j].count
		}
		return pairs[i].name < pairs[j].name
	})

	out := ""
	for i, p := range pairs {
		if i > 0 {
			out += ", "
		}
		out += fmt.Sprintf("%s=%d", p.name, p.count)
	}
	return out
}

func openInBrowser(path string) error {
	switch runtime.GOOS {
	case "windows":
		return exec.Command("rundll32", "url.dll,FileProtocolHandler", path).Start()
	case "darwin":
		return exec.Command("open", path).Start()
	default:
		return exec.Command("xdg-open", path).Start()
	}
}
