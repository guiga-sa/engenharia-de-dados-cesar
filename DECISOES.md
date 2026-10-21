# DECISOES.md — Exercício 04 (Aula 21)

Uma frase por decisão, **cada uma com um número que você mediu**. Não repita o
enunciado: diga o que escolheu, o que aceitou perder e o que mediu.
Justificativa sem número não pontua (critério 7, 20%).

**DECISÃO 01 — chave de partição.** Escolhi só `dt` porque a pergunta da madrugada filtra `dt >= hoje−6` (chave do caminho) e agrupa os 22 bairros: com esta chave, a semana abre **7 arquivos** (7 dias × 1 arquivo). Particionar também por `bairro` abriria 7 × 22 = **154 arquivos** para a mesma consulta, sem pular um byte — a pergunta precisa de todos os bairros.

**DECISÃO 02 — arquivos por pasta.** Escolhi **1** arquivo por pasta; cada arquivo ficou com **604.769 bytes** em média (min 603.763, max 605.934; 30 arquivos = 18.143.089 bytes), e a pergunta lê **7 rodapés**. Com 4 arquivos por pasta seriam 28 GET no S3 e 28 rodapés, sem ganho neste volume.

**DECISÃO 03 — a meta de custo.** Declarei **800.000 bytes** (abaixo de 1 MiB = 1.048.576). Ela saiu da medição do Lab 05 (0,4 MB na mesma pergunta) com folga; nesta conta o Athena leu **355.803 bytes** — 11.137 corridas, abaixo da meta.

**DECISÃO 04 — o teto do workgroup.** Declarei **10.485.760 bytes** (10 MiB, mínimo do Athena): deixa passar a pergunta da madrugada (355.803 bytes) e barra o `SELECT` de todas as colunas da trusted inteira (**18.143.089 bytes**). O preço é que uma exploração de 30 dias com todas as colunas não roda neste workgroup.

**DECISÃO 05 — o registro das partições.** Escolhi **partition projection** (`NOW-90DAYS,NOW`), não MSCK. Aceito que pastas fora dessa janela de **90 dias** fiquem invisíveis sem erro; no dia 31, `NOW` inclui a pasta nova sozinho, sem `MSCK REPAIR TABLE`.
