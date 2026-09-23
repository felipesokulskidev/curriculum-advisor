% src/trilhas.pl
% Camada 3: fecho transitivo e geracao de trilhas de formatura
% Assumido ja carregado: curriculum.pl e elegibilidade.pl

:- use_module(library(lists)).

% todos os ancestrais diretos e indiretos de uma disciplina
prerequisito_transitivo(Disciplina, Ancestral) :-
    prerequisito(Disciplina, Ancestral).
prerequisito_transitivo(Disciplina, Ancestral) :-
    prerequisito(Disciplina, Meio),
    prerequisito_transitivo(Meio, Ancestral).

% detecta ciclo usando DFS com conjunto de visitados
existe_ciclo(Disciplina) :-
    existe_ciclo_dfs(Disciplina, Disciplina, [Disciplina]).

existe_ciclo_dfs(Atual, Alvo, _) :-
    prerequisito(Atual, Alvo).
existe_ciclo_dfs(Atual, Alvo, Visitados) :-
    prerequisito(Atual, Proximo),
    \+ member(Proximo, Visitados),
    existe_ciclo_dfs(Proximo, Alvo, [Proximo|Visitados]).

% checa ciclos em todas as disciplinas e reporta
validar_base :-
    findall(D, (disciplina(D, _, _, _), existe_ciclo(D)), ComCiclo),
    (   ComCiclo = []
    ->  format("Validacao da base: OK — nenhum ciclo detectado.~n")
    ;   format("AVISO — ciclos detectados nas disciplinas: ~w~n", [ComCiclo])
    ).

% soma de creditos de uma lista de disciplinas
soma_creditos([], 0).
soma_creditos([H|T], Total) :-
    disciplina(H, _, Cred, _),
    soma_creditos(T, Resto),
    Total is Cred + Resto.

% disciplinas de Pendentes cujos prereqs diretos ja estao em Feitas
disponiveis(Feitas, Pendentes, Candidatas) :-
    findall(D,
            (member(D, Pendentes),
             forall(prerequisito(D, Pre), member(Pre, Feitas))),
            Candidatas).

% gera subconjuntos nao vazios de Candidatas com soma de creditos <= MaxCred
selecionar_semestre(Candidatas, MaxCred, Semestre) :-
    selecionar_aux(Candidatas, MaxCred, 0, Semestre),
    Semestre \= [].

selecionar_aux([], _, _, []).
selecionar_aux([H|T], Max, Acum, [H|Resto]) :-
    disciplina(H, _, Cred, _),
    NovoAcum is Acum + Cred,
    NovoAcum =< Max,
    selecionar_aux(T, Max, NovoAcum, Resto).
selecionar_aux([_|T], Max, Acum, Resto) :-
    selecionar_aux(T, Max, Acum, Resto).
    

% gera uma trilha de formatura cobrindo todas as obrigatorias pendentes
trilha_valida(Aluno, MaxCred, Trilha) :-
    aluno_existe(Aluno),
    findall(D, cursou(Aluno, D), JaFeitas),
    findall(D, disciplina(D, obrigatoria, _, _), TodasObrig),
    findall(D, (member(D, TodasObrig), \+ member(D, JaFeitas)), Pendentes),
    gerar_trilha(JaFeitas, Pendentes, MaxCred, 0, Trilha).

gerar_trilha(_, [], _, _, []) :- !.
gerar_trilha(Feitas, Pendentes, MaxCred, SemAtual, [Semestre|Resto]) :-
    SemAtual < 12,
    ProxSem is SemAtual + 1,
    disponiveis(Feitas, Pendentes, Candidatas),
    Candidatas \= [],
    selecionar_semestre(Candidatas, MaxCred, Semestre),
    findall(D, (member(D, Pendentes), \+ member(D, Semestre)), NovosPendentes),
    append(Feitas, Semestre, NovasFeitas),
    gerar_trilha(NovasFeitas, NovosPendentes, MaxCred, ProxSem, Resto).
