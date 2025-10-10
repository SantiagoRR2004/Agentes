// Agent tom in project family

{ include("family.asl") }

// Este es un ejemplo de agente con personalidad multiple ya que su comportamiento

// Está pensado para que mude de personalidad en base a la respuesta y a la semilla inicial

/* Initial beliefs and rules */

// The main program

yo(tom).

/*
           john --- ann       bob --- sally
                 |                 |
  |--------------|                 |
  |              |                 |
karl           fred ------------- liz
  |                       |
  |              | --------------- |
  |              |                 |
nico     july - erik              tom
              |
              |
              |
             eve
*/

// Relaciones paternales

es_padre_de(fred,erik).

es_padre_de(fred,tom).

es_padre_de(erik,eve).

es_padre_de(bob,liz).

es_padre_de(john,fred).

es_padre_de(john,karl).

es_padre_de(karl,nico).

// Relaciones maternales 

es_madre_de(liz,erik).

es_madre_de(liz,tom).

es_madre_de(sally,liz).

es_madre_de(ann,fred).

es_madre_de(ann,karl).

es_madre_de(july,eve).

// matrimonios y divorcios
casadoCon(john,ann).
casadoCon(bob,sally).
casadoCon(fred,liz).
divorciados(july,erik).
divorciados(nico,eve).


/* Initial goals */

// Este agente tiene un único objetivo => similar a un main

!start. 

/* Plans for events and intentions */

// A continuación se codifican los planes que satisfacen el objetivo planeado

// El plan introduce un subobjetivo que consiste en realizar un saludo

+!start <- 
    !greet;
    +yo(nico);
    !greet;
    !showLists;
    !exit.


+!greet : yo(Me) <-

 .println("Me llamo: ", Me);

 .setof(Y, es_pariente_de(Y,Me), L);

 .print("Mis parientes son: ",L).

 +!showLists
    <-
        .setof([X,Y], casadoCon(X,Y), L1);
        .print("Parejas casadas: ",L1);

        .setof([X,Y], divorciados(X,Y), L2);
        .print("Parejas divorciadas: ",L2);

        .setof([X,Y], es_suegro_de(X,Y), L3);
        .print("Relaciones de suegro: ",L3);

        .setof([X,Y], es_yerno_de(X,Y), L4);
        .print("Relaciones de yerno: ",L4).

// Regla final

+!exit <- .print("Y este cuento se acabo......").

