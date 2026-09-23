% src/main.pl
% Ponto de entrada do Curriculum Advisor
%
% Uso:
%   swipl src/main.pl
%   ?- demo.

:- use_module(library(lists)).

:- consult('curriculum.pl').
:- consult('elegibilidade.pl').
:- consult('trilhas.pl').

demo :-
    catch(demo_seguro, Erro,
          format("~nErro inesperado durante demo: ~w~n", [Erro])).

demo_seguro :-
    format("~nCurriculum Advisor~n"),

    format("~n[Camada 1] Base de fatos~n~n"),

    findall(D, disciplina(D, _, _, _), Todas),
    length(Todas, NTotal),
    findall(D, disciplina(D, obrigatoria, _, _), Obrig),
    length(Obrig, NObrig),
    findall(D, disciplina(D, eletiva, _, _), Elet),
    length(Elet, NElet),
    format("Disciplinas: ~w  (obrigatorias: ~w | eletivas: ~w)~n",
           [NTotal, NObrig, NElet]),
    format("Eletivas: ~w~n", [Elet]),

    format("~nDisciplinas por semestre:~n"),
    forall(
        between(1, 6, S),
        (findall(D, disciplina(D, _, _, S), Ds),
         format("  Sem ~w: ~w~n", [S, Ds]))
    ),

    format("~n[Camada 2] Elegibilidade~n"),
    demo_aluno(joao,  adiantado),
    demo_aluno(maria, ritmo_normal),
    demo_aluno(pedro, atrasado_trancamento),

    format("~n[Camada 3] Fecho transitivo e trilhas~n~n"),

    format("Pre-requisitos transitivos de tcc:~n"),
    findall(A, prerequisito_transitivo(tcc, A), AncsTcc),
    sort(AncsTcc, AncsTccOrd),
    format("  ~w~n~n", [AncsTccOrd]),

    format("Pre-requisitos transitivos de compiladores:~n"),
    findall(A, prerequisito_transitivo(compiladores, A), AncsComp),
    sort(AncsComp, AncsCompOrd),
    format("  ~w~n~n", [AncsCompOrd]),

    validar_base,

    format("~nTrilha de Maria (max 16 cred/semestre):~n"),
    demo_trilha(maria, 16),

    format("~nTrilha de Pedro (max 16 cred/semestre):~n"),
    demo_trilha(pedro, 16),

    format("~nTrilha de Joao (max 16 cred/semestre):~n"),
    demo_trilha(joao, 16),

    format("~nDuas trilhas distintas para Maria (max 12 cred):~n"),
    demo_multiplas_trilhas(maria, 12).

demo_aluno(Aluno, Descricao) :-
    format("~nAluno: ~w  [~w]~n", [Aluno, Descricao]),
    (   aluno_existe(Aluno)
    ->  creditos_cursados(Aluno, Cred),
        format("  Creditos cursados  : ~w~n", [Cred]),
        disciplinas_liberadas(Aluno, Lib),
        format("  Pode cursar agora  : ~w~n", [Lib]),
        disciplinas_pendentes(Aluno, Pend),
        format("  Obrigatorias pend. : ~w~n", [Pend])
    ;   format("  [aluno nao encontrado na base]~n")
    ).

demo_trilha(Aluno, MaxCred) :-
    (   once(trilha_valida(Aluno, MaxCred, Trilha))
    ->  imprimir_trilha(Trilha, 1)
    ;   format("  Nenhuma trilha encontrada.~n")
    ).

demo_multiplas_trilhas(Aluno, MaxCred) :-
    (   once(trilha_valida(Aluno, MaxCred, T1))
    ->  format("~n  Trilha 1:~n"),
        imprimir_trilha(T1, 1),
        (   once((trilha_valida(Aluno, MaxCred, T2), T2 \= T1))
        ->  format("~n  Trilha 2:~n"),
            imprimir_trilha(T2, 1),
            format("  (existem mais trilhas disponiveis)~n")
        ;   format("  (apenas uma trilha valida encontrada)~n")
        )
    ;   format("  Nenhuma trilha encontrada.~n")
    ).

imprimir_trilha([], _).
imprimir_trilha([Sem|Resto], N) :-
    soma_creditos(Sem, Cred),
    format("  Semestre ~w (~w cred): ~w~n", [N, Cred, Sem]),
    N1 is N + 1,
    imprimir_trilha(Resto, N1).
