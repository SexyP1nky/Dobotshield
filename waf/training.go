package waf

import (
	"bytes"
	"io"
	"mime"
	"mime/multipart"
	"net/http"
	"strings"
)

// Detection reune os detalhes didaticos de um bloqueio que ja foi decidido por
// CheckRequest. Serve de insumo para o "Modo de Treinamento": alem da categoria
// e da regra acionada, expoe o payload original recebido e todas as variantes
// que o WAF gerou ao decodifica-lo.
type Detection struct {
	Category string   // ex.: "XSS", "SQLi", "CMD_INJ"
	Location string   // ex.: "Query", "Body", "Header User-Agent"
	Rule     string   // regex/identificador acionado
	Payload  string   // valor bruto recebido no campo que casou
	Variants []string // variantes geradas pelas decodificacoes do WAF
}

// DescribeBlock monta os detalhes ricos de um bloqueio JA decidido por
// CheckRequest. Recebe os mesmos details e rule retornados por CheckRequest e
// NAO reavalia a decisao de seguranca: apenas localiza, no melhor esforco, o
// payload original do campo que casou e deriva suas variantes de inspecao.
//
// Por nao alterar nenhuma decisao, e seguro chama-la somente no caminho de
// registro (logging), sem qualquer impacto sobre o bloqueio em si.
func DescribeBlock(r *http.Request, bodyBytes []byte, details, rule string) Detection {
	category, location := splitDetails(details)

	payload := locatePayload(r, bodyBytes, location)

	var variants []string
	if payload != "" {
		variants = buildInspectionVariants(payload)
	}

	return Detection{
		Category: category,
		Location: location,
		Rule:     rule,
		Payload:  payload,
		Variants: variants,
	}
}

// BuildVariants expoe, para fins de relatorio/testes, a mesma cadeia de
// decodificacoes usada internamente pela inspecao do WAF.
func BuildVariants(input string) []string {
	return buildInspectionVariants(input)
}

// SplitDetails separa o texto "Categoria in Localizacao" devolvido por
// CheckRequest/CheckResponse nos seus dois componentes.
func SplitDetails(details string) (category, location string) {
	return splitDetails(details)
}

// splitDetails separa o texto de details ("XSS in Query", "SQLi in Header
// User-Agent", "MULTIPART_LIMIT") em categoria e localizacao. Quando nao ha o
// separador " in ", o details inteiro vira categoria (casos como
// MALFORMED_MULTIPART).
func splitDetails(details string) (category, location string) {
	const sep = " in "
	if idx := strings.Index(details, sep); idx >= 0 {
		return details[:idx], details[idx+len(sep):]
	}
	return details, ""
}

// locatePayload recupera o valor bruto do campo indicado pela localizacao.
// Para multiplos candidatos (headers repetidos, partes multipart) escolhe
// aquele que efetivamente dispara a inspecao.
func locatePayload(r *http.Request, bodyBytes []byte, location string) string {
	if r == nil {
		if location == "Body" {
			return string(bodyBytes)
		}
		return ""
	}

	switch {
	case location == "Path":
		return r.URL.EscapedPath()
	case location == "Host":
		return r.Host
	case location == "Query":
		return r.URL.RawQuery
	case location == "Body":
		return string(bodyBytes)
	case strings.HasPrefix(location, "Header "):
		name := strings.TrimSpace(strings.TrimPrefix(location, "Header "))
		return locateHeaderPayload(r, name)
	case strings.HasPrefix(location, "Multipart"):
		return locateMultipartPayload(r, bodyBytes)
	default:
		return ""
	}
}

// locateHeaderPayload devolve o valor do header que casou. Headers podem
// aparecer repetidos; escolhemos o primeiro que dispara qualquer grupo de
// inspecao (incluindo injecao de cabecalho). Sem match claro, juntamos todos.
func locateHeaderPayload(r *http.Request, name string) string {
	values := r.Header.Values(name)
	headerInjection := []patternGroup{{"HTTP_HEADER_INJECTION", headerInjectionPatterns}}

	for _, value := range values {
		if mal, _, _ := analyzePayload(value); mal {
			return value
		}
		if mal, _, _ := analyzePayloadWithGroups(value, headerInjection); mal {
			return value
		}
	}

	if len(values) > 0 {
		return strings.Join(values, " | ")
	}
	return ""
}

// locateMultipartPayload reanalisa o corpo multipart (a partir dos bytes ja
// lidos, sem tocar em r.Body) e retorna o primeiro valor — metadado ou
// conteudo de parte — que dispara a inspecao.
func locateMultipartPayload(r *http.Request, bodyBytes []byte) string {
	if len(bodyBytes) == 0 {
		return ""
	}

	mediaType, params, err := mime.ParseMediaType(r.Header.Get("Content-Type"))
	if err != nil || !strings.HasPrefix(strings.ToLower(mediaType), "multipart/") {
		return ""
	}
	boundary := params["boundary"]
	if boundary == "" {
		return ""
	}

	reader := multipart.NewReader(bytes.NewReader(bodyBytes), boundary)
	for i := 0; i < maxMultipartParts; i++ {
		part, err := reader.NextPart()
		if err != nil {
			return ""
		}

		for _, value := range []string{part.FormName(), part.FileName(), part.Header.Get("Content-Type")} {
			if mal, _, _ := analyzePayload(value); mal {
				_ = part.Close()
				return value
			}
		}

		content, err := io.ReadAll(io.LimitReader(part, maxMultipartPartBytes+1))
		_ = part.Close()
		if err != nil || len(content) == 0 {
			continue
		}
		if mal, _, _ := analyzePayload(string(content)); mal {
			return string(content)
		}
	}

	return ""
}
