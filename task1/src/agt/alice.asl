// Agent alice in project task1

/* Initial beliefs and rules */

/* Initial goals */

!create_calendar.
!startBeliever.
!startWatcher.
!startRevisionist.
!startLazy.

/* Plans */

+!create_calendar
   <- 
        makeArtifact("c","Calendar",[],AId);
        focus(AId).

+!startBeliever
    <-
        .send(bobBeliever, tell, happy(bob)).

+!startWatcher
    <-
        .send(bobWatcher, tell, happy(bob));
        .send(bobWatcher, tell, happy(alice));
        .wait(2000);
        .send(bobWatcher, tell, happy(morgana));
        for (.range(I,1,100)) {
            .send(bobWatcher, tell, happy(I));
        }.

+!startRevisionist
    <-
        .send(bobRevisionist,tell,happy(bob));
        .send(bobRevisionist,tell,happy(alice));    .wait(2000);
        .send(bobRevisionist,tell,happy(morgana));  .wait(2000);
        .send(bobRevisionist,untell,happy(bob));    .wait(1000); 
        .send(bobRevisionist,untell,happy(alice)).

+!startLazy
    <-
        .send(bobLazy,tell,happy(bob));
        .send(bobLazy,tell,happy(alice));    .wait(2000);
        .send(bobLazy,tell,happy(morgana));  .wait(2000);
        .send(bobLazy,untell,happy(bob));    .wait(1000); 
        .send(bobLazy,untell,happy(alice)).

