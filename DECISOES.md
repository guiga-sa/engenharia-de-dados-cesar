# DECISOES.md — Exercício 06 · grupo: 08

Uma frase por decisão, com o número ou a evidência que vocês mediram. Não repita o enunciado:
diga o que escolheram, o que aceitaram perder e o que mostra isso.

## DECISÃO 01 — o alcance da Prefeitura na refined (`escopo_prefeitura`)
Escolhemos `tabela`: a Prefeitura recebe SELECT só na `madrugada_bairro`, não no database refined inteiro. Com essa escolha, se alguém criar amanhã uma tabela nova na refined, a Prefeitura não a enxerga até alguém conceder a permissão (aceitamos esse trabalho extra a cada tabela nova, e não testamos criando uma tabela); com `banco`, uma tabela criada por engano com `motorista_id` seria legível no mesmo dia. A madrugada dos últimos 7 dias, lida como a Prefeitura, deu 11.137 corridas, e a trusted e a raw foram recusadas ("Required Describe on ... _trusted" e "... _raw"), assim como o S3 direto.

## DECISÃO 02 — as colunas que a analista não vê (`colunas_ocultas_analista`)
Escondemos só `passageiro_id`, o mínimo que o jurídico pediu. A analista continua lendo 10 das 11 colunas: `count(bairro)` na trusted deu 518.400 linhas; `SELECT passageiro_id` como ela foi recusado (COLUMN_NOT_FOUND / não autorizada). Deixamos visível `corrida_id` porque ela precisa dele para citar a corrida reclamada e para checar duplicata com `count(*)` contra `count(DISTINCT corrida_id)` (esconder esse id a impediria de saber se uma corrida aparece duas vezes); `motorista_id` também ficou visível porque o requisito do jurídico foi só sobre o passageiro, e o risco que aceitamos é a analista ver quem dirigiu cada corrida.

## DECISÃO 03 — o contrato da refined (`contrato_refined`)
A descrição diz que a tabela traz corridas e receita da madrugada (0h às 5h59) por bairro do Recife e dia do evento, uma linha por bairro e dia, e que não contém id de corrida, motorista ou passageiro (161 caracteres, medidos pelo `verifica.sh`; o mínimo é 40). Um consumidor que só ler o catálogo sabe o grão (bairro e dia), o recorte (madrugada) e o que cada coluna (`bairro`, `corridas`, `receita`) significa, e sabe que a tabela não tem nenhum id. O dono é "Engenharia de Dados - grupo grupo08", e a tabela é recalculada a partir da trusted, de modo que os últimos 4 dias podem mudar até o atraso de 3 dias chegar.

## Evidência do verifica.sh
Critérios automáticos: 70 / 70. `prefeitura_refined=11137 prefeitura_trusted=RECUSADO prefeitura_raw=RECUSADO prefeitura_s3=RECUSADO analista_trusted=518400 analista_passageiro=RECUSADO`. Jobs: trusted com 518.400 linhas (17.280 duplicatas removidas do reenvio) e refined com 660 linhas (22 bairros × 30 dias).
