# Curriculum Advisor

Sistema em SWI-Prolog que modela a grade curricular de um curso de Bacharelado em Ciencia da Computacao e responde perguntas sobre elegibilidade e trilhas de formatura.

## Estrutura do Projeto

```
curriculum-advisor/
├── src/
│   ├── curriculum.pl       (Camada 1: fatos — disciplinas, prereqs, historico)
│   ├── elegibilidade.pl    (Camada 2: regras — o que o aluno pode fazer agora)
│   ├── trilhas.pl          (Camada 3: fecho transitivo + geracao de trilhas)
│   └── main.pl             (demo/0 e ponto de entrada)
├── tests/
│   ├── consultas_teste.pl  (baterias de teste com PASS/FAIL)
│   └── teste_ciclo.pl      (teste isolado de deteccao de ciclos)
├── docs/
│   └── decisoes.md         (decisoes de modelagem e limitacoes)
└── README.md
```

## Rodar no Browser (SWISH)

Sem instalar nada: acesse `swish.swi-prolog.org`.

1. Cole o conteudo de `src/curriculum.pl` + `src/elegibilidade.pl` + `src/trilhas.pl` no editor (campo de cima), removendo as linhas `:- use_module` e `:- consult`
2. No campo de baixo (`?-`), digite a query desejada
3. Clique **Run!**

Queries para testar:

```prolog
disciplinas_liberadas(maria, L).
disciplinas_pendentes(pedro, L).
creditos_cursados(joao, C).
trilha_valida(maria, 16, T).
validar_base.
```

---

## Pre-requisitos

- [SWI-Prolog](https://www.swi-prolog.org/Download.html) versao 8.x ou superior
- Verificar instalacao: `swipl --version`

## Como Carregar o Projeto

A partir da raiz do repositorio (`curriculum-advisor/`):

```bash
swipl src/main.pl
```

O SWI-Prolog exibira o prompt interativo `?-` apos carregar as tres camadas.

## Como Rodar a Demo

Com o projeto carregado:

```prolog
?- demo.
```

A demo exercita as tres camadas em sequencia para os tres alunos de teste (joao, maria, pedro), imprimindo:
- Contagem e listagem de disciplinas por semestre (Camada 1)
- Creditos cursados, disciplinas liberadas e pendentes por aluno (Camada 2)
- Fecho transitivo de prereqs, validacao da base e trilhas de formatura (Camada 3)

## Como Rodar os Testes

### Baterias completas (18 cenarios)

```bash
swipl -g "consult('tests/consultas_teste.pl'), rodar_todos_testes, halt" -t halt
```

Ou interativamente apos carregar o projeto:

```prolog
?- consult('tests/consultas_teste.pl'), rodar_todos_testes.
```

### Teste de deteccao de ciclos (base malformada proposital)

```bash
swipl -g "consult('tests/teste_ciclo.pl'), rodar_testes_ciclo, halt" -t halt
```

## Consultas Avulsas Uteis

```prolog
% Disciplinas que um aluno pode cursar agora
?- disciplinas_liberadas(maria, L).

% Obrigatorias ainda pendentes
?- disciplinas_pendentes(pedro, L).

% Creditos acumulados
?- creditos_cursados(joao, C).

% Todos os pre-requisitos transitivos de uma disciplina
?- findall(A, prerequisito_transitivo(tcc, A), L), sort(L, S).

% Gerar uma trilha de formatura (max 16 creditos/semestre)
?- once(trilha_valida(maria, 16, T)).

% Verificar se existe ciclo em alguma disciplina
?- existe_ciclo(tcc).

% Validar toda a base contra ciclos
?- validar_base.
```

## Arquitetura em 3 Camadas

| Camada | Arquivo | Responsabilidade |
|--------|---------|-----------------|
| 1 | `curriculum.pl` | Fatos puros: disciplinas, prereqs, historico dos alunos |
| 2 | `elegibilidade.pl` | Regras derivadas: o que cada aluno pode fazer *agora* |
| 3 | `trilhas.pl` | Fecho transitivo, deteccao de ciclos, trilhas de formatura via backtracking |

## Alunos de Teste

| Aluno | Perfil | Sems concluidos |
|-------|--------|-----------------|
| `joao` | Adiantado | 1-4 completos + obrigatorias do sem 5 |
| `maria` | Ritmo normal | 1-3 completos |
| `pedro` | Atrasado / trancamento | Parte do sem 1 e uma disciplina do sem 2 |
