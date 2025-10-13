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


+parents_list(Child, ParentList)[source(Sender)]
        <- for(.member(P, ParentList)) {
            .abolish(parentesco(P, Child));
            +parentesco(P, Child);
        }.

+!get_parents(Subject, Requester)[source(Sender)]
    <-
        .findall(P, parentesco(P, Subject), L);
        .send(Requester, tell, parents_list(Subject, L)).

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

+!get_ancestors(Subject, Requester)[source(Sender)]
    <- 
        .findall(P, parentesco(P, Subject), Parents);
        for ( .member(P, Parents)) {
            .send(P, achieve, get_ancestors(P, Requester));
        }
        .send(Requester, tell, parents_list(Subject, Parents)).


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

+!get_cousins(Subject, Requester)[source(Sender)]
:
    not alreadyAsked(Subject, Requester)
    <- 
        +alreadyAsked(Subject, Requester); // to avoid infinite loops
        .findall(P, parentesco(Subject, P), Children);
        for ( .member(P, Children)) {
            .send(P, achieve, get_cousins(P, Requester));
            .send(P, achieve, get_parents(P, Requester));
        };
        .findall(P, parentesco(P, Subject), Parents);
        for ( .member(P, Parents)) {
            .send(P, achieve, get_cousins(P, Requester));
        }
        .send(Requester, tell, parents_list(Subject, Parents)).

+!get_cousins(Subject, Requester)[source(Sender)]
    <-
        true.

// Suegro o yerno

casadoBidireccional(X,Y)
    :-
            casadoCon(X,Y)
        |
            casadoCon(Y,X).

+married_list(User, SpouseList)[source(Sender)]
    <- for(.member(P, SpouseList)) {
        .abolish(casadoCon(User, P));
        +casadoCon(User, P);
    }.


+!get_spouses(Subject, Requester)[source(Sender)]
    <-
        .findall(P, casadoBidireccional(Subject, P), L);
        .send(Requester, tell, married_list(Subject, L)).

es_suegro_de(X,Y)
    :-
        parentesco(X,Z)
    &
        casadoBidireccional(Z,Y).

+!get_suegros(Subject, Requester)[source(Sender)]
    <-
        .findall(P, casadoBidireccional(P, Subject), L);
        for ( .member(P, L)) {
            .send(P, achieve, get_parents(P, Requester));
        }.

es_yerno_de(X,Y)
    :-
        es_suegro_de(Y,X).

+!get_yernos(Subject, Requester)[source(Sender)]
    <-
        .findall(P, parentesco(Subject, P), Children);
        for ( .member(C, Children)) {
            .send(C, achieve, get_spouses(C, Requester));
        }.

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

        // Find ancestors first
        !get_cousins(Me, Me);
        !get_suegros(Me, Me);
        !get_yernos(Me, Me);
        .wait(10000);

        .println("Me llamo: ", Me);

        .setof(X, parentesco(X,Me), L0);
        .print("Mis padres son: ",L0);

        .setof(X, es_hermano_de(X,Me), L1);
        .print("Mis hermanos son: ",L1);

        .setof(X, es_antepasadoDirecto_de(X,Me), L2);
        .print("Mis antepasados directos son: ",L2);

        .setof(X, es_antepasadoIndirecto_de(X,Me), L3);
        .difference(L3, L2, R);
        .print("Mis antepasados indirectos (sin los directos) son: ",R);

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

