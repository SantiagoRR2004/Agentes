// Common functions for the family project

/* Initial beliefs and rules */

parentesco(X,Y)
    :-
        es_padre_de(X,Y).

parentesco(X,Y)
    :-
        es_madre_de(X,Y).

// Relaciones de hermanos

/*

Nota: Según el diccionario consideramos hermanos aquellos que comparten un padre o una madre.

*/

es_hermano_de(X,Y)
    :-
            parentesco(Z,X)
        &
            parentesco(Z,Y)
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
        es_antepasadoDirecto_de(X,Y)
        |
        es_antepasadoIndirecto_de(X,Y).

es_antepasadoDirecto_de(X,Y)
    :-
            parentesco(X,Y)
        |
            (
                    parentesco(X,Z)
                &
                    es_antepasadoDirecto_de(Z,Y)
            ).


es_antepasadoIndirecto_de(X,Y)
    :-
            es_hermano_de(X,Z)
        &
            es_antepasadoDirecto_de(Z,Y).


// Luego reglas para "X es_descendiente_de Y"

es_descendiente_de(X,Y)
    :-
            parentesco(Y,X)
        |
            (
                    parentesco(Y,Z)
                &
                    es_descendiente_de(X,Z)
            ).

// Creamos reglas para primos lejanos

es_primoLejano_de(X,Y)
    :-
            es_antepasadoIndirecto_de(Z,Y)
        &
            es_descendiente_de(X,Z).

// Suegro o yerno

casadoBidireccional(X,Y)
    :-
            casadoCon(X,Y)
        |
            casadoCon(Y,X).

es_suegro_de(X,Y)
    :-
        parentesco(X,Z)
    &
        casadoBidireccional(Z,Y).

es_yerno_de(X,Y)
    :-
        es_suegro_de(Y,X).

// Por ultimo las reglas de parentesco

es_pariente_de(X,Y)
    :-
            (
                es_hermano_de(X,Y)
                |
                es_antepasado_de(X,Y)
                |
                es_descendiente_de(X,Y)
                |
                es_primoLejano_de(X,Y)
            )
        &
            not X=Y.

// El código anterior es básicamente código PROLOG para resolver el problema de parentesco entre familiares


/* Initial goals */


/* Plans */
