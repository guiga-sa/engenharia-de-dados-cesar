DECISÃO 01: Escolhi o tipo string para a coluna de valor e salvar os 1,5% de dados com vírgula. Com isso, aceito perder a agregação matemática nativa, exigindo que toda consulta futura faça o tratamento (como regex ou CAST) para não quebrar.

DECISÃO 02: Escolhi o tipo string para as colunas de tempo. Se declaradas como timestamp, o Athena não consegue processar nativamente o formato ISO enviado pelo produtor e a consulta SELECT devolve nulo (null) em todas as linhas.  

DECISÃO 03: Escolhi false para o ignore.malformed.json, optando pelo barulho. Aceito pagar o preço como engenheiro de ter consultas interrompidas (HIVE_BAD_DATA) e precisar atuar na correção, para garantir que os analistas nunca consumam dados silenciosamente corrompidos.

DECISÃO 04: Declarei 3 partições manualmente. As outras 27 partições que não declarei continuam existindo no S3, mas estão invisíveis para o Athena, pois dado não catalogado é dado que não existe para a consulta. No dia 31, os novos dados chegarão ao S3, mas não poderão ser consultados até que alguém registre a nova partição manualmente (já que não temos mais o Crawler).  

DECISÃO 05: Escolhi o teto de 11.000.000 bytes. Como declarei apenas 3 partições, a minha consulta larga totaliza ~11,7 MB. O valor escolhido bloqueia esse full scan, permite folgadamente a consulta estreita (~3,9 MB) e respeita o piso da AWS (10.485.760).

Comportamento observado em produção: o bloqueio funcionou corretamente — o Athena interrompeu a consulta larga com a mensagem "Bytes scanned limit was exceeded" e varreu apenas 10,49 MB antes de parar. No entanto, o status devolvido pela API da AWS nesse caso é CANCELLED, e não FAILED como o verifica.sh espera na condição do Critério 4. Por causa dessa divergência entre o status real da API e o status esperado pelo script, o Critério 4 exibe [FALHA] mesmo com a infraestrutura funcionando conforme projetado. A evidência do bloqueio correto está nas capturas de tela do console do Athena anexadas ao PR.