# DECISOES.md — Exercício 05 · grupo: grupo08

Uma frase por decisão, com o número que vocês mediram. Não repita o enunciado: diga o que
escolheram, o que aceitaram perder e o número que mostra isso.

## DECISÃO 01 — modo de escrita (`modo_escrita`)
Escolhemos **sobrescrever**. Rodando o job duas vezes, a tabela foi de **518.400** para **518.400** linhas
(e a madrugada de 7 dias de **11.137** para **11.137**; o `verifica.sh` rodou uma terceira vez e mediu o mesmo).
O preço aceito: cada execução diária reescreveu as **30** pastas `dt=` inteiras, mesmo as que não mudaram.
Em append, a 2ª execução teria acrescentado outra cópia de cada corrida (a madrugada iria a 22.274).

## DECISÃO 02 — a chave da linha (`chave_dedup`)
Escolhemos **corrida_id**. Com o reenvio de 5 dias atrás (2026-10-30, chegado de novo em 2026-10-31), o job leu
**535.680** linhas da raw, removeu **17.280** duplicatas e a tabela ficou com **518.400** linhas para **518.400**
corridas distintas. O preço aceito: a ordenação por `chegada` dentro de cada `corrida_id`, em toda execução.
Sem chave, as duas cópias entram na mesma execução e o sobrescrever as gravaria juntas: o número seria
estável, mas errado.

## DECISÃO 03 — janela de atraso (`janela_atraso_dias`)
Escolhemos **3** dias, o atraso que medimos na raw: as **1.591** corridas da madrugada de 2026-11-01 chegaram
só em 2026-11-04 (atraso exato de 3 dias). A madrugada dos últimos 7 dias deu **11.137** corridas, com
**0** linhas fora da janela; com janela 2, essas 1.591 ficariam de fora (11.137 − 1.591 = 9.546).
Não fomos além de 3 porque cada dia a mais de janela é mais uma pasta de evento reaberta em cada execução
diária (com 3, cada execução reaceita **4** dias de evento: D-3 a D); o que chegar com mais de 3 dias de atraso
aceitamos perder na carga diária e recuperar pelo backfill (DECISÃO 04).

## DECISÃO 04 — o backfill
Se uma corrida chegar com mais atraso do que a janela, o comando que conserta é
`./rodar-job.sh DIAS=2026-11-01` (o dia do evento); ele reescreve **1** pasta (`dt=2026-11-01`, **17.280** linhas,
lendo todas as chegadas daquele dia, com qualquer atraso) e a tabela fica com **518.400** linhas — as mesmas
518.400 de antes, com 518.400 corridas distintas e a madrugada em 11.137. Não duplica porque o modo é
sobrescrever (DECISÃO 01): a pasta do dia é trocada, não acrescentada; em append, o backfill somaria as
17.280 linhas do dia de novo.
