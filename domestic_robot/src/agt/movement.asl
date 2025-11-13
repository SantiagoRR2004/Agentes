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

originalPatience(50).
patience(50).

minusOne(X, Y)
	:-
	Y = X - 1.


numberOfDoors(X)
	:-
		.setof(Door, connect(_, _, Door), DoorList)
	&
		.length(DoorList, X).


findPathRoom(Current, Target, _, [], MaxDepth)
    :-
		Current=Target.

findPathRoom(Current, Target, Visited, Path, MaxDepth)
	:-
			connect(Current, NextRoom, Door)
		&
			minusOne(MaxDepth, N1)
		&
			N1 > 0
		&
			not .member(Door, Visited)
		&
			findPathRoom(NextRoom, Target, [Door|Visited], SubPath, N1)
		&
			Path = [Door|SubPath].


shortestRoomPath(Current, Target, Path, MaxDepth)
	:-
			MaxDepth > 0
		&
			(
				(
					minusOne(MaxDepth, N1)
				&
					shortestRoomPath(Current, Target, Path, N1)
				)
			|
				findPathRoom(Current, Target, [], Path, MaxDepth)
			).

/* Plans */

+!moveTowardsAdvanced(Objective):
	// They are in the same Room
            atRoom(CurrentRoom)
		&
            atRoom(Objective, CurrentRoom)
	<-
        move_towards(Objective);
        !reducePatience.

+!moveTowardsAdvanced(Objective):
	// They are not in the same Room
            atRoom(CurrentRoom)
        &
            atRoom(Objective, ObjectiveRoom)
        &
            not ObjectiveRoom = CurrentRoom
	<-
        !goToRoom(ObjectiveRoom);
        !reducePatience.


+!goToRoom(ObjectiveRoom):
            atRoom(CurrentRoom)
        &
            numberOfDoors(MaxDepth)
        &
            shortestRoomPath(CurrentRoom, ObjectiveRoom, Path, MaxDepth)
	<-
        // Move towards the first door in the path
        .nth(0, Path, FirstDoor);
        if (atDoor) {
            +wasAtDoor;
        } else {
            -wasAtDoor;
        };
        move_towards(FirstDoor);
        if (atDoor & wasAtDoor) {
            .println("Stuck in a door.");
            !unstuckFromDoor;
        };
        !reducePatience;
        -wasAtDoor.


+!unstuckFromDoor
	<-
    !moveRandomly;
	// Keep trying
	if (atDoor) {
		!unstuckFromDoor;
	}.

+!moveRandomly
    <-
    .my_name(Me);
    .random(R);
    if (R < 0.25) {
        moveLeft(Me);
    } else {
        if (R < 0.5) {
            moveRight(Me);
        } else {
            if (R < 0.75) {
                moveUp(Me);
            } else {
                moveDown(Me);
            };
        };
    }.


+!moveRandomlyNoExit
    <-
    .my_name(Me);
    .random(R);
    if (R < 0.25) {
        !moveLeftNoExit;
    } else {
        if (R < 0.5) {
            !moveRightNoExit;
        } else {
            if (R < 0.75) {
                !moveUpNoExit;
            } else {
                !moveDownNoExit;
            };
        };
    }.

+!moveDownNoExit:
    // Move down, but do not exit the room
            .my_name(Me)
        &
            atRoom(CurrentRoom)
        &
            height(H)
    <-                  
        moveDown(Me);
        if (not atRoom(CurrentRoom) | atDoor) {
            moveUp(Me);
            -height(H);
            +height(0);
        } else {
            -height(H);
            +height(H-1);
        }.

+!moveDownNoExit:
    // Move down, but do not exit the room
            .my_name(Me)
        &
            atRoom(CurrentRoom)
        &
            not height(H)
    <-
        moveDown(Me);
        if (not atRoom(CurrentRoom) | atDoor) {
            moveUp(Me);
        }.


+!moveUpNoExit:
    // Move up, but do not exit the room
            .my_name(Me)
        &
            atRoom(CurrentRoom)
        &
            height(H)
    <-
        moveUp(Me);
        if (not atRoom(CurrentRoom) | atDoor) {
            moveDown(Me);
            -height(H);
            +height(0);
        } else {
            -height(H);
            +height(H-1);
        }.

+!moveUpNoExit:
    // Move up, but do not exit the room
            .my_name(Me)
        &
            atRoom(CurrentRoom)
        &
            not height(H)
    <-
        moveUp(Me);
        if (not atRoom(CurrentRoom) | atDoor) {
            moveDown(Me);
        }.


+!moveLeftNoExit:
    // Move left, but do not exit the room
            .my_name(Me)
        &
            atRoom(CurrentRoom)
        &
            width(W)
    <-
        moveLeft(Me);
        if (not atRoom(CurrentRoom) | atDoor) {
            moveRight(Me);
            -width(W);
            +width(0);
        } else {
            -width(W);
            +width(W-1);
        }.

+!moveLeftNoExit:
    // Move left, but do not exit the room
            .my_name(Me)
        &
            atRoom(CurrentRoom)
        &
            not width(W)
    <-
        moveLeft(Me);
        if (not atRoom(CurrentRoom) | atDoor) {
            moveRight(Me);
        }.


+!moveRightNoExit:
    // Move right, but do not exit the room
            .my_name(Me)
        &
            atRoom(CurrentRoom)
        &
            width(W)
    <-
        moveRight(Me);
        if (not atRoom(CurrentRoom) | atDoor) {
            moveLeft(Me);
            -width(W);
            +width(0);
        } else {
            -width(W);
            +width(W-1);
        }.

+!moveRightNoExit:
    // Move right, but do not exit the room
            .my_name(Me)
        &
            atRoom(CurrentRoom)
        &
            not width(W)
    <-
        moveRight(Me);
        if (not atRoom(CurrentRoom) | atDoor) {
            moveLeft(Me);
        }.


+patience(0)
    <-
        !moveRandomly;
        .println("Patience exhausted, moving randomly.");
        !resetPatience.

+!reducePatience:
        patience(P)
    <-
        -patience(P);
        +patience(P-1).

+!resetPatience:
        originalPatience(OP)
    <-
        -patience(_);
        +patience(OP).