// Agent tom in project task2

/* Initial beliefs and rules */

/* Initial goals */

!start.

/* Plans */

+!start : true <- .send(bob,tell,hello).

+hello[source(A)]
     <- .print("Thanks for answering my hello, ",A);
        .send(A, tell, hello).
