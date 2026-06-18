package report

import (
	"html/template"
	"os"
	"path/filepath"
	"runtime"
)

// reportCSSRelPath e o caminho da folha de estilo do relatorio dentro do
// projeto. O CSS vive em admin-config/styles/report.css (fonte unica de
// edicao); o gerador o injeta embutido no HTML para o relatorio continuar
// autocontido (abre e e compartilhado sem depender de arquivos externos).
var reportCSSRelPath = filepath.Join("admin-config", "styles", "report.css")

// loadReportCSS le a folha de estilo do relatorio e a devolve como CSS seguro
// para interpolacao no template. Procura primeiro relativo ao codigo-fonte
// (robusto a qualquer diretorio de trabalho) e depois relativo ao diretorio
// atual. Se nao encontrar o arquivo, cai para um estilo minimo, de modo que o
// relatorio nunca saia completamente sem formatacao.
func loadReportCSS() template.CSS {
	for _, path := range reportCSSCandidates() {
		if data, err := os.ReadFile(path); err == nil {
			return template.CSS(data)
		}
	}
	return template.CSS(fallbackReportCSS)
}

// reportCSSCandidates lista os caminhos onde o report.css pode estar, em ordem
// de preferencia.
func reportCSSCandidates() []string {
	paths := make([]string, 0, 2)
	if _, file, _, ok := runtime.Caller(0); ok {
		// file = <projeto>/report/cssloader.go ; sobe um nivel ate a raiz.
		paths = append(paths, filepath.Join(filepath.Dir(file), "..", reportCSSRelPath))
	}
	paths = append(paths, reportCSSRelPath)
	return paths
}

// fallbackReportCSS e um estilo de seguranca, usado apenas quando report.css
// nao pode ser lido. Mantem o relatorio legivel; o visual completo vive em
// admin-config/styles/report.css.
const fallbackReportCSS = `
  body{margin:0;padding:24px;font-family:system-ui,-apple-system,sans-serif;line-height:1.5;color:#1f2925;background:#f7f9f8}
  .wrap{max-width:1180px;margin:0 auto}
  .card,.panel,.event,.gloss-item{border:1px solid #d8e0dc;border-radius:10px;padding:16px;margin-bottom:12px;background:#fff}
  .badge,.pill{padding:2px 8px;border-radius:999px;font-size:.74rem}
  pre.payload{background:#10221f;color:#e7f4f0;padding:12px;border-radius:8px;overflow:auto}
`
