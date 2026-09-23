% src/curriculum.pl
% Camada 1: fatos da grade curricular
%   disciplina(Nome, Tipo, Creditos, SemestreSugerido)
%   prerequisito(Disciplina, Prerequisito)
%   cursou(Aluno, Disciplina)

% Semestre 1
disciplina(calculo1,                 obrigatoria, 4, 1).
disciplina(intro_programacao,        obrigatoria, 4, 1).
disciplina(logica_matematica,        obrigatoria, 4, 1).
disciplina(algebra_linear,           obrigatoria, 4, 1).

% Semestre 2
disciplina(calculo2,                 obrigatoria, 4, 2).
disciplina(programacao_oo,           obrigatoria, 4, 2).
disciplina(estruturas_discretas,     obrigatoria, 4, 2).
disciplina(arquitetura_computadores, obrigatoria, 4, 2).

% Semestre 3
disciplina(calculo_numerico,         obrigatoria, 4, 3).
disciplina(algoritmos,               obrigatoria, 4, 3).
disciplina(probabilidade,            obrigatoria, 4, 3).
disciplina(sistemas_operacionais,    obrigatoria, 4, 3).

% Semestre 4
disciplina(banco_dados,              obrigatoria, 4, 4).
disciplina(teoria_grafos,            obrigatoria, 4, 4).
disciplina(redes,                    obrigatoria, 4, 4).
disciplina(eng_software,             obrigatoria, 4, 4).

% Semestre 5
disciplina(inteligencia_artificial,  obrigatoria, 4, 5).
disciplina(compiladores,             obrigatoria, 4, 5).
disciplina(seguranca,                eletiva,     4, 5).
disciplina(banco_dados_avancado,     eletiva,     4, 5).

% Semestre 6
disciplina(machine_learning,         eletiva,     4, 6).
disciplina(processamento_linguagem,  eletiva,     4, 6).
disciplina(computacao_grafica,       eletiva,     4, 6).
disciplina(tcc,                      obrigatoria, 8, 6).

% Prerequisitos — um fato por par

% Semestre 2
prerequisito(calculo2,               calculo1).
prerequisito(programacao_oo,         intro_programacao).
prerequisito(estruturas_discretas,   logica_matematica).

% Semestre 3
prerequisito(calculo_numerico,       calculo2).
prerequisito(calculo_numerico,       algebra_linear).
prerequisito(algoritmos,             programacao_oo).
prerequisito(probabilidade,          calculo2).
prerequisito(sistemas_operacionais,  arquitetura_computadores).

% Semestre 4
prerequisito(banco_dados,            algoritmos).
prerequisito(teoria_grafos,          algoritmos).
prerequisito(teoria_grafos,          estruturas_discretas).
prerequisito(redes,                  sistemas_operacionais).
prerequisito(eng_software,           algoritmos).
prerequisito(eng_software,           programacao_oo).

% Semestre 5
prerequisito(inteligencia_artificial, algoritmos).
prerequisito(inteligencia_artificial, probabilidade).
prerequisito(compiladores,           teoria_grafos).
prerequisito(compiladores,           algoritmos).
prerequisito(seguranca,              redes).
prerequisito(banco_dados_avancado,   banco_dados).

% Semestre 6
prerequisito(machine_learning,       inteligencia_artificial).
prerequisito(machine_learning,       probabilidade).
prerequisito(processamento_linguagem, inteligencia_artificial).
prerequisito(computacao_grafica,     calculo_numerico).
prerequisito(computacao_grafica,     algoritmos).
prerequisito(tcc,                    eng_software).
prerequisito(tcc,                    banco_dados).
prerequisito(tcc,                    compiladores).

% Historico dos alunos

% Joao: adiantado — semestres 1-4 completos + obrigatorias do sem 5
cursou(joao, calculo1).
cursou(joao, intro_programacao).
cursou(joao, logica_matematica).
cursou(joao, algebra_linear).
cursou(joao, calculo2).
cursou(joao, programacao_oo).
cursou(joao, estruturas_discretas).
cursou(joao, arquitetura_computadores).
cursou(joao, calculo_numerico).
cursou(joao, algoritmos).
cursou(joao, probabilidade).
cursou(joao, sistemas_operacionais).
cursou(joao, banco_dados).
cursou(joao, teoria_grafos).
cursou(joao, redes).
cursou(joao, eng_software).
cursou(joao, inteligencia_artificial).
cursou(joao, compiladores).

% Maria: ritmo normal — semestres 1-3 completos
cursou(maria, calculo1).
cursou(maria, intro_programacao).
cursou(maria, logica_matematica).
cursou(maria, algebra_linear).
cursou(maria, calculo2).
cursou(maria, programacao_oo).
cursou(maria, estruturas_discretas).
cursou(maria, arquitetura_computadores).
cursou(maria, calculo_numerico).
cursou(maria, algoritmos).
cursou(maria, probabilidade).
cursou(maria, sistemas_operacionais).

% Pedro: atrasado — historico com trancamento parcial
cursou(pedro, calculo1).
cursou(pedro, intro_programacao).
cursou(pedro, programacao_oo).
