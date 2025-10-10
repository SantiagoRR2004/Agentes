// Common functions for the family project

/* Initial beliefs and rules */


// Relaciones de hermanos

/*

Nota: Según el diccionario consideramos hermanos aquellos que comparten un padre o una madre.

*/

//Primero suponemos que comparten solo padre y no son la misma persona

es_hermano_de(X,Y)
    :-
            es_padre_de(Z,X)
        &
            es_padre_de(Z,Y)
        &
            es_madre_de(W,X)
        &
            not es_madre_de(W,Y)
        &
            not X=Y.

//Segundo suponemos que comparten solo madre y no son la misma persona

es_hermano_de(X,Y)
    :-
        es_madre_de(Z,X)
    &
        es_madre_de(Z,Y)
    &
        es_padre_de(W,X)
    &
        not es_padre_de(W,Y)
    &
        not X=Y.

//Tercero suponemos que comparten padre y madre y no son la misma persona

es_hermano_de(X,Y)
    :-
        es_padre_de(Z,X)
    &
        es_padre_de(Z,Y)
    &
        es_madre_de(W,X)
    &
        es_madre_de(W,Y)
    &
        not X=Y.

/*

NOTA: Fijaros que el hecho de que tengan padre o madre distinta incluye 

las situaciones de padres divorciados o de horfandad 

*/

// RELACIONES DE PARENTESCO

// Primero reglas para "X es_antepasado_de Y"

es_antepasado_de(X,Y)
    :-
        es_antepasadoDirecto_de(X,Y).

es_antepasado_de(X,Y)
    :-
        es_antepasadoIndirecto_de(X,Y).

es_antepasadoDirecto_de(X,Y)
    :-
        es_padre_de(X,Y).

es_antepasadoDirecto_de(X,Y)
    :-
        es_madre_de(X,Y).

es_antepasadoDirecto_de(X,Y)
    :-
            es_padre_de(X,Z)
        &
            es_antepasadoDirecto_de(Z,Y).

es_antepasadoDirecto_de(X,Y)
    :-
            es_madre_de(X,Z)
        &
            es_antepasadoDirecto_de(Z,Y).

es_antepasadoIndirecto_de(X,Y)
    :-
            es_hermano_de(X,Z)
        &
            es_antepasadoDirecto_de(Z,Y).


// Luego reglas para "X es_descendiente_de Y"

es_descendiente_de(X,Y)
    :-
        es_padre_de(Y,X).

es_descendiente_de(X,Y)
    :-
        es_madre_de(Y,X).

es_descendiente_de(X,Y)
    :-
        es_padre_de(Y,Z)
    &
        es_descendiente_de(X,Z).

es_descendiente_de(X,Y)
    :-
            es_madre_de(Y,Z)
        &
            es_descendiente_de(X,Z).


// Creamos reglas para primos lejanos

es_primoLejano_de(X,Y)
    :-
            es_antepasadoIndirecto_de(Z,Y)
        &
            es_descendiente_de(X,Z).

// Por ultimo las reglas de parentesco

es_pariente_de(X,Y)
    :-
            es_hermano_de(X,Y)
        &
            not X=Y.

es_pariente_de(X,Y)
    :-
            es_antepasado_de(X,Y)
        &
            not X=Y.

es_pariente_de(X,Y)
    :-
            es_descendiente_de(X,Y)
        &
            not X=Y.

es_pariente_de(X,Y)
    :-
        es_primoLejano_de(X,Y).

// El código anterior es básicamente código PROLOG para resolver el problema de parentesco entre familiares


/* Initial goals */


/* Plans */
