package report

import (
	"bytes"
	"strings"
	"testing"

	"dobotshield/traininglog"
)

func sampleEvents() []traininglog.Event {
	return []traininglog.Event{
		{
			Timestamp: "2026-06-02T10:05:00Z",
			IP:        "203.0.113.11",
			Method:    "POST",
			Path:      "/items",
			Phase:     "request",
			Action:    "blocked",
			Category:  "SQLi",
			Location:  "Body",
			Rule:      "union select",
			Payload:   "id=1 UNION SELECT password",
			Variants:  []string{"id=1 UNION SELECT password"},
		},
		{
			Timestamp: "2026-06-02T10:00:00Z",
			IP:        "203.0.113.10",
			Method:    "GET",
			Path:      "/search",
			Phase:     "request",
			Action:    "blocked",
			Category:  "XSS",
			Location:  "Query",
			Rule:      "(?i)<\\s*script",
			Payload:   "q=<script>alert(1)</script>",
			Variants:  []string{"q=<script>alert(1)</script>", "q=<script>alert(1)</script>"},
		},
		{
			Timestamp: "2026-06-02T10:10:00Z",
			IP:        "203.0.113.10",
			Path:      "/profile",
			Phase:     "response",
			Action:    "detected",
			Category:  "RESPONSE_SQL_ERROR",
			Location:  "Response Body",
			Rule:      "SQLSTATE",
			Payload:   "SQLSTATE[42000]",
		},
	}
}

func TestBuildAggregates(t *testing.T) {
	report := Build(sampleEvents(), "logs/training.jsonl")

	if report.Total != 3 {
		t.Fatalf("expected total 3, got %d", report.Total)
	}
	if report.BlockedCount != 2 || report.DetectedCount != 1 {
		t.Fatalf("unexpected action counts: %d blocked, %d detected", report.BlockedCount, report.DetectedCount)
	}
	if report.RequestCount != 2 || report.ResponseCount != 1 {
		t.Fatalf("unexpected phase counts: %d req, %d resp", report.RequestCount, report.ResponseCount)
	}
	if report.UniqueIPs != 2 {
		t.Fatalf("expected 2 unique IPs, got %d", report.UniqueIPs)
	}
	// Timeline deve estar ordenada por timestamp ascendente.
	if report.Timeline[0].Category != "XSS" {
		t.Fatalf("expected earliest event (XSS) first, got %q", report.Timeline[0].Category)
	}
	if report.Timeline[2].Category != "RESPONSE_SQL_ERROR" {
		t.Fatalf("expected latest event last, got %q", report.Timeline[2].Category)
	}
	if report.FirstSeen == "" || report.LastSeen == "" {
		t.Fatalf("expected first/last seen to be set")
	}
}

func TestGenerateEscapesPayload(t *testing.T) {
	var buf bytes.Buffer
	if err := Generate(sampleEvents(), "logs/training.jsonl", &buf); err != nil {
		t.Fatalf("generate: %v", err)
	}
	html := buf.String()

	// O payload XSS NAO pode aparecer como tag executavel no relatorio.
	if strings.Contains(html, "<script>alert(1)</script>") {
		t.Fatalf("payload was not escaped (relatorio vulneravel a XSS armazenado)")
	}
	// Deve aparecer escapado.
	if !strings.Contains(html, "&lt;script&gt;alert(1)&lt;/script&gt;") {
		t.Fatalf("expected escaped payload in the report")
	}
	// Conteudo informativo esperado.
	if !strings.Contains(html, "Modo de Treinamento") {
		t.Fatalf("expected report title")
	}
	if !strings.Contains(html, "SQLi") || !strings.Contains(html, "XSS") {
		t.Fatalf("expected categories rendered")
	}
}

func TestGenerateEmpty(t *testing.T) {
	var buf bytes.Buffer
	if err := Generate(nil, "", &buf); err != nil {
		t.Fatalf("generate empty: %v", err)
	}
	if !strings.Contains(buf.String(), "Nenhum evento registrado") {
		t.Fatalf("expected empty-state message")
	}
}

func TestGlossaryCoversRequestedCategories(t *testing.T) {
	requested := []string{
		"SQLi", "CMD_INJ", "JNDI", "NoSQLi", "OPEN_REDIRECT",
		"PATH_TRAVERSAL", "RESPONSE_SQL_ERROR", "RESPONSE_XSS_PATTERN", "SSRF", "SSTI", "XSS",
	}
	for _, cat := range requested {
		info := lookupCategory(cat)
		if info.Title == defaultCategoryInfo.Title {
			t.Fatalf("category %q falls back to default title (sem explicacao dedicada)", cat)
		}
		if len(info.Attack) < 40 || len(info.Defense) < 30 {
			t.Fatalf("category %q tem explicacao curta demais: attack=%d defense=%d", cat, len(info.Attack), len(info.Defense))
		}
		if info.Summary == "" {
			t.Fatalf("category %q sem resumo (Summary)", cat)
		}
		if len(info.Subtypes) == 0 {
			t.Fatalf("category %q sem subtipos (esperado detalhamento por subtipo)", cat)
		}
		for _, st := range info.Subtypes {
			if st.Name == "" || st.Explanation == "" {
				t.Fatalf("category %q tem subtipo incompleto: %+v", cat, st)
			}
			if st.Example != "" && st.Reading == "" {
				t.Fatalf("category %q: subtipo %q tem exemplo sem traducao ludica", cat, st.Name)
			}
		}
	}
}

func TestLookupUnknownCategoryFallsBack(t *testing.T) {
	info := lookupCategory("ALGO_DESCONHECIDO")
	if info.Attack == "" || info.Defense == "" {
		t.Fatalf("expected generic explanation for unknown category")
	}
	if info.Title != "ALGO_DESCONHECIDO" {
		t.Fatalf("expected unknown category to keep its name as title, got %q", info.Title)
	}
}

func TestBuildPopulatesGlossaryAndEvents(t *testing.T) {
	report := Build(sampleEvents(), "logs/training.jsonl")

	if len(report.Glossary) != 3 {
		t.Fatalf("expected 3 glossary entries (XSS, SQLi, RESPONSE_SQL_ERROR), got %d", len(report.Glossary))
	}
	// Deve estar ordenado por contagem decrescente.
	for i := 1; i < len(report.Glossary); i++ {
		if report.Glossary[i-1].Count < report.Glossary[i].Count {
			t.Fatalf("glossary nao esta ordenado por contagem desc: %+v", report.Glossary)
		}
	}
	for _, entry := range report.Glossary {
		if entry.Attack == "" || entry.Defense == "" {
			t.Fatalf("glossary entry %q missing explanation", entry.Category)
		}
	}
	// Cada evento deve carregar sua explicação.
	for _, ev := range report.Timeline {
		if ev.Attack == "" || ev.Defense == "" {
			t.Fatalf("event %q (category %q) missing explanation", ev.Path, ev.Category)
		}
	}
}

func TestGenerateIncludesExplanations(t *testing.T) {
	var buf bytes.Buffer
	if err := Generate(sampleEvents(), "logs/training.jsonl", &buf); err != nil {
		t.Fatalf("generate: %v", err)
	}
	html := buf.String()

	for _, needle := range []string{
		"Entenda os ataques",
		"Em poucas palavras",                // rótulo do resumo da categoria
		"Como esse ataque costuma aparecer", // cabeçalho dos subtipos
		"O que isso quer dizer",             // tradução do payload
		"Como o DoBot Shield protege",       // rótulo da defesa
		"Injeção de SQL",                    // título amigável do SQLi
		"Cross-Site Scripting",              // título amigável do XSS
		"O que foi esse ataque",             // bloco por evento
	} {
		if !strings.Contains(html, needle) {
			t.Fatalf("expected report to contain %q", needle)
		}
	}
}

func TestNoEmDashInExplanations(t *testing.T) {
	// Requisito do TCC: as explicações não usam travessão (em-dash/en-dash).
	for cat, info := range categoryGlossary {
		texts := []string{info.Summary, info.Attack, info.Defense}
		for _, st := range info.Subtypes {
			texts = append(texts, st.Name, st.Explanation, st.Reading)
		}
		for _, text := range texts {
			if strings.ContainsRune(text, '—') || strings.ContainsRune(text, '–') {
				t.Fatalf("categoria %q contém travessão em: %q", cat, text)
			}
		}
	}
}

func TestCategoryClassStable(t *testing.T) {
	if categoryClass("XSS") != categoryClass("XSS") {
		t.Fatalf("category class should be deterministic")
	}
	if !strings.HasPrefix(categoryClass("SQLi"), "badge-") {
		t.Fatalf("unexpected class format")
	}
}
