// Agent bob the believer in project task1

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

-happy(H)[source(A)]
    <- 
        .drop_intention(say(hello(A)));
        .drop_intention(say(i_envy(H))).


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
    <-
        !say(X).


+!enter_lazy_mode
    : .findall(A, .intend(say(A)), [_,_|L]) // the agent has at most two active "say" intentions
   <- for ( .member(I,L) ) {                // the agent suspend the rest of active "say" intentions
         .suspend(say(I));
      }.
+!enter_lazy_mode.

+!resume_all
    : .count( .intend(A) & .suspended(A,R) & .substring("suspended",R), I) & I > 0
   <- .resume(say(_));
      !resume_all.
+!resume_all.
