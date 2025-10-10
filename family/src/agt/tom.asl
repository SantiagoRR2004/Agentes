// Agent tom in project family

// Este es un ejemplo de agente con personalidad multiple ya que su comportamiento

// Está pensado para que mude de personalidad en base a la respuesta y a la semilla inicial

/* Initial beliefs and rules */

// The main program

yo(tom).         

tab("     "). 

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

// Relaciones de hermanos

/*

Nota: Según el diccionario consideramos hermanos aquellos que comparten un padre o una madre.

*/

//Primero suponemos que comparten solo padre y no son la misma persona

es_hermano_de(X,Y) :-

 es_padre_de(Z,X)

 & es_padre_de(Z,Y)

 & es_madre_de(W,X)

 & not es_madre_de(W,Y)

 & not X=Y.

//Segundo suponemos que comparten solo madre y no son la misma persona

es_hermano_de(X,Y) :-

 es_madre_de(Z,X)

 & es_madre_de(Z,Y)

 & es_padre_de(W,X)

 & not es_padre_de(W,Y)

 & not X=Y.

//Tercero suponemos que comparten padre y madre y no son la misma persona

es_hermano_de(X,Y) :- 

 es_padre_de(Z,X)

 & es_padre_de(Z,Y)

 & es_madre_de(W,X)

 & es_madre_de(W,Y)

 & not X=Y.

/*

NOTA: Fijaros que el hecho de que tengan padre o madre distinta incluye 

las situaciones de padres divorciados o de horfandad 

*/

// RELACIONES DE PARENTESCO

// Primero reglas para "X es_antepasado_de Y"

es_antepasado_de(X,Y) :- 

 es_antepasadoDirecto_de(X,Y).

es_antepasado_de(X,Y) :- 

 es_antepasadoIndirecto_de(X,Y).



es_antepasadoDirecto_de(X,Y) :- 

 es_padre_de(X,Y).

es_antepasadoDirecto_de(X,Y) :- 

 es_madre_de(X,Y).

es_antepasadoDirecto_de(X,Y) :- 

 es_padre_de(X,Z)

 & es_antepasadoDirecto_de(Z,Y). 

es_antepasadoDirecto_de(X,Y) :- 

 es_madre_de(X,Z)

 & es_antepasadoDirecto_de(Z,Y).



es_antepasadoIndirecto_de(X,Y) :- 

 es_hermano_de(X,Z)

 & es_antepasadoDirecto_de(Z,Y).

 

// Luego reglas para "X es_descendiente_de Y"

es_descendiente_de(X,Y) :- 

 es_padre_de(Y,X).

es_descendiente_de(X,Y) :- 

 es_madre_de(Y,X).

es_descendiente_de(X,Y) :- 

 es_padre_de(Y,Z)

 & es_descendiente_de(X,Z).

es_descendiente_de(X,Y) :- 

 es_madre_de(Y,Z)

 & es_descendiente_de(X,Z).



// Creamos reglas para primos lejanos

es_primoLejano_de(X,Y) :-

 es_antepasadoIndirecto_de(Z,Y)

 & es_descendiente_de(X,Z).

 

// Por ultimo las reglas de parentesco

es_pariente_de(X,Y) :-

 es_hermano_de(X,Y)

 & not X=Y.

es_pariente_de(X,Y) :-

 es_antepasado_de(X,Y)

 & not X=Y.

es_pariente_de(X,Y) :-

 es_descendiente_de(X,Y)

 & not X=Y.

es_pariente_de(X,Y) :-

 es_primoLejano_de(X,Y).

// El código anterior es básicamente código PROLOG para resolver el problema de parentesco entre familiares



/* Initial goals */

// Este agente tiene un único objetivo => similar a un main

!start. 

/* Plans for events and intentions */

// A continuación se codifican los planes que satisfacen el objetivo planeado

// El plan introduce un subobjetivo que consiste en realizar un saludo

+!start <- !greet.



// Se planifica la manera de satisfacer el objetivo de saludar en función de la identidad del agente y del estado de ánimo

+!greet : yo(Me) & state(happy) <-

 .println("Hola hoy me encuentro feliz de la vida,");

 .println("y quiero compartir muchas cosas con vosotros. ");

 .println("Me llamo: ", Me);

 .findall(Y, es_pariente_de(Y,Me), L); // Busca todos los parientes de Me

 .print("Mis parientes son: ",L);

 if (es_madre_de(Z,Me))

 {.print("Mi madre es : ",Z)} else

 {.print("No tengo madre.")};

 .abolish(state(_)); // Se elimina la creencia sobre el estado de ánimo

 +state(ungry); // Se añade un nuevo estado de ánimo

 !greet. // Repetimos el saludo



+!greet : yo(Me) & state(unhappy) <-

 .println("Hola soy ", Me, " y estoy triste.");

 .abolish(state(_));

 +state(happy);

 .abolish(yo(_)); // Eliminamos la personalidad/identidad del agente

 +yo(nico); // Creamos una nueva identidad

 !greet. // Repetimos el saludo



+!greet : yo(Me) & not state(_) <-

 .println("Hola estoy un poco desorientado, creo que me llamo ", Me);

 +state(unhappy); // Añadimos un estado de ánimo infeliz

 !greet. // Volvemos a saludar



// Regla para cuando todas las condiciones anteriores fallen

-!greet <- .print("Y este cuento se acabo......").

