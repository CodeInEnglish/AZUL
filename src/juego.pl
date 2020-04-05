% La bolsa es una lista de 5 elementos.
% Cada elemento de la lista representa la cantidad de azulejos de un color que hay en la bolsa.
% Los indices de los colores son: 0-amarillo, 1-rojo, 2-azul, 3-gris, 4-negro

% Los jugadores estan enumerados del 1 al 4


% Predicados dinamicos
:- dynamic
   cant_fabricas/1,
   cant_jugadores/1,
   estado_bolsa/2,
   estado_puntuaciones/3,
   estado_fabricas/4,
   estado_muro/4,
   estado_suelo/4,
   estado_patrones/4.

% Decidir el numero de fabricas

no_fabricas(2, 5).
no_fabricas(3, 7).
no_fabricas(4, 9).


% decidir el jugador inicial

jugador_inicial(No_jugadores, Jugador_escogido):- N is No_jugadores + 1, random(1, N, Jugador_escogido).


% sacar un azulejo al azar de la bolsa

extrae_azulejo_bolsa(Bolsa_antes, Azulejo_escogido, Bolsa_despues):-
    escoge_azulejo_bolsa(Bolsa_antes, Idx_azulejo_escogido),
    nth0(Idx_azulejo_escogido, Bolsa_antes, Azulejo_escogido),
    substrae_azulejo_bolsa(Bolsa_antes, Idx_azulejo_escogido, Bolsa_despues).

    substrae_azulejo_bolsa(Bolsa_antes, Idx_Azulejo, Bolsa_despues):-
        borra_lista(Bolsa_antes, Idx_Azulejo, Bolsa_despues).

    borra_lista([_|R], 0, R).
    borra_lista([A|R], C, [A|M]):-
        T is C - 1,
        borra_lista(R, T, M).

    escoge_azulejo_bolsa(Bolsa, Azulejo_escogido):-
        length(Bolsa, N),
        random(0, N, Azulejo_escogido).


% extraer 4 azulejos de la bolsa

extrae_4_azulejos_bolsa(Bolsa_antes, [A1, A2, A3, A4], Bolsa_despues):-
    extrae_azulejo_bolsa(Bolsa_antes, A1, Bd1),
    extrae_azulejo_bolsa(Bd1, A2, Bd2),
    extrae_azulejo_bolsa(Bd2, A3, Bd3),
    extrae_azulejo_bolsa(Bd3, A4, Bolsa_despues).


% Por cada fabrica, sacar 4 azulejos y colocarlos en la misma

llena_fabricas(Bolsa_antes, N, Fabricas, Bolsa_despues):-
    llena_fabricas_(Bolsa_antes, N, [], Fabricas, Bolsa_despues).

    llena_fabricas_(Bolsa_antes, 0, Fabricas_antes, Fabricas_antes, Bolsa_antes).
    llena_fabricas_(Bolsa_antes, N, Fabricas_antes, Fabricas_despues, Bolsa_despues):-
        extrae_4_azulejos_bolsa(Bolsa_antes, Azulejos_escogidos, Bolsa_intermedia),
        M is N - 1,
        llena_fabricas_(Bolsa_intermedia, M, [Azulejos_escogidos|Fabricas_antes], Fabricas_despues, Bolsa_despues).


% el primer jugador llena cada fabrica con 4 azulejos extraidos al azar

mueve_azulejos_bolsa_fabrica(No_ronda, Jugador):-
    estado_bolsa(No_ronda, Bolsa_antes),
    cant_fabricas(CF),
    llena_fabricas(Bolsa_antes, CF, Fabricas, Bolsa_despues),
    retract(estado_bolsa(No_ronda, Bolsa_antes)),
    asserta(estado_bolsa(No_ronda, Bolsa_despues)),
    asserta(estado_fabricas(No_ronda, 1, Jugador, Fabricas)).

mueve_azulejos_fabrica_centro(Fabrica, Centro_antes, Centro_despues)
    :- append(Centro_antes, Fabrica, Centro_despues).

encuentra_fabrica(Fabricas, Color, F) :-
    member(F, Fabricas),
    member(Color, F).

extrae_un_azulejo_fabrica(Fabrica_antes, Azulejo_escogido, Fabrica_despues) :-
    nth0(Idx_azulejo_escogido, Fabrica_antes, Azulejo_escogido),
    substrae_azulejo_fabrica(Fabrica_antes, Idx_azulejo_escogido, Fabrica_despues).

    substrae_azulejo_fabrica(Fabrica_antes, Idx_Azulejo, Fabrica_despues):- 
        borra_lista(Fabrica_antes, Idx_Azulejo, Fabrica_despues).

extrae_todos_azulejos_fabrica(Fabrica, Azulejo_escogido, Fabrica) :-
    not(member(Azulejo_escogido, Fabrica)), !.

extrae_todos_azulejos_fabrica(Fabrica_antes, Azulejo_escogido, Fabrica_despues) :-
    extrae_un_azulejo_fabrica(Fabrica_antes, Azulejo_escogido, Fabrica_despues_temp), !,
    extrae_todos_azulejos_fabrica(Fabrica_despues_temp, Azulejo_escogido, Fabrica_despues).