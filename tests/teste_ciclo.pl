% tests/teste_ciclo.pl
% Teste isolado de deteccao de ciclos
% Nao carrega curriculum.pl — os prerequisitos abaixo sao os unicos fatos na base.
%
% Uso:
%   swipl tests/teste_ciclo.pl
%   ?- rodar_testes_ciclo.

:- consult('../src/trilhas.pl').

% prerequisitos circulares propositais

% ciclo de comprimento 2
prerequisito(ciclo_a, ciclo_b).
prerequisito(ciclo_b, ciclo_a).

% ciclo de comprimento 3
prerequisito(ciclo_x, ciclo_y).
prerequisito(ciclo_y, ciclo_z).
prerequisito(ciclo_z, ciclo_x).

% sem ciclo
prerequisito(solo_b, solo_a).

% depende de ciclico mas nao e ciclico
prerequisito(externa, ciclo_a).

:- dynamic ciclo_pass/1, ciclo_fail/1.
ciclo_pass(0).
ciclo_fail(0).

checar_ciclo(Goal, Desc) :-
    (   call(Goal)
    ->  format("  PASS: ~w~n", [Desc]),
        retract(ciclo_pass(N)), N1 is N + 1, assert(ciclo_pass(N1))
    ;   format("  FAIL: ~w~n", [Desc]),
        retract(ciclo_fail(N)), N1 is N + 1, assert(ciclo_fail(N1))
    ).

checar_ciclo_falha(Goal, Desc) :-
    (   \+ call(Goal)
    ->  format("  PASS: ~w~n", [Desc]),
        retract(ciclo_pass(N)), N1 is N + 1, assert(ciclo_pass(N1))
    ;   format("  FAIL: ~w~n", [Desc]),
        retract(ciclo_fail(N)), N1 is N + 1, assert(ciclo_fail(N1))
    ).

% TC1: ciclo de comprimento 2
teste_ciclo_par :-
    format("~n[TC1] Ciclo de comprimento 2~n"),
    checar_ciclo(existe_ciclo(ciclo_a), "ciclo_a e ciclico"),
    checar_ciclo(existe_ciclo(ciclo_b), "ciclo_b e ciclico").

% TC2: ciclo de comprimento 3
teste_ciclo_triplo :-
    format("~n[TC2] Ciclo de comprimento 3~n"),
    checar_ciclo(existe_ciclo(ciclo_x), "ciclo_x e ciclico"),
    checar_ciclo(existe_ciclo(ciclo_y), "ciclo_y e ciclico"),
    checar_ciclo(existe_ciclo(ciclo_z), "ciclo_z e ciclico").

% TC3: sem ciclo nao gera falso positivo
teste_sem_ciclo :-
    format("~n[TC3] Sem ciclo~n"),
    checar_ciclo_falha(existe_ciclo(solo_a), "solo_a nao e ciclico"),
    checar_ciclo_falha(existe_ciclo(solo_b), "solo_b nao e ciclico").

% TC4: depende de ciclico mas nao faz parte do ciclo
teste_dependente_de_ciclico :-
    format("~n[TC4] Dependente de ciclico~n"),
    checar_ciclo_falha(existe_ciclo(externa), "externa nao e ciclico").

% TC5: nos ciclicos detectados na base
teste_validar_base_ciclica :-
    format("~n[TC5] Nos ciclicos na base~n"),
    findall(D, (prerequisito(D, _), existe_ciclo(D)), Ciclicos),
    sort(Ciclicos, CicSort),
    format("  Nos ciclicos: ~w~n", [CicSort]),
    checar_ciclo(member(ciclo_a, CicSort), "ciclo_a listado"),
    checar_ciclo(member(ciclo_b, CicSort), "ciclo_b listado"),
    checar_ciclo(member(ciclo_x, CicSort), "ciclo_x listado").

rodar_testes_ciclo :-
    retractall(ciclo_pass(_)), assert(ciclo_pass(0)),
    retractall(ciclo_fail(_)), assert(ciclo_fail(0)),

    format("~nTeste de deteccao de ciclos~n"),

    teste_ciclo_par,
    teste_ciclo_triplo,
    teste_sem_ciclo,
    teste_dependente_de_ciclico,
    teste_validar_base_ciclica,

    ciclo_pass(P),
    ciclo_fail(F),
    Total is P + F,
    format("~nResultado: ~w/~w passou  (~w falhou)~n~n", [P, Total, F]).
