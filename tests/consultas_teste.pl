% tests/consultas_teste.pl
% Baterias de teste do Curriculum Advisor
%
% Uso:
%   swipl tests/consultas_teste.pl
%   ?- rodar_todos_testes.

:- consult('../src/curriculum.pl').
:- consult('../src/elegibilidade.pl').
:- consult('../src/trilhas.pl').

:- dynamic testes_pass/1, testes_fail/1.
testes_pass(0).
testes_fail(0).

registrar_pass(Desc) :-
    format("  PASS: ~w~n", [Desc]),
    retract(testes_pass(N)), N1 is N + 1, assert(testes_pass(N1)).

registrar_fail(Desc) :-
    format("  FAIL: ~w~n", [Desc]),
    retract(testes_fail(N)), N1 is N + 1, assert(testes_fail(N1)).

checar(Goal, Desc) :-
    (   call(Goal)
    ->  registrar_pass(Desc)
    ;   registrar_fail(Desc)
    ).

checar_falha(Goal, Desc) :-
    (   \+ call(Goal)
    ->  registrar_pass(Desc)
    ;   registrar_fail(Desc)
    ).

% T1: disciplinas do semestre 3
teste_c1_sem3 :-
    format("~n[T1] Disciplinas do semestre 3~n"),
    findall(D, disciplina(D, _, _, 3), Ds),
    format("  Semestre 3: ~w~n", [Ds]),
    checar(length(Ds, 4), "semestre 3 tem 4 disciplinas"),
    checar(member(algoritmos, Ds), "algoritmos esta no sem 3"),
    checar(member(probabilidade, Ds), "probabilidade esta no sem 3"),
    checar(member(calculo_numerico, Ds), "calculo_numerico esta no sem 3"),
    checar(member(sistemas_operacionais, Ds), "sistemas_operacionais esta no sem 3").

% T2: total de disciplinas
teste_c1_total :-
    format("~n[T2] Total de disciplinas~n"),
    findall(D, disciplina(D, _, _, _), Ds),
    length(Ds, N),
    format("  Total: ~w disciplinas~n", [N]),
    checar((N >= 20), "pelo menos 20 disciplinas cadastradas").

% T3: eletivas
teste_c1_eletivas :-
    format("~n[T3] Eletivas~n"),
    findall(D, disciplina(D, eletiva, _, _), Ds),
    length(Ds, N),
    format("  Eletivas: ~w~n", [Ds]),
    checar((N >= 3), "pelo menos 3 eletivas cadastradas").

% T4: cadeia de prerequisito com profundidade >= 3
teste_c1_cadeia_profunda :-
    format("~n[T4] Cadeia de prerequisito com profundidade >= 3~n"),
    checar(prerequisito(programacao_oo, intro_programacao), "programacao_oo -> intro_programacao"),
    checar(prerequisito(algoritmos, programacao_oo), "algoritmos -> programacao_oo"),
    checar(prerequisito(banco_dados, algoritmos), "banco_dados -> algoritmos"),
    checar(prerequisito(tcc, banco_dados), "tcc -> banco_dados"),
    format("  Cadeia: intro_programacao->programacao_oo->algoritmos->banco_dados->tcc~n").

% T5: disciplinas_liberadas para Joao e Maria
teste_c2_liberadas_distintas :-
    format("~n[T5] disciplinas_liberadas para alunos diferentes~n"),
    disciplinas_liberadas(joao, LibJ),
    disciplinas_liberadas(maria, LibM),
    format("  Joao  pode cursar: ~w~n", [LibJ]),
    format("  Maria pode cursar: ~w~n", [LibM]),
    checar((LibJ \= LibM), "joao e maria tem listas liberadas diferentes"),
    checar(member(tcc, LibJ), "joao pode cursar tcc"),
    checar(member(banco_dados, LibM), "maria pode cursar banco_dados"),
    checar_falha(member(banco_dados, LibJ), "joao nao pode cursar banco_dados (ja cursou)").

% T6: disciplinas_liberadas para Maria e Pedro
teste_c2_liberadas_pedro_maria :-
    format("~n[T6] disciplinas_liberadas Pedro vs Maria~n"),
    disciplinas_liberadas(pedro, LibP),
    disciplinas_liberadas(maria, LibM),
    format("  Pedro pode cursar: ~w~n", [LibP]),
    format("  Maria pode cursar: ~w~n", [LibM]),
    checar((LibP \= LibM), "pedro e maria tem listas liberadas diferentes"),
    checar(member(algoritmos, LibP), "pedro pode cursar algoritmos"),
    checar_falha(member(calculo_numerico, LibP), "pedro nao pode cursar calculo_numerico").

% T7: disciplinas_pendentes para Joao e Pedro
teste_c2_pendentes_distintas :-
    format("~n[T7] disciplinas_pendentes para alunos diferentes~n"),
    disciplinas_pendentes(joao, PJ),
    disciplinas_pendentes(pedro, PP),
    format("  Joao  pendentes: ~w~n", [PJ]),
    format("  Pedro pendentes: ~w~n", [PP]),
    checar((PJ \= PP), "joao e pedro tem listas pendentes diferentes"),
    checar((PJ = [tcc]), "joao tem apenas tcc pendente"),
    checar(member(calculo2, PP), "pedro tem calculo2 pendente"),
    checar(member(teoria_grafos, PP), "pedro tem teoria_grafos pendente").

% T8: \+ cursou e decisivo para pode_cursar
teste_c2_negacao_decisiva :-
    format("~n[T8] \\+ cursou e decisivo para pode_cursar~n"),
    checar(prerequisitos_ok(joao, banco_dados), "joao cumpre os prerequisitos de banco_dados"),
    checar(prerequisitos_ok(maria, banco_dados), "maria cumpre os prerequisitos de banco_dados"),
    checar_falha(pode_cursar(joao, banco_dados), "joao NAO pode cursar banco_dados (ja cursou -> \\+ decide)"),
    checar(pode_cursar(maria, banco_dados), "maria PODE cursar banco_dados (\\+ cursou e verdadeiro)"),
    % casos abaixo: falha por PREREQUISITO, para contraste com o caso acima
    checar(pode_cursar(joao, tcc), "joao pode cursar tcc"),
    checar_falha(pode_cursar(maria, tcc), "maria nao pode cursar tcc (falta prerequisito)"),
    checar_falha(pode_cursar(maria, banco_dados_avancado), "maria nao pode cursar banco_dados_avancado (falta prerequisito)").

% T9: creditos_cursados para os 3 alunos
teste_c2_creditos :-
    format("~n[T9] creditos_cursados~n"),
    creditos_cursados(joao, CJ),
    creditos_cursados(maria, CM),
    creditos_cursados(pedro, CP),
    format("  Joao : ~w creditos~n", [CJ]),
    format("  Maria: ~w creditos~n", [CM]),
    format("  Pedro: ~w creditos~n", [CP]),
    checar((CJ =:= 72), "joao tem 72 creditos"),
    checar((CM =:= 48), "maria tem 48 creditos"),
    checar((CP =:= 12), "pedro tem 12 creditos").

% T10: aluno inexistente falha de forma limpa
teste_c2_aluno_inexistente :-
    format("~n[T10] Aluno inexistente~n"),
    checar_falha(aluno_existe(estudante_fantasma), "aluno_existe falha para aluno inexistente"),
    checar_falha(pode_cursar(estudante_fantasma, calculo1), "pode_cursar falha para aluno inexistente"),
    disciplinas_liberadas(estudante_fantasma, L),
    checar((L = []), "disciplinas_liberadas retorna [] para aluno inexistente"),
    disciplinas_pendentes(estudante_fantasma, Pend),
    checar((Pend = []), "disciplinas_pendentes retorna [] para aluno inexistente"),
    creditos_cursados(estudante_fantasma, C),
    checar((C =:= 0), "creditos_cursados retorna 0 para aluno inexistente"),
    checar_falha(trilha_valida(estudante_fantasma, 16, _), "trilha_valida falha para aluno inexistente").

% T11: disciplina inexistente falha de forma limpa
teste_c2_disciplina_inexistente :-
    format("~n[T11] Disciplina inexistente~n"),
    checar_falha(prerequisitos_ok(joao, disciplina_fantasma), "prerequisitos_ok falha para disciplina inexistente"),
    checar_falha(pode_cursar(joao, disciplina_fantasma), "pode_cursar falha para disciplina inexistente").

% T12: prerequisito_transitivo com cadeia de profundidade >= 3
teste_c3_transitivo :-
    format("~n[T12] prerequisito_transitivo — cadeia de prof >= 3~n"),
    findall(A, prerequisito_transitivo(tcc, A), Ancs),
    sort(Ancs, AncsOrd),
    format("  Ancestrais de tcc: ~w~n", [AncsOrd]),
    checar(member(compiladores, AncsOrd), "compiladores e ancestral de tcc"),
    checar(member(teoria_grafos, AncsOrd), "teoria_grafos e ancestral de tcc"),
    checar(member(algoritmos, AncsOrd), "algoritmos e ancestral de tcc"),
    checar(member(programacao_oo, AncsOrd), "programacao_oo e ancestral de tcc"),
    checar(member(intro_programacao, AncsOrd), "intro_programacao e ancestral de tcc"),
    findall(A, prerequisito_transitivo(inteligencia_artificial, A), AncsIA),
    sort(AncsIA, AncsIAOrd),
    checar(member(calculo1, AncsIAOrd), "calculo1 e ancestral de inteligencia_artificial").

% T13: trilha_valida para Maria
teste_c3_trilha_maria :-
    format("~n[T13] trilha_valida para Maria (max 16 cred)~n"),
    (   once(trilha_valida(maria, 16, Trilha))
    ->  registrar_pass("trilha_valida encontrou trilha para Maria"),
        format("  Trilha gerada:~n"),
        imprimir_trilha_teste(Trilha, 1),
        findall(D, (member(Sem, Trilha), member(D, Sem)), TodasNaTrilha),
        checar(member(tcc, TodasNaTrilha), "tcc esta na trilha de Maria"),
        checar(member(banco_dados, TodasNaTrilha), "banco_dados esta na trilha de Maria"),
        checar(todos_sems_dentro_do_limite(Trilha, 16), "nenhum semestre ultrapassa 16 creditos")
    ;   registrar_fail("trilha_valida nao encontrou trilha para Maria")
    ).

% T14: trilha_valida para Pedro
teste_c3_trilha_pedro :-
    format("~n[T14] trilha_valida para Pedro (max 16 cred)~n"),
    (   once(trilha_valida(pedro, 16, Trilha))
    ->  registrar_pass("trilha_valida encontrou trilha para Pedro"),
        format("  Trilha de Pedro:~n"),
        imprimir_trilha_teste(Trilha, 1),
        findall(D, (member(Sem, Trilha), member(D, Sem)), TodasNaTrilha),
        checar(member(tcc, TodasNaTrilha), "tcc esta na trilha de Pedro")
    ;   registrar_fail("trilha_valida nao encontrou trilha para Pedro")
    ).

% T15: multiplas trilhas validas para Maria
teste_c3_multiplas_trilhas :-
    format("~n[T15] Multiplas trilhas validas para Maria (max 12 cred)~n"),
    (   trilha_valida(maria, 12, T1),
        trilha_valida(maria, 12, T2),
        T2 \= T1
    ->  registrar_pass("existe mais de uma trilha valida para Maria"),
        format("  Trilha 1: ~w~n", [T1]),
        format("  Trilha 2: ~w~n", [T2])
    ;   registrar_fail("nao encontrou segunda trilha para Maria")
    ).

% T16: limite de creditos impossivel
teste_c3_limite_semestres :-
    format("~n[T16] Limite de creditos impossivel~n"),
    checar_falha(trilha_valida(maria, 2, _), "trilha_valida falha com MaxCred=2").

% T17: Pedro tem lacunas em semestres anteriores
teste_c3_pendentes_pedro :-
    format("~n[T17] Pendentes de Pedro~n"),
    disciplinas_pendentes(pedro, Pend),
    format("  Pendentes: ~w~n", [Pend]),
    checar(member(logica_matematica, Pend), "logica_matematica pendente"),
    checar(member(algebra_linear, Pend), "algebra_linear pendente"),
    checar(member(calculo2, Pend), "calculo2 pendente"),
    checar(member(estruturas_discretas, Pend), "estruturas_discretas pendente"),
    checar(member(arquitetura_computadores, Pend), "arquitetura_computadores pendente"),
    checar(member(tcc, Pend), "tcc pendente").

% T18: disciplinas_liberadas nao tem duplicatas
teste_c2_sem_duplicatas :-
    format("~n[T18] disciplinas_liberadas sem duplicatas~n"),
    disciplinas_liberadas(maria, L),
    sort(L, LSorted),
    checar((L = LSorted), "disciplinas_liberadas retorna lista sem duplicatas e ordenada").

% T19: enumeracao de multiplas trilhas via findall
teste_c3_findall_trilhas :-
    format("~n[T19] Enumeracao de trilhas via findall (maria, max 16)~n"),
    findall(T, trilha_valida(maria, 16, T), Todas),
    length(Todas, N),
    format("  Trilhas encontradas: ~w~n", [N]),
    checar((N > 1), "findall enumera mais de uma trilha valida para maria"),
    sort(Todas, TodasUnicas),
    length(TodasUnicas, NUnicas),
    checar((NUnicas =:= N), "todas as trilhas encontradas sao distintas entre si").

% T20: MaxCred menor que os creditos do tcc (8) 
teste_c3_maxcred_menor_que_tcc :-
    format("~n[T20] MaxCred=7 (menor que os 8 creditos do tcc)~n"),
    checar_falha(trilha_valida(maria, 7, _), "trilha_valida falha quando MaxCred < creditos do tcc").

% auxiliares

todos_sems_dentro_do_limite([], _).
todos_sems_dentro_do_limite([Sem|Resto], Max) :-
    soma_creditos(Sem, C),
    C =< Max,
    todos_sems_dentro_do_limite(Resto, Max).

imprimir_trilha_teste([], _).
imprimir_trilha_teste([Sem|Resto], N) :-
    soma_creditos(Sem, Cred),
    format("    Semestre ~w (~w cred): ~w~n", [N, Cred, Sem]),
    N1 is N + 1,
    imprimir_trilha_teste(Resto, N1).

rodar_todos_testes :-
    retractall(testes_pass(_)), assert(testes_pass(0)),
    retractall(testes_fail(_)), assert(testes_fail(0)),

    format("~nCurriculum Advisor — testes~n"),

    teste_c1_sem3,
    teste_c1_total,
    teste_c1_eletivas,
    teste_c1_cadeia_profunda,

    teste_c2_liberadas_distintas,
    teste_c2_liberadas_pedro_maria,
    teste_c2_pendentes_distintas,
    teste_c2_negacao_decisiva,
    teste_c2_creditos,
    teste_c2_aluno_inexistente,
    teste_c2_disciplina_inexistente,
    teste_c2_sem_duplicatas,

    teste_c3_transitivo,
    teste_c3_trilha_maria,
    teste_c3_trilha_pedro,
    teste_c3_multiplas_trilhas,
    teste_c3_findall_trilhas,
    teste_c3_limite_semestres,
    teste_c3_maxcred_menor_que_tcc,
    teste_c3_pendentes_pedro,

    testes_pass(P),
    testes_fail(F),
    Total is P + F,
    format("~nResultado: ~w/~w passou  (~w falhou)~n~n", [P, Total, F]).
