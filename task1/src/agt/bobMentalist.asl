// Agent bob the mentalist in project task1

/* Initial beliefs and rules */

happy(bob).

/* Initial goals */

!say(hello).

/* Plans */

+!say(X) : happy(bob) <- .print(X).
