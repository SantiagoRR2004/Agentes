// Agent bob the watcher in project task1

/* Initial beliefs and rules */

sincere(alice).

/* Initial goals */

/* Plans */

+happy(bob)[source(A)]
    :
        sincere(A)[source(self)]
        &
        .my_name(H)
    <-
        !say(hello(A)).

+happy(H)
    :
        not .my_name(H)
    <-
        !say(i_envy(H)).


+!say(X)
    :
        today(friday)
    <-
        .print(X,"!!!!!");
        .wait(math.random(400)+100);
        !say(X).

+!say(X)
    :
        not today(monday)
    <-
        .print(X);
        .wait(math.random(400)+100);
        !say(X).

+!say(X)
    <- // If the calendar artifact is not working
        !say(X).

