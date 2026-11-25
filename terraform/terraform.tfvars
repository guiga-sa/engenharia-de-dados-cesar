turma  = "TURMA-8"
sufixo = "grupo08"

escopo_prefeitura        = "tabela"
colunas_ocultas_analista = ["passageiro_id"]

contrato_refined = {
  descricao   = "Corridas e receita da madrugada (0h às 5h59) por bairro do Recife e dia do evento, uma linha por bairro e dia. Não contém id de corrida, motorista ou passageiro."
  dono        = "Engenharia de Dados - grupo grupo08"
  atualizacao = "recalculada a partir da trusted; os últimos 4 dias podem mudar até o atraso de 3 dias chegar"
  comentarios = {
    bairro   = "bairro da corrida"
    corridas = "número de corridas da madrugada naquele bairro e dia"
    receita  = "soma do valor das corridas da madrugada, arredondada em 2 casas"
  }
}
