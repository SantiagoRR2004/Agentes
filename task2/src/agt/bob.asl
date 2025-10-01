// Agent bob in project task2

/* Initial beliefs and rules */

/* Initial goals */

/* Plans */

+hello[source(tom)] <- 
	.print("I received a 'hello' from tom");
	.broadcast(tell, hello).

+hello[source(Tom)] <- 
	.print("I dispose a 'hello' from ", Tom);
	.abolish(hello[source(Tom)]);
	.send(Tom, tell, hello);
	.wait(1); // En milisegundos
	.send(Tom, untell, hello).

/*
(a)
Si se mantienen los dos planes +hello significa
que solo se entra en el primer plan y entonces solo
hay un intercambio de mensajes.

Si se comenta el primer plan, entra en el segundo plan
como si fuese una variable y hay un intercambio infinito:
[bob] I dispose a 'hello' from tom
[tom] Thanks for answering my hello, bob
Un problema es que el ordenador empieza a ir lento
tras un rato.

Si se pone con mayúscula el agente de tom, entonces da un error
el fichero .mas2j porque los agentes tienen que empezar por minúscula.
tOm es un agente válido, Tom no lo es.

jason.mas2j.parser.ParseException: Encountered " <ID> "Tom "" at line 19, column 9.
Was expecting one of:
    "classpath" ...
    "aslSourcePath" ...
    "directives" ...
    <ASID> ...
    "}" ...
*/

/*
(b)
Con un nuevo agente john, tom sigue con dos mensajes y john
con los mensajes infinitos.
*/

/*
(c)
Añadiendo el wait(1) solo cambia el comportamiento con john,
no se envía un mensaje cada milisegundo, solo se intercambian
uno o dos mensajes.

[bob] I dispose a 'hello' from john
[bob] I received a 'hello' from tom
[john] Thanks for answering my hello, bob
[tom] Thanks for answering my hello, bob
[bob] I dispose a 'hello' from john
[bob] I received a 'hello' from tom
*/

