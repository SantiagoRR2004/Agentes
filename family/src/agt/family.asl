// Common functions for the family project

/* Initial beliefs and rules */

parentesco(X,Y)
    :-
        es_padre_de(X,Y)
        &
        not X=Y.

parentesco(X,Y)
    :-
        es_madre_de(X,Y)
        &
        not X=Y.

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


+!presentation
    <-
        .my_name(Me);
        .println("Me llamo: ", Me);

        .setof(X, parentesco(X,Me), L0);
        .print("Mis parientes son: ",L0);

        .setof(X, es_hermano_de(X,Me), L1);
        .print("Mis hermanos son: ",L1);

        .setof(X, es_antepasadoDirecto_de(X,Me), L2);
        .print("Mis antepasados directos son: ",L2);

        .setof(X, es_antepasadoIndirecto_de(X,Me), L3);
        .print("Mis antepasados indirectos son: ",L3);

        .setof(X, es_descendiente_de(X,Me), L4);
        .print("Mis descendientes son: ",L4);

        .setof(X, es_primoLejano_de(X,Me), L5);
        .print("Mis primos lejanos son: ",L5);

        .setof(X, divorciados(Me,X), L6);
        .print("Mis divorcios son: ",L6);

        .setof(X, casadoCon(Me,X), L7);
        .print("Mis matrimonios son: ",L7);

        .setof(X, es_suegro_de(X,Me), L8);
        .print("Mis relaciones de suegro son: ",L8);

        .setof(X, es_yerno_de(X,Me), L9);
        .print("Mis relaciones de yerno son: ",L9).

