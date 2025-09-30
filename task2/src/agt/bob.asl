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
	//.wait(1);
	.send(Tom, untell, hello).

/*
(a)
Si se mantienen los dos planes +hello significa
que solo se entra en el primer plan y entonces solo
hay un intercambio de mensajes.
*/