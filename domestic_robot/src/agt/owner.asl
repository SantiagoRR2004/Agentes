{ include("movement.asl") }

/* Initial Beliefs */
sittable([sofa, chair1, chair2, chair3, chair4]).
sleepOn([bed1, bed2, bed3]).

/* Initial goals */

!main.

/* Plans */

+!main:
	wantToSit(Object)
	<-
	!sitOnObjective;
	!main.

+!main:
	wantToSleep(Object)
	<-
	!sleepOnObjective;
	!main.

+!main
	<-
	!chooseObjective;
	!main.

-!main
	<-
	!main.

+!chooseObjective
	<-
	.random(X);
	// 50% chance to want to sit
	if (X < 0.5) {
		!chooseSittingPlace;
	} else {
		// 50% chance to want to sleep
		!chooseSleepingPlace;
	}.

+!chooseSittingPlace:
		sittable(SittableList)
	<-
		// Randomly choose a sitting place
		.random(R);
		.length(SittableList, Len);
		Index = (R * Len);
		IndexInt = math.floor(Index);
		.nth(IndexInt, SittableList, ChosenPlace);
		.println("Owner wants to sit on ", ChosenPlace);
		+wantToSit(ChosenPlace).


+!chooseSleepingPlace:
		sleepOn(SleepableList)
	<-
		// Randomly choose a sleeping place
		.random(R);
		.length(SleepableList, Len);
		Index = (R * Len);
		IndexInt = math.floor(Index);
		.nth(IndexInt, SleepableList, ChosenPlace);
		.println("Owner wants to sleep on ", ChosenPlace);
		+wantToSleep(ChosenPlace).


+!sitOnObjective:
	// Owner is not where he wants to sit
			wantToSit(ChosenPlace)
		&
			.my_name(Me)
		&
			not at(Me, ChosenPlace)
	<-
		!moveTowardsAdvanced(ChosenPlace).

+!sitOnObjective:
	// Owner is where he wants to sit
			wantToSit(ChosenPlace)
		&
			.my_name(Me)
		&
			at(Me, ChosenPlace)
	<-
		sit(ChosenPlace);
		.random(X);
		// Between 1 and 2 seconds
		.wait(X*1000+1000);
		.random(Y);
		// 10% change to want to do something else
		if (Y < 0.1) {
			-wantToSit(ChosenPlace);
		}.


+!sleepOnObjective:
	// Owner is not where he wants to sleep
			wantToSleep(ChosenPlace)
		&
			.my_name(Me)
		&
			not at(Me, ChosenPlace)
	<-
		!moveTowardsAdvanced(ChosenPlace).

+!sleepOnObjective:
	// Owner is where he wants to sleep
			wantToSleep(ChosenPlace)
		&
			.my_name(Me)
		&
			at(Me, ChosenPlace)
	<-
		sit(ChosenPlace);
		.random(X);
		// Between 2 and 7 seconds
		.wait(X*5000+2000);
		.random(Y);
		// 10% change to want to do something else
		if (Y < 0.1) {
			-wantToSleep(ChosenPlace);
		}.
