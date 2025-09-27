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
        for (.range(I,1,100)) {
            .send(bobWatcher, tell, happy(I));
        }.

+!create_calendar
   <- 
        makeArtifact("c","Calendar",[],AId);
        focus(AId).
