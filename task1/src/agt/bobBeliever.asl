// Agent bob the believer in project task1

/* Initial beliefs and rules */

sincere(alice).

/* Initial goals */

!create_calendar.

/* Plans */

+happy(bob)[source(A)]
    :
        sincere(A)[source(self)]
    <-
        !say(hello(A)).

+!say(X)
    :
        not today(monday)
    <-
        .print(X); 
        .wait(500);
        !say(X).

+!say(X)
    :
        today(monday)
    <-
        .print("I hate mondays!");
        .wait(500);
        !say(X).

+!create_calendar
   <- 
        makeArtifact("c","Calendar",[],AId);
        focus(AId).
