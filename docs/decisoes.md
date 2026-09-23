# Decisoes de Modelagem — Curriculum Advisor

## 1. findall vs setof em cada predicado da Camada 2

### `disciplinas_liberadas/2`
**Escolha: `findall` + `sort`**

`setof/3` foi considerado mas descartado pelos seguintes motivos:
- `setof` falha silenciosamente quando o resultado e vazio (ex.: aluno recém-matriculado sem historico ou aluno já formado). Isso exigiria um tratamento extra com `(setof(...) -> ... ; Lista = [])`, tornando o codigo menos limpo.
- `findall` sempre retorna uma lista, mesmo vazia — comportamento uniforme e previsível independente do estado do aluno.
- O `sort/2` aplicado após o `findall` elimina duplicatas e ordena alfabeticamente, entregando o mesmo resultado determinístico que `setof` produziria quando bem-sucedido.

**Conclusão:** `findall + sort` e a combinação mais robusta e legível para este caso.

### `disciplinas_pendentes/2`
**Escolha: `findall` + `sort`**

Mesma justificativa: aluno recém-matriculado com zero cursos cursados deveria retornar a lista completa de obrigatorias, não falhar. `findall` garante isso.

### `creditos_cursados/2`
**Escolha: `findall` + soma manual**

`aggregate_all` foi considerado mas requer `library(aggregate)`. Para manter o código em SWI-Prolog puro (sem dependências além de `library(lists)`), usamos `findall` para coletar os créditos e um predicado auxiliar `somar_lista/2` para reduzi-los. O resultado é semanticamente idêntico a `aggregate_all(sum(C), ..., Total)`.

---

## 2. Modelagem do Fecho Transitivo

### Predicado `prerequisito_transitivo/2`

**Caso base:** `prerequisito(Disciplina, Ancestral)` — Ancestral é pré-requisito *direto* de Disciplina.

**Caso recursivo:** existe um nó intermediário `Meio` tal que `prerequisito(Disciplina, Meio)` e `prerequisito_transitivo(Meio, Ancestral)` — Ancestral é ancestral de Meio, que é predecesssor direto de Disciplina.

**Por que esta ordem?**
A recursão vai "para baixo na cadeia" a partir de Disciplina, o que é natural para responder "quais disciplinas preciso ter cursado para chegar aqui". Funciona corretamente com a estratégia de busca DFS de Prolog desde que a base seja acíclica.

**Limitação assumida:** a base de fatos de `curriculum.pl` é garantidamente acíclica por design (nenhuma disciplina pode exigir como pré-requisito algo que só existe em semestres posteriores). Para bases malformadas, use `existe_ciclo/1` antes de invocar este predicado em modo geral.

### Predicado `existe_ciclo/1`

Implementado com DFS + conjunto de visitados (`existe_ciclo_dfs/3`) em vez de simplesmente chamar `prerequisito_transitivo(D, D)`. Motivo: invocar `prerequisito_transitivo` em uma base com ciclos pode divergir (loop infinito) antes de encontrar a resposta. O DFS com visitados garante terminação em O(V + E) onde V = nós e E = arestas.

---

## 3. Abordagem em `trilha_valida`: Acumulador vs assert/retract

**Escolha: acumulador explícito (sem assert/retract)**

A Camada 3 usa um argumento `Feitas` que acumula as disciplinas já alocadas (histórico real + semestres simulados anteriores). Este argumento é passado explicitamente na recursão de `gerar_trilha/5`.

**Por que não usar assert/retract?**

Prolog desfaz automaticamente as *variáveis* ao retroceder no backtracking, mas **não desfaz fatos alterados com assert/retract**. Se `gerar_trilha` adicionasse disciplinas com `assert` e depois o backtracking precisasse explorar outro ramo, as disciplinas "adicionadas" continuariam no banco de fatos, corrompendo as buscas subsequentes. Seria necessário garantir um `retract` correspondente em cada ponto de corte — código frágil e difícil de manter.

Com o acumulador, cada ramo da busca possui sua própria cópia de `Feitas` como argumento, completamente isolada dos outros ramos. O backtracking natural do Prolog descarta a variável ao retroceder, sem efeitos colaterais. Esta abordagem é mais idiomática em Prolog e mais fácil de raciocinar.

---

## 4. Limitações Conhecidas

1. **Equivalência de currículos:** O sistema não lida com disciplinas equivalentes entre currículos de versões diferentes (ex.: "Programação I" de um currículo antigo equivalendo a "Introdução à Programação" do currículo novo). Todas as equivalências precisariam ser codificadas como fatos adicionais de um predicado `equivalente/2`.

2. **Restrições de co-requisito:** O modelo não suporta o conceito de co-requisito (disciplinas que devem ser cursadas *simultaneamente*). Todos os requisitos modelados são pré-requisitos estritos.

3. **Máximo de semestres fixo:** O limite de 12 semestres em `gerar_trilha` é hardcoded. Para cursos com muitas disciplinas ou alunos com histórico muito irregular, o número real de semestres necessários poderia exceder 12. O predicado falharia de forma limpa mas sem mensagem explicativa ao usuário.

4. **Disciplinas obrigatórias apenas na trilha:** `trilha_valida` planeja apenas as disciplinas **obrigatórias** pendentes. Eletivas não são incluídas na trilha de formatura. Um sistema completo deveria permitir que o aluno inclua eletivas na simulação.

5. **Limite de créditos mínimo:** Se `MaxCreditosPorSemestre` for menor que o menor número de créditos de qualquer disciplina pendente (ex.: MaxCred=2 com todas as disciplinas tendo 4+ créditos), o predicado falha de forma limpa mas sem mensagem explicativa.

6. **Sem validação de carga máxima curricular:** O modelo não verifica regras institucionais como número mínimo de créditos por semestre para manutenção de matrícula.

---

## 5. Decisoes de Modelagem Nao Previstas no Enunciado

### Disciplina sem pré-requisito
`prerequisitos_ok(Aluno, Disciplina)` retorna `true` vacuamente via `forall` quando `Disciplina` não tem nenhum fato `prerequisito/2` — comportamento correto: qualquer aluno pode cursar uma disciplina sem requisitos. Não foi necessário nenhum caso especial.

### Aluno com histórico vazio (recém-matriculado)
O predicado `aluno_existe/1` requer ao menos um fato `cursou/2`. Um aluno recém-matriculado (sem nenhum curso feito) não existiria na base e `pode_cursar` retornaria `false` para qualquer disciplina. Para suportar este caso, seria necessário um predicado separado `aluno/1` independente do histórico. Como o enunciado define os alunos pelo seu histórico, esta limitação foi aceita e documentada.

### Aluno já formado
Se todos as obrigatórias já foram cursadas, `disciplinas_pendentes` retorna `[]` e `trilha_valida` retorna `Trilha = []` (trilha vazia = já formado). O predicado `demo_trilha` imprime uma mensagem adequada neste caso via o branch `false` do `->`.

### Átomos sem acento
Todos os nomes de disciplinas e alunos usam átomos sem acento (ex.: `logica_matematica` em vez de `lógica_matemática`). Isso evita problemas de encoding UTF-8 vs Latin-1 ao carregar arquivos `.pl` em diferentes sistemas operacionais, conforme recomendado no enunciado.
