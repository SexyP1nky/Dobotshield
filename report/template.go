package report

import "html/template"

// reportTemplate é o relatório HTML autocontido (CSS e JS embutidos) do Modo de
// Treinamento. Todo dado vindo de payloads é interpolado por html/template e,
// portanto, escapado automaticamente: o relatório exibe os ataques como texto,
// sem nunca executá-los.
var reportTemplate = template.Must(template.New("report").Parse(reportHTML))

const reportHTML = `<!doctype html>
<html lang="pt-BR">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>DoBot Shield | Modo de Treinamento</title>
<style>{{.CSS}}</style>
</head>
<body>
<div class="wrap">
  <header class="top">
    <div>
      <p class="eyebrow">DoBot Shield</p>
      <h1>Modo de Treinamento: relatorio de ataques barrados</h1>
      <p class="subtitle">Cada cartao abaixo corresponde a uma requisicao (ou resposta) que o WAF
        interrompeu. Veja o que foi tentado, as variantes geradas apos as decodificacoes e a regra
        exata que disparou a defesa.</p>
    </div>
    <div class="meta">
      <div>Gerado em <strong>{{.GeneratedAt}}</strong></div>
      {{if .Source}}<div>Fonte: <strong>{{.Source}}</strong></div>{{end}}
      {{if .FirstSeen}}<div>Periodo: {{.FirstSeen}} &rarr; {{.LastSeen}}</div>{{end}}
    </div>
  </header>

  {{if eq .Total 0}}
    <div class="empty">
      <h2>Nenhum evento registrado ainda</h2>
      <p>Assim que o WAF barrar uma requisicao maliciosa com o Modo de Treinamento ativo,
        ela aparecera aqui. Rode os laboratorios de ataque e gere o relatorio novamente.</p>
    </div>
  {{else}}
    <section class="cards">
      <div class="card accent"><div class="label">Total de eventos</div><div class="value">{{.Total}}</div></div>
      <div class="card danger"><div class="label">Bloqueados</div><div class="value">{{.BlockedCount}}</div></div>
      <div class="card warning"><div class="label">Apenas detectados</div><div class="value">{{.DetectedCount}}</div></div>
      <div class="card"><div class="label">Em requisicoes</div><div class="value">{{.RequestCount}}</div></div>
      <div class="card"><div class="label">Em respostas</div><div class="value">{{.ResponseCount}}</div></div>
      <div class="card"><div class="label">IPs distintos</div><div class="value">{{.UniqueIPs}}</div></div>
      <div class="card"><div class="label">Regras acionadas</div><div class="value">{{.UniqueRules}}</div></div>
    </section>

    <section class="grid2">
      <div class="panel">
        <h2>Distribuicao por categoria</h2>
        {{range .Categories}}
        <div class="bar-row">
          <span class="name" title="{{.Label}}">{{.Label}}</span>
          <span class="bar-track"><span class="bar-fill" data-percent="{{printf "%.1f" .Percent}}"></span></span>
          <span class="num">{{.Count}}</span>
        </div>
        {{end}}
      </div>
      <div class="panel">
        <h2>Principais origens (IP)</h2>
        {{if .TopIPs}}
        {{range .TopIPs}}
        <div class="bar-row">
          <span class="name" title="{{.Label}}">{{.Label}}</span>
          <span class="bar-track"><span class="bar-fill" data-percent="{{printf "%.1f" .Percent}}"></span></span>
          <span class="num">{{.Count}}</span>
        </div>
        {{end}}
        {{else}}<p class="subtitle">Sem IPs registrados.</p>{{end}}
      </div>
    </section>

    {{if .Glossary}}
    <h2 class="section-title">Entenda os ataques deste relatorio</h2>
    <p class="section-lead">Clique em cada ataque para expandir e ver, em linguagem simples, as formas
      concretas em que ele costuma aparecer (com exemplos traduzidos) e como o DoBot Shield se defende.
      Nenhum conhecimento tecnico e necessario para acompanhar.</p>
    <div class="glossary-list">
      {{range .Glossary}}
      <details class="gloss-item">
        <summary class="gloss-summary">
          <span class="badge {{.CategoryClass}}">{{.Category}}</span>
          <span class="gloss-title">{{.Title}}</span>
          <span class="gloss-count">{{.Count}} evento(s)</span>
          {{if .Summary}}<span class="gloss-hint">{{.Summary}}</span>{{end}}
        </summary>
        <div class="gloss-body">
          <div class="gloss-block attack"><span class="tag">Em poucas palavras</span><p>{{.Attack}}</p></div>
          {{if .Subtypes}}
          <h4 class="gloss-sub-title">Como esse ataque costuma aparecer</h4>
          <div class="subtypes">
            {{range .Subtypes}}
            <div class="subtype">
              <div class="subtype-name">{{.Name}}</div>
              <p class="subtype-exp">{{.Explanation}}</p>
              {{if .Example}}
              <div class="subtype-example">
                <span class="subtype-ex-label">Exemplo</span>
                <code>{{.Example}}</code>
              </div>
              <p class="subtype-reading"><span class="reading-label">O que isso quer dizer:</span> {{.Reading}}</p>
              {{end}}
            </div>
            {{end}}
          </div>
          {{end}}
          <div class="gloss-block defense"><span class="tag">Como o DoBot Shield protege</span><p>{{.Defense}}</p></div>
        </div>
      </details>
      {{end}}
    </div>
    {{end}}

    <h2 class="section-title">Linha do tempo do ataque</h2>
    <div class="toolbar">
      <input type="search" id="search" placeholder="Filtrar por payload, regra, caminho ou IP...">
      <select id="filterCategory"><option value="">Todas as categorias</option>
        {{range .Categories}}<option value="{{.Label}}">{{.Label}}</option>{{end}}
      </select>
      <select id="filterPhase"><option value="">Requisicao e resposta</option>
        <option value="request">Somente requisicoes</option>
        <option value="response">Somente respostas</option>
      </select>
      <span class="count" id="visibleCount"></span>
    </div>

    <div id="timeline">
      {{range .Timeline}}
      <article class="event {{.ActionClass}}"
        data-category="{{.Category}}" data-phase="{{.Phase}}"
        data-search="{{.Payload}} {{.Rule}} {{.Path}} {{.IP}} {{.Category}} {{.Location}}">
        <div class="event-head">
          <span class="idx">#{{.Index}}</span>
          <span class="badge {{.CategoryClass}}">{{.Category}}</span>
          <span class="pill {{.Action}}">{{.Action}}</span>
          <span class="pill phase">{{.Phase}}</span>
          {{if .Path}}<span class="route">{{if .Method}}<span class="method">{{.Method}}</span> {{end}}{{.Path}}</span>{{end}}
          <span class="ip">{{.IP}}</span>
        </div>
        <div class="event-head" style="margin-top:6px">
          <span class="ts">{{.Timestamp}}</span>
        </div>
        <dl class="kv">
          {{if .Location}}<dt>Localizacao</dt><dd>{{.Location}}</dd>{{end}}
          {{if .Rule}}<dt>Regra</dt><dd class="rule"><code>{{.Rule}}</code></dd>{{end}}
          {{if .RequestID}}<dt>Request ID</dt><dd><code>{{.RequestID}}</code></dd>{{end}}
        </dl>
        {{if .Attack}}
        <details class="explain">
          <summary>O que foi esse ataque e como o DoBot Shield agiu?</summary>
          {{if .FriendlyTitle}}<p style="margin:8px 0 0;font-weight:600">{{.FriendlyTitle}}</p>{{end}}
          <div class="ex attack"><span class="tag">O ataque</span><p>{{.Attack}}</p></div>
          <div class="ex defense"><span class="tag">A defesa</span><p>{{.Defense}}</p></div>
        </details>
        {{end}}
        {{if .Payload}}
        <div style="margin-top:12px">
          <dt style="color:var(--muted);font-weight:600;font-size:.86rem">Payload original</dt>
          <pre class="payload">{{.Payload}}</pre>
        </div>
        {{end}}
        {{if .Variants}}
        <details class="variants">
          <summary>Variantes geradas pela inspecao ({{len .Variants}})</summary>
          <ol>
            {{range .Variants}}<li><code>{{.}}</code></li>{{end}}
          </ol>
        </details>
        {{end}}
      </article>
      {{end}}
      <div class="no-results" id="noResults">Nenhum evento corresponde aos filtros.</div>
    </div>
  {{end}}

  <footer>
    Relatorio gerado pelo DoBot Shield &middot; Modo de Treinamento. Os payloads sao exibidos como
    texto e nunca executados. Util para equipes que querem aprender sobre ataques web enquanto
    protegem sistemas legados.
  </footer>
</div>

<script>
(function(){
  "use strict";
  // Aplica a largura das barras a partir do data-attribute (evita CSS dinamico inseguro).
  var fills = document.querySelectorAll(".bar-fill");
  for (var i = 0; i < fills.length; i++) {
    fills[i].style.width = (fills[i].getAttribute("data-percent") || "0") + "%";
  }

  var search = document.getElementById("search");
  var filterCategory = document.getElementById("filterCategory");
  var filterPhase = document.getElementById("filterPhase");
  var counter = document.getElementById("visibleCount");
  var noResults = document.getElementById("noResults");
  if (!search) { return; }

  var events = Array.prototype.slice.call(document.querySelectorAll(".event"));

  function apply(){
    var term = search.value.trim().toLowerCase();
    var cat = filterCategory.value;
    var phase = filterPhase.value;
    var visible = 0;

    events.forEach(function(el){
      var haystack = (el.getAttribute("data-search") || "").toLowerCase();
      var matchTerm = term === "" || haystack.indexOf(term) !== -1;
      var matchCat = cat === "" || el.getAttribute("data-category") === cat;
      var matchPhase = phase === "" || el.getAttribute("data-phase") === phase;
      var show = matchTerm && matchCat && matchPhase;
      el.style.display = show ? "" : "none";
      if (show) { visible++; }
    });

    if (counter) { counter.textContent = visible + " de " + events.length + " evento(s)"; }
    if (noResults) { noResults.style.display = visible === 0 ? "block" : "none"; }
  }

  search.addEventListener("input", apply);
  filterCategory.addEventListener("change", apply);
  filterPhase.addEventListener("change", apply);
  apply();
})();
</script>
</body>
</html>
`
