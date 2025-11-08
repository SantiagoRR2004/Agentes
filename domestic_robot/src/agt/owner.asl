{ include("movement.asl") }

/* Initial Beliefs */
sittable([sofa, chair1, chair2, chair3, chair4]).

/* Initial goals */

!main.

/* Plans */

+!main:
	wantToSit(Object)
	<-
	!sitOnObjective;
	!main.

+!main
	<-
	!chooseObjective;
	!main.

-!main
	<-
	!main.


+!chooseObjective:
	sittable(SittableList)
	<-
	// Randomly choose a sitting place
	.random(R);
	.length(SittableList, Len);
	Index = (R * Len);
	IndexInt = math.floor(Index);
	.nth(IndexInt, SittableList, ChosenPlace);
	+wantToSit(ChosenPlace).
	  

+!sitOnObjective:
		wantToSit(ChosenPlace)
		&
		not at(ChosenPlace)
	<-
	.println("Owner moving towards ", ChosenPlace);
	// .wait(1000);
	!moveTowardsAdvanced(ChosenPlace).
	// -wantToSit(ChosenPlace).

