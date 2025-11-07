/* Initial Beliefs */
connect(kitchen, hall, doorKit1).
connect(kitchen, hallway, doorKit2).
connect(hall, kitchen, doorKit1).
connect(hallway, kitchen, doorKit2).
connect(bath1, hallway, doorBath1).
connect(bath2, bedroom1, doorBath2).
connect(hallway, bath1, doorBath1).
connect(bedroom1, bath2, doorBath2).
connect(bedroom1, hallway, doorBed1).
connect(hallway, bedroom1, doorBed1).
connect(bedroom2, hallway, doorBed2).
connect(hallway, bedroom2, doorBed2).
connect(bedroom3, hallway, doorBed3).
connect(hallway, bedroom3, doorBed3).
connect(hall,livingroom, doorSal1).                       
connect(livingroom, hall, doorSal1).
connect(hallway,livingroom, doorSal2).
connect(livingroom, hallway, doorSal2).

sittable([sofa, chair1, chair2, chair3, chair4]).


findPath(Current, Target, _, [])
    :-
		Current=Target.

findPath(Current, Target, Visited, Path)
	:-
			connect(Current, NextRoom, Door)
		&
			not .member(Door, Visited)
		&
			findPath(NextRoom, Target, [Door|Visited], SubPath)
		&
			Path = [Door|SubPath].

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


+!moveTowardsAdvanced(Objective):
	// Check if they are in the same Room
		atRoom(CurrentRoom)
		&
		atRoom(Objective, CurrentRoom)
	<-
	.println("They are on the same room");
	move_towards(Objective).

+!moveTowardsAdvanced(Objective):
	// They are not in the same Room
	atRoom(CurrentRoom)
	&
	atRoom(Objective, ObjectiveRoom)
	&
	not ObjectiveRoom = CurrentRoom
	<-
	.println("They are in different rooms");
	!goToRoom(ObjectiveRoom).


+!goToRoom(ObjectiveRoom):
	atRoom(CurrentRoom)
	&
	findPath(CurrentRoom, ObjectiveRoom, [], Path)
	<-
	.println("Going to room: ", ObjectiveRoom);
	// Move towards the first door in the path
	.nth(0, Path, FirstDoor);
	move_towards(FirstDoor).
