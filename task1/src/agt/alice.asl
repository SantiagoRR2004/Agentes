// Agent alice in project task1

/* Initial beliefs and rules */

/* Initial goals */

!start.
!create_calendar.

/* Plans */

+!start
    <-
        .send(bobBeliever, tell, happy(bob));
        .send(bobWatcher, tell, happy(bob));
        .send(bobWatcher, tell, happy(alice));
        .wait(2000);
        .send(bobWatcher, tell, happy(morgana));
        .send(bobRevisionist,tell,happy(bob));
        .send(bobRevisionist,tell,happy(alice));    .wait(2000);
        .send(bobRevisionist,tell,happy(morgana));  .wait(2000);
        .send(bobRevisionist,untell,happy(bob));    .wait(1000); 
        .send(bobRevisionist,untell,happy(alice));
        for (.range(I,1,100)) {
            .send(bobWatcher, tell, happy(I));
        }.

+!create_calendar
   <- 
        makeArtifact("c","Calendar",[],AId);
        focus(AId).
