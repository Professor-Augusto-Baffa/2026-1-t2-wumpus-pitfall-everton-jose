:- discontiguous add_blocked/2.
:- discontiguous clear_blocked/0.
:-dynamic posicao/3.
:-dynamic memory/3.
:-dynamic visitado/2.
:-dynamic certeza/2.
:-dynamic energia/1.
:-dynamic pontuacao/1.
:-dynamic sentiu_impacto/0.

:-dynamic energia/1.
:-dynamic pontuacao/1.
:-dynamic ouro/1.
:-dynamic blocked/2.

:-dynamic venceu/0.
:-dynamic saiu_inicio/0.

:-consult('../mapas/mapa.pl').

delete([], _, []).
delete([Elem|Tail], Del, Result) :-
    (   \+ Elem \= Del
    ->  delete(Tail, Del, Result)
    ;   Result = [Elem|Rest],
        delete(Tail, Del, Rest)
    ).
	


% reset_game :- retractall(memory(_,_,_)), 
% 			retractall(visitado(_,_)), 
% 			retractall(certeza(_,_)),
% 			retractall(energia(_)),
% 			retractall(pontuacao(_)),
% 			retractall(posicao(_,_,_)),
% 			assert(energia(100)),
% 			assert(pontuacao(0)),
% 			assert(posicao(1,1, norte)).

reset_game :-retractall(sentiu_impacto), 
			retractall(memory(_,_,_)), 
			retractall(visitado(_,_)), 
			retractall(certeza(_,_)),
			retractall(energia(_)),
			retractall(pontuacao(_)),
			retractall(posicao(_,_,_)),
			retractall(ouro(_)),
			retractall(blocked(_,_)),
            retractall(venceu),
            retractall(saiu_inicio),
			assert(energia(100)),
			assert(pontuacao(0)),
			assert(ouro(0)),
			assert(posicao(1,1, norte)).

:-reset_game.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Controle de Status
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%atualiza pontuacao
atualiza_pontuacao(X):- pontuacao(P), retract(pontuacao(P)), NP is P + X, assert(pontuacao(NP)),!.

%atualiza energia
atualiza_energia(N):- energia(E), retract(energia(E)), NE is E + N, 
					(
					 (NE =<0, assert(energia(0)),posicao(X,Y,_),retract(posicao(_,_,_)), assert(posicao(X,Y,morto)), atualiza_pontuacao(-1000), !);
					 (NE >100, assert(energia(100)),!);
					  (NE >0,assert(energia(NE)),!)
					 ).

%atualiza estado do jogo: se saiu do inicio e se venceu
atualiza_estado_jogo :-
    ( \+posicao(1,1,_), \+saiu_inicio -> assert(saiu_inicio) ; true ),
    ( posicao(1,1,_), saiu_inicio, ouro(Q), Q >= 3, \+venceu -> assert(venceu) ; true ).

%verifica situacao da nova posicao e atualiza energia e pontos
verifica_player :- posicao(X,Y,_), tile(X,Y,'P'), atualiza_energia(-100), atualiza_pontuacao(-1000),!.
verifica_player :- posicao(X,Y,_), tile(X,Y,'D'), atualiza_energia(-50), atualiza_pontuacao(-50),!.
verifica_player :- posicao(X,Y,_), tile(X,Y,'d'), atualiza_energia(-20), atualiza_pontuacao(-20),!.
verifica_player :- posicao(X,Y,Z), tile(X,Y,'T'), 
					map_size(SX,SY), random_between(1,SX,NX), random_between(1,SY,NY),
				retract(posicao(X,Y,Z)), assert(posicao(NX,NY,Z)), atualiza_obs, verifica_player,!.
verifica_player :- true.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Comandos
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%virar direita
virar_direita :- posicao(X,Y, norte), retract(posicao(_,_,_)), assert(posicao(X, Y, leste)),atualiza_pontuacao(-1),!.
virar_direita :- posicao(X,Y, oeste), retract(posicao(_,_,_)), assert(posicao(X, Y, norte)),atualiza_pontuacao(-1),!.
virar_direita :- posicao(X,Y, sul), retract(posicao(_,_,_)), assert(posicao(X, Y, oeste)),atualiza_pontuacao(-1),!.
virar_direita :- posicao(X,Y, leste), retract(posicao(_,_,_)), assert(posicao(X, Y, sul)),atualiza_pontuacao(-1),!.

%virar esquerda
virar_esquerda :- posicao(X,Y, norte), retract(posicao(_,_,_)), assert(posicao(X, Y, oeste)),atualiza_pontuacao(-1),!.
virar_esquerda :- posicao(X,Y, oeste), retract(posicao(_,_,_)), assert(posicao(X, Y, sul)),atualiza_pontuacao(-1),!.
virar_esquerda :- posicao(X,Y, sul), retract(posicao(_,_,_)), assert(posicao(X, Y, leste)),atualiza_pontuacao(-1),!.
virar_esquerda :- posicao(X,Y, leste), retract(posicao(_,_,_)), assert(posicao(X, Y, norte)),atualiza_pontuacao(-1),!.

%andar
andar :- posicao(X,Y,P), P = norte, map_size(_,MAX_Y), Y < MAX_Y, YY is Y + 1, 
         retract(posicao(X,Y,_)), assert(posicao(X, YY, P)), 
		 %((retract(certeza(X,YY)), assert(certeza(X,YY))); assert(certeza(X,YY))),
		 set_real(X,YY),
		 ((retract(visitado(X,Y)), assert(visitado(X,Y))); assert(visitado(X,Y))),retractall(sentiu_impacto),atualiza_pontuacao(-1),!.
		 
andar :- posicao(X,Y,P), P = sul,  Y > 1, YY is Y - 1, 
         retract(posicao(X,Y,_)), assert(posicao(X, YY, P)), 
		 %((retract(certeza(X,YY)), assert(certeza(X,YY))); assert(certeza(X,YY))),
		 set_real(X,YY),
		 ((retract(visitado(X,Y)), assert(visitado(X,Y))); assert(visitado(X,Y))),retractall(sentiu_impacto),atualiza_pontuacao(-1),!.

andar :- posicao(X,Y,P), P = leste, map_size(MAX_X,_), X < MAX_X, XX is X + 1, 
         retract(posicao(X,Y,_)), assert(posicao(XX, Y, P)), 
		 %((retract(certeza(XX,Y)), assert(certeza(XX,Y))); assert(certeza(XX,Y))),
		 set_real(XX,Y),
		 ((retract(visitado(X,Y)), assert(visitado(X,Y))); assert(visitado(X,Y))),retractall(sentiu_impacto),atualiza_pontuacao(-1),!.

andar :- posicao(X,Y,P), P = oeste,  X > 1, XX is X - 1, 
         retract(posicao(X,Y,_)), assert(posicao(XX, Y, P)), 
		 %((retract(certeza(XX,Y)), assert(certeza(XX,Y))); assert(certeza(XX,Y))),
		 set_real(XX,Y),
		 ((retract(visitado(X,Y)), assert(visitado(X,Y))); assert(visitado(X,Y))),retractall(sentiu_impacto),atualiza_pontuacao(-1),!.
		 
%pegar	
pegar :- posicao(X,Y,_), tile(X,Y,'O'), retract(tile(X,Y,'O')), assert(tile(X,Y,'')), atualiza_pontuacao(-1), atualiza_pontuacao(1000), ouro(Q), NQ is Q + 1, retract(ouro(Q)), assert(ouro(NQ)), set_real(X,Y),!.
pegar :- posicao(X,Y,_), tile(X,Y,'U'), retract(tile(X,Y,'U')), assert(tile(X,Y,'')), atualiza_pontuacao(-1), atualiza_energia(20),set_real(X,Y),!.
pegar :- atualiza_pontuacao(-1),!.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Funcoes Auxiliares de navegação e observação
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		 
%Define as 4 adjacencias		 
adjacente(X, Y) :- posicao(PX, Y, _), map_size(MAX_X,_),PX < MAX_X, X is PX + 1.  
adjacente(X, Y) :- posicao(PX, Y, _), PX > 1, X is PX - 1.  
adjacente(X, Y) :- posicao(X, PY, _), map_size(_,MAX_Y),PY < MAX_Y, Y is PY + 1.  
adjacente(X, Y) :- posicao(X, PY, _), PY > 1, Y is PY - 1.  

%cria lista com a adjacencias
adjacentes(L) :- findall(Z,(adjacente(X,Y),tile(X,Y,Z)),L).

%define observacoes locais
observacao_loc(brilho,L) :- member('O',L).
observacao_loc(reflexo,L) :- member('U',L).

%define observacoes adjacentes
observacao_adj(brisa,L) :- member('P',L).
observacao_adj(palmas,L) :- member('T',L).
observacao_adj(passos,L) :- member('D',L).
observacao_adj(passos,L) :- member('d',L).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Tratamento de KB e observações
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%consulta e processa observações
atualiza_obs:-adj_cand_obs(LP), observacoes(LO), iter_pos_list(LP,LO), observacao_certeza, observacao_vazia, atualiza_estado_jogo.

%adjacencias candidatas p/ a observacao (aquelas não visitadas)
adj_cand_obs(L) :- findall((X,Y), (adjacente(X, Y), \+visitado(X,Y)), L).

%cria lista de observacoes
observacoes(X) :- adjacentes(L), findall(Y, observacao_adj(Y,L), X).

%itera posicoes da lista para adicionar observacoes
iter_pos_list([], _) :- !.
iter_pos_list([H|T], LO) :- H=(X,Y), 
							((corrige_observacoes_antigas(X, Y, LO),!);
							adiciona_observacoes(X, Y, LO)),
							iter_pos_list(T, LO).							 

%Corrige observacoes antigas na memoria que ficaram com apenas uma adjacencia
corrige_observacoes_antigas(X, Y, []):- \+certeza(X,Y), memory(X,Y,[]).
corrige_observacoes_antigas(X, Y, LO):-
	\+certeza(X,Y), \+ memory(X,Y,[]), memory(X, Y, LM), intersection(LO, LM, L), 
	retract(memory(X, Y, LM)), assert(memory(X, Y, L)).

%Adiciona observacoes na memoria
adiciona_observacoes(X, Y, _) :- certeza(X,Y),!.
adiciona_observacoes(X, Y, LO) :- \+certeza(X,Y), \+ memory(X,Y,_), assert(memory(X, Y, LO)).

%Quando há apenas uma observação e uma unica posição incerta, deduz que a observação está na casa incerta
%e marca como certeza
%observacao_certeza:- findall((X,Y), (adjacente(X, Y), 
%						((\+visitado(X,Y), \+certeza(X,Y));(certeza(X,Y),memory(X,Y,ZZ),ZZ\=[])),
%						memory(X,Y,Z), Z\=[]), L), ((length(L,1),L=[(XX,YY)], assert(certeza(XX,YY)),!);true).
						
observacao_certeza:- observacao_certeza('brisa'),
						observacao_certeza('palmas'),
						observacao_certeza('passos').
						
observacao_certeza(Z):- findall((X,Y), (adjacente(X, Y), 
						((\+visitado(X,Y), \+certeza(X,Y));(certeza(X,Y),memory(X,Y,[Z]))),
						memory(X,Y,[Z])), L), ((length(L,1),L=[(XX,YY)], assert(certeza(XX,YY)),!);true).						

%Quando posição não tem observações
observacao_vazia:- adj_cand_obs(LP), observacao_vazia(LP).
observacao_vazia([]) :- !.
observacao_vazia([H|T]) :- H=(X,Y), ((memory(X,Y,[]), \+certeza(X,Y),assert(certeza(X,Y)),!);true), observacao_vazia(T).

%Quando posicao é visitada, atualiza memoria de posicao com a informação real do mapa 
set_real(X,Y):- ((retract(certeza(X,Y)), assert(certeza(X,Y)),!); assert(certeza(X,Y))), set_real2(X,Y),!.
set_real2(X,Y):- tile(X,Y,'P'), ((retract(memory(X,Y,_)),assert(memory(X,Y,[brisa])),!);assert(memory(X,Y,[brisa]))),!.
set_real2(X,Y):- tile(X,Y,'O'), ((retract(memory(X,Y,_)),assert(memory(X,Y,[brilho])),!);assert(memory(X,Y,[brilho]))),!.
set_real2(X,Y):- tile(X,Y,'T'), ((retract(memory(X,Y,_)),assert(memory(X,Y,[palmas])),!);assert(memory(X,Y,[palmas]))),!.
set_real2(X,Y):- ((tile(X,Y,'D'),!); tile(X,Y,'d')), ((retract(memory(X,Y,_)),assert(memory(X,Y,[passos])),!);assert(memory(X,Y,[passos]))),!.
set_real2(X,Y):- tile(X,Y,'U'), ((retract(memory(X,Y,_)),assert(memory(X,Y,[reflexo])),!);assert(memory(X,Y,[reflexo]))),!.
set_real2(X,Y):- tile(X,Y,''), ((retract(memory(X,Y,_)),assert(memory(X,Y,[])),!);assert(memory(X,Y,[]))),!.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Mostra mapa real
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
show_player(X,Y) :- posicao(X,Y, norte), write('^'),!.
show_player(X,Y) :- posicao(X,Y, oeste), write('<'),!.
show_player(X,Y) :- posicao(X,Y, leste), write('>'),!.
show_player(X,Y) :- posicao(X,Y, sul), write('v'),!.
show_player(X,Y) :- posicao(X,Y, morto), write('+'),!.

%show_position(X,Y) :- show_player(X,Y),!.
show_position(X,Y) :- (show_player(X,Y); write(' ')), tile(X,Y,Z), ((Z='', write(' '));write(Z)),!.

show_map :- map_size(_,MAX_Y), show_map(1,MAX_Y),!.
show_map(X,Y) :- Y >= 1, map_size(MAX_X,_), X =< MAX_X, show_position(X,Y), write(' | '), XX is X + 1, show_map(XX, Y),!.
show_map(X,Y) :- Y >= 1, map_size(X,_),YY is Y - 1, write(Y), nl, show_map(1, YY),!.
show_map(_,0) :- energia(E), pontuacao(P), write('E: '), write(E), write('   P: '), write(P),!.



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Mostra mapa conhecido
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

show_mem_info(X,Y) :- memory(X,Y,Z), 
		((visitado(X,Y), write('.'),!); (\+certeza(X,Y), write('?'),!); (certeza(X,Y), write('!'))),
		((member(brisa, Z), write('P'));write(' ')),
		((member(palmas, Z), write('T'));write(' ')),
		((member(brilho, Z), write('O'));write(' ')),
		((member(passos, Z), write('D'));write(' ')),
		((member(reflexo, Z), write('U'));write(' ')),!.

show_mem_info(X,Y) :- \+memory(X,Y,[]), 
			((visitado(X,Y), write('.'),!); (\+certeza(X,Y), write('?'),!); (certeza(X,Y), write('!'))),
			write('     '),!.		
		
		

show_mem_position(X,Y) :- posicao(X,Y,_), 
		((visitado(X,Y), write('.'),!); (certeza(X,Y), write('!'),!); write(' ')),
		write(' '), show_player(X,Y),
		((memory(X,Y,Z),
		((member(brilho, Z), write('O'));write(' ')),
		((member(passos, Z), write('D'));write(' ')),
		((member(reflexo, Z), write('U'));write(' ')),!);
		(write('   '),!)).

		
show_mem_position(X,Y) :- show_mem_info(X,Y),!.


show_mem :- map_size(_,MAX_Y), show_mem(1,MAX_Y),!.
show_mem(X,Y) :- Y >= 1, map_size(MAX_X,_), X =< MAX_X, show_mem_position(X,Y), write('|'), XX is X + 1, show_mem(XX, Y),!.
show_mem(X,Y) :- Y >= 1, map_size(X,_),YY is Y - 1, write(Y), nl, show_mem(1, YY),!.
show_mem(_,0) :- energia(E), pontuacao(P), write('E: '), write(E), write('   P: '), write(P),!.



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%apagar esta linha - apenas para demonstracao aleatoria
%executa_acao(X) :- L=['virar_esquerda','virar_direita','andar','pegar'],random_between(1,4,I), nth1(I, L, X),!.

%apagar linhas abaixo... sao exemplos de resposta
%executa_acao(andar) :- posicao(PX, _, oeste), PX > 1, X = andar,!.
%executa_acao(andar) :- posicao(PX, _, leste), PX < 3, X = andar,!.
%executa_acao(pegar) :- posicao(PX, PY,_), tem_ouro(PX, PY), !.
%executa_acao(voltar) :- peguei_todos_ouros,!.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ORDEM DE EXECUÇÃO DE AÇÕES (Cérebro do Agente)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 1- Se pegou os 3 ouros, foge para o início (A*) para ganhar o jogo.
executa_acao(X) :- ouro(Qtd), Qtd >= 3, X = go_to(1,1).

% 2- Se está pisando no ouro, pega.
executa_acao(X) :- posicao(X0,Y0,_), memory(X0,Y0,[brilho]), !, X = pegar.

% 3- Se está no power-up e precisa, pega.
executa_acao(X) :- posicao(X0,Y0,_), memory(X0,Y0,[reflexo]), energia(E), E =< 50, !, X = pegar.

% 4- Continua andando para frente se for 100% seguro.
executa_acao(andar) :- posicao(X,Y,Dir), proximo(X,Y,Dir,NX,NY), memory(NX,NY,Percepts), Percepts = [], \+ visitado(NX,NY), !.

% 5- Se não dá para ir para frente, mas tem um lado seguro, vira para lá.
executa_acao(X) :- posicao(XN,YN,DirAtual), valid_direction(XN,YN,DirAlvo), turn_action(DirAtual, DirAlvo, X), !.

% 6- Beco sem saída seguro: chama o A* para voltar para a fronteira segura mais próxima.
executa_acao(X) :- posicao(CX, CY, _), nearest_open(TX, TY, _), not_blocked(TX,TY), (CX \= TX ; CY \= TY), X = go_to(TX, TY), !.

% 7- Acabou a segurança. Avalia o Risco: Se a energia aguenta um monstro, avança na fronteira de um monstro suspeito.
executa_acao(X) :- max_monster_damage(MaxD), energia(E), E > MaxD, nearest_monster_frontier(TX,TY,DirM,_), not_blocked(TX,TY), posicao(CX,CY,DirNow),
    ( (CX \= TX ; CY \= TY) ->  X = go_to(TX,TY) ; (DirNow \= DirM -> turn_action(DirNow,DirM,X) ;  X = andar) ), !.

% 8- Vida baixa e monstros à vista: busca poção para sobreviver.
executa_acao(X) :- max_monster_damage(MaxD), energia(E), E =< MaxD, known_monster, nearest_potion(TX,TY,_), not_blocked(TX,TY), X = go_to(TX,TY), !.

% 9- Sem poção e sem segurança: arrisca o teletransporte do morcego.
executa_acao(X) :- nearest_bat_frontier(TX,TY,DirB,_), not_blocked(TX,TY), posicao(CX,CY,DirNow),
    ( (CX \= TX ; CY \= TY) ->  X = go_to(TX,TY) ; (DirNow \= DirB -> turn_action(DirNow,DirB,X) ;  X = andar) ), !.

% 10- Encurralado por monstros: enfrenta um garantido.
executa_acao(X) :- trapped_monster_dir(_), X = andar, !.

% 11- Encurralado por poços/morcegos: bate no monstro.
executa_acao(X) :- trapped_bat_pit_dir(DirM), max_monster_damage(MaxD), energia(E), E  > MaxD, posicao(_,_,DirNow),
    ( DirNow \= DirM -> turn_action(DirNow,DirM,X) ;  X = andar ), !.

% 12- Desespero total: avança cego para o poço.
executa_acao(X) :- nearest_pit_frontier(TX,TY,DirP,_), not_blocked(TX,TY), posicao(CX,CY,DirNow),
    ( (CX \= TX ; CY \= TY) ->  X = go_to(TX,TY) ; (DirNow \= DirP -> turn_action(DirNow,DirP,X) ;  X = andar) ).


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% Motor de Decisão do Agente
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % Prioridade 1: Reflexos Condicionados (Pegar Ouro ou Energia)
% executa_acao(pegar) :- 
%     posicao(X, Y, _),          % Descobre onde o agente está
%     memory(X, Y, Obs),         % Puxa o que ele está sentindo nessa posição
%     member(brilho, Obs),       % Verifica se "brilho" está na lista de observações
%     !.                         % O "Cut" (!) impede que o Prolog procure outras regras

% executa_acao(pegar) :- 
%     posicao(X, Y, _), 
%     memory(X, Y, Obs), 
%     member(reflexo, Obs), 
%     !.

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% Regras Auxiliares de Movimento e Direção
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % Define para qual direção cardeal fica o vizinho em relação a posição X, Y atual
% vizinho_direcao(X, Y, NX, Y, leste) :- NX is X + 1.
% vizinho_direcao(X, Y, NX, Y, oeste) :- NX is X - 1.
% vizinho_direcao(X, Y, X, NY, norte) :- NY is Y + 1.
% vizinho_direcao(X, Y, X, NY, sul) :- NY is Y - 1.

% % Tabela de decisões de giro: Como virar da DirAtual para a DirDesejada da forma mais rápida
% melhor_virada(norte, leste, virar_direita).
% melhor_virada(norte, oeste, virar_esquerda).
% melhor_virada(norte, sul, virar_direita). % Meia-volta (precisará de 2 turnos, começa virando para a direita)

% melhor_virada(sul, leste, virar_esquerda).
% melhor_virada(sul, oeste, virar_direita).
% melhor_virada(sul, norte, virar_direita).

% melhor_virada(leste, sul, virar_direita).
% melhor_virada(leste, norte, virar_esquerda).
% melhor_virada(leste, oeste, virar_direita).

% melhor_virada(oeste, sul, virar_esquerda).
% melhor_virada(oeste, norte, virar_direita).
% melhor_virada(oeste, leste, virar_direita).


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% Prioridade 2: Exploração de Vizinhança Segura
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% executa_acao(Acao) :-
%     posicao(X, Y, DirAtual),           % Pega a posição e direção atual do agente
%     adjacente(NX, NY),                 % Verifica um quadrado adjacente
%     \+ visitado(NX, NY),               % Garante que ainda não passamos por ele
%     certeza(NX, NY),                   % Garante que a lógica já processou a sala
%     ( memory(NX, NY, [])               % E a sala está vazia (sem perigos)
%       ; memory(NX, NY, [brilho])       % OU tem ouro
%       ; memory(NX, NY, [reflexo])      % OU tem energia
%     ),
%     vizinho_direcao(X, Y, NX, NY, DirDesejada), % Descobre para onde essa sala segura fica
%     (   DirAtual = DirDesejada         % Se já estou olhando para a sala...
%     ->  Acao = andar                   % ... a ação é andar pra frente!
%     ;   melhor_virada(DirAtual, DirDesejada, Acao) % Se não, consulta a tabela de giro
%     ),
%     !.                                 % Cut! Para de pensar e executa.

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% Prioridade 3: Solicitar Rota (A*) ao Python
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Se o agente travou, pede ao Python para calcular a rota até a fronteira segura mais próxima
executa_acao(buscar_caminho) :- !.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% INTELIGÊNCIA: Seguranças, Certezas e Suspeitas
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% O ponto de partida é sempre seguro por regra.
seguro(1,1).

% Uma casa é 100% segura SE o agente tem certeza sobre ela E a memória de perigos está vazia.
seguro(X,Y) :-
    certeza(X,Y),
    memory(X,Y, []).

% Monstro CONFIRMADO: O agente tem 'certeza' e a memória da casa tem 'passos'.
monster_cert_cell(X,Y) :-
    certeza(X,Y),
    memory(X,Y,L),
    member(passos,L).

% Monstro SUSPEITO: Tem 'passos' na memória, MAS não há certeza absoluta. 
% (Ele também verifica se não tem brisa ou palmas junto para não confundir os perigos).
monster_sus_cell(X,Y) :-
    memory(X,Y,L),
    member(passos, L),
    \+ member(palmas, L),
    \+ member(brisa, L),
    \+ certeza(X,Y).

% Morcego SUSPEITO (Flash / Palmas)
bat_sus_cell(X,Y) :-
    memory(X,Y,L),
    member(palmas, L),
    \+ member(brisa, L),
    \+ certeza(X,Y).

% Poço SUSPEITO (Brisa) - O poço é o pior cenário, se tem brisa e não há certeza, é suspeito.
pit_sus_cell(X,Y) :-
    memory(X,Y,L),
    member(brisa, L),
    \+ certeza(X,Y).
    
% Regra rápida para saber se existe ALGUM monstro suspeito no mapa
known_monster :-
    monster_sus_cell(_,_).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% INTELIGÊNCIA: Matemática de Direções
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Mapeia cada direção em um delta (DX,DY) no plano cartesiano.
possible_dir(norte, 0,  1).
possible_dir(leste,  1,  0).
possible_dir(sul,    0, -1).
possible_dir(oeste, -1,  0).

% Atribui um índice matemático para cada direção (usaremos para calcular giros depois)
dir_index(norte, 0).
dir_index(leste, 1).
dir_index(sul,   2).
dir_index(oeste, 3).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% INTELIGÊNCIA: Fronteiras Táticas
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Fronteira de Monstro: Uma casa segura e visitada que tem um monstro suspeito como vizinho.
monster_frontier(VX,VY,Dir) :-  
    ( visitado(VX,VY) ; posicao(VX,VY,_) ),
    seguro(VX,VY),                     
    possible_dir(Dir,DX,DY),             
    MX is VX+DX,  MY is VY+DY,           
    monster_sus_cell(MX,MY).           

% Fronteira de Morcego: Uma casa segura e visitada encostada num morcego suspeito.
bat_frontier(VX,VY,Dir) :-
    ( visitado(VX,VY) ; posicao(VX,VY,_) ),
    seguro(VX,VY),
    possible_dir(Dir,DX,DY),            
    MX is VX+DX, MY is VY+DY,           
    bat_sus_cell(MX,MY).                

% Fronteira de Poço: Uma casa segura e visitada encostada num poço suspeito.
pit_frontier(VX,VY,Dir) :-
    ( visitado(VX,VY) ; posicao(VX,VY,_) ), 
    seguro(VX,VY),                      
    possible_dir(Dir,DX,DY),            
    MX is VX+DX, MY is VY+DY,           
    pit_sus_cell(MX,MY).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% INTELIGÊNCIA: Navegação e Distâncias
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Garante que nenhum alvo de navegação seja considerado impossível a priori
% not_blocked(_, _).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Gerenciamento de bloqueio A*
add_blocked(X,Y) :- blocked(X,Y), !.
add_blocked(X,Y) :- assertz(blocked(X,Y)).

clear_blocked :- retractall(blocked(_,_)).

not_blocked(X,Y) :- \+ blocked(X,Y).

% Dano máximo para cálculo de sobrevivência
max_monster_damage(50).

% Quem é o bloco à frente do agente?
proximo(X,Y,norte,  X, Y1) :- Y1 is Y+1.
proximo(X,Y,sul,    X, Y1) :- Y1 is Y-1.
proximo(X,Y,leste,  X1, Y) :- X1 is X+1.
proximo(X,Y,oeste,  X1, Y) :- X1 is X-1.

% Informa para qual lado o agente deve virar
turn_action(DirAtual, DirAlvo, virar_direita) :-
    dir_index(DirAtual, I1), dir_index(DirAlvo,  I2),
    D is (I2 - I1 + 4) mod 4, D =:= 1, !.
turn_action(DirAtual, DirAlvo, virar_esquerda) :-
    dir_index(DirAtual, I1), dir_index(DirAlvo,  I2),
    D is (I2 - I1 + 4) mod 4, D =:= 3, !.
turn_action(_, _, virar_direita). % Retorno (180 graus), vira duas vezes

% Retorna uma direção válida (não visitada e sem perigo) ao redor do bloco
valid_direction(X,Y,Dir) :-
    possible_dir(Dir,DX,DY), NX is X + DX, NY is Y + DY,
    map_size(MAX_X,MAX_Y), between(1,MAX_X,NX), between(1,MAX_Y,NY),
    memory(NX,NY,Percepts), Percepts = [], \+ visitado(NX,NY), !.

% Verifica se o bloco tem pelo menos um vizinho não visitado e sem avisos
has_safe_frontier(X,Y) :-
    member((DX,DY), [(1,0),(-1,0),(0,1),(0,-1)]),
	NX is X + DX, NY is Y + DY,
    map_size(MAX_X,MAX_Y), between(1,MAX_X,NX), between(1,MAX_Y,NY),
    \+ visitado(NX,NY), memory(NX,NY,Percepts), Percepts = [], !.

% Acha o bloco seguro e visitado mais próximo que tenha caminhos abertos
nearest_open(TX,TY,D) :-
    posicao(X0,Y0,_),
    findall(Dist-(VX,VY), 
      ( visitado(VX,VY), Dist is abs(VX-X0) + abs(VY-Y0), has_safe_frontier(VX,VY) ),
      Pairs), Pairs \= [], keysort(Pairs, [D-(TX,TY)|_]).

% Acha a poção conhecida mais próxima
nearest_potion(TX,TY,D) :-
    posicao(X0,Y0,_),
    findall(Dist-(PX,PY),
      ( memory(PX,PY,[reflexo]), Dist is abs(PX-X0) + abs(PY-Y0) ),
      Pairs), Pairs \= [], keysort(Pairs,[D-(TX,TY)|_]).

% Acha a fronteira de monstro mais próxima
nearest_monster_frontier(TX,TY,Dir,D) :-
    posicao(X0,Y0,_),
    findall( Dist-(VX,VY,Dir1),
             ( monster_frontier(VX,VY,Dir1), Dist is abs(VX-X0)+abs(VY-Y0) ),
             Pairs), Pairs \= [], keysort(Pairs,[D-(TX,TY,Dir)|_]).

% Acha a fronteira de morcego mais próxima
nearest_bat_frontier(TX,TY,Dir,D) :-                     
    posicao(X0,Y0,_),
    findall( Dist-(VX,VY,Dir1),
             ( bat_frontier(VX,VY,Dir1), Dist is abs(VX-X0)+abs(VY-Y0) ),
             Pairs), Pairs \= [], keysort(Pairs,[D-(TX,TY,Dir)|_]).

% Acha a fronteira de poço mais próxima
nearest_pit_frontier(TX,TY,Dir,D) :-                     
    posicao(X0,Y0,_),
    findall( Dist-(VX,VY,Dir1),
             ( pit_frontier(VX,VY,Dir1), Dist is abs(VX-X0)+abs(VY-Y0) ),
             Pairs), Pairs \= [], keysort(Pairs,[D-(TX,TY,Dir)|_]).

% Identifica se está encurralado por monstros suspeitos e um certo
trapped_monster_dir(DirM) :-
    posicao(X,Y,_), possible_dir(DirM,DXM,DYM), MX is X+DXM, MY is Y+DYM, monster_cert_cell(MX,MY),
    map_size(MAX_X,MAX_Y),
    forall((possible_dir(Dir2,DX2,DY2), Dir2 \= DirM, NX is X+DX2, NY is Y+DY2, between(1,MAX_X,NX), between(1,MAX_Y,NY)),
      (monster_sus_cell(NX,NY))).

% Identifica se está encurralado por poços/morcegos e um monstro certo
trapped_bat_pit_dir(DirM) :-
    posicao(X,Y,_), possible_dir(DirM,DXM,DYM), MX is X+DXM, MY is Y+DYM, monster_cert_cell(MX,MY),
    map_size(MAX_X,MAX_Y),
    forall((possible_dir(Dir2,DX2,DY2), Dir2 \= DirM, NX is X+DX2, NY is Y+DY2, between(1,MAX_X,NX), between(1,MAX_Y,NY)),
      (pit_sus_cell(NX,NY) ; bat_sus_cell(NX,NY))).

:-dynamic blocked/2.
add_blocked(X,Y) :- blocked(X,Y), !.
add_blocked(X,Y) :- assertz(blocked(X,Y)).

clear_blocked :- retractall(blocked(_,_)).