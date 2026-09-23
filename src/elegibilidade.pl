% src/elegibilidade.pl
% Camada 2: regras de elegibilidade
% Assumido ja carregado: curriculum.pl

% soma uma lista de inteiros
somar_lista([], 0).
somar_lista([H|T], Total) :-
    somar_lista(T, Sub),
    Total is H + Sub.

% true se o aluno tem ao menos um registro na base
aluno_existe(Aluno) :-
    cursou(Aluno, _), !.

% true se o aluno cursou todos os prereqs diretos da disciplina
prerequisitos_ok(Aluno, Disciplina) :-
    disciplina(Disciplina, _, _, _),
    forall(prerequisito(Disciplina, Pre),
           cursou(Aluno, Pre)).

% true se o aluno pode se matricular na disciplina agora
pode_cursar(Aluno, Disciplina) :-
    aluno_existe(Aluno),
    disciplina(Disciplina, _, _, _),
    prerequisitos_ok(Aluno, Disciplina),
    \+ cursou(Aluno, Disciplina).

% lista ordenada de tudo que o aluno pode cursar agora
disciplinas_liberadas(Aluno, Lista) :-
    findall(D, pode_cursar(Aluno, D), Bruta),
    sort(Bruta, Lista). 

% lista ordenada de obrigatorias ainda nao cursadas
disciplinas_pendentes(Aluno, Lista) :-
    (   aluno_existe(Aluno)
    ->  findall(D,
                (disciplina(D, obrigatoria, _, _),
                 \+ cursou(Aluno, D)),
                Bruta),
        sort(Bruta, Lista)
    ;   Lista = []
    ).

% soma de creditos de todas as disciplinas ja cursadas
creditos_cursados(Aluno, Total) :-
    findall(C,
            (cursou(Aluno, D),
             disciplina(D, _, C, _)),
            Creditos),
    somar_lista(Creditos, Total).
