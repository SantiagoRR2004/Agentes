{ include("sweep.asl") }

/* Initial Beliefs */
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

/* Initial goals */

!findDoors.

/* Plans */

+!findDoors
    // Find all the possible doors in the environment
    <-
    .setof(Object, atRoom(Object ,_), Objects);
    for ( .member(O, Objects) ) {
        ?atRoom(O, Room);
        +couldBeDoor(O, Room);
    }.

+at(Me, Object):
	// If it can be at, it is not a door
	// Activate on belief
            .my_name(Me)
        &
            at(Me, Object)
        &
            couldBeDoor(Object, Room)
	<-
		-couldBeDoor(Object, Room);
        .broadcast(untell, couldBeDoor(Object, Room)).


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
            shortestRoomPath(CurrentRoom, ObjectiveRoom, Path, MaxDepth + 1)
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

+!goToRoom(ObjectiveRoom):
    // Could not find a path, find doors
        couldBeDoor(Door, _)
    <-
        !findDoors.

-!goToRoom(ObjectiveRoom)
    // Could not find a path
    <-
        .println("Error in goToRoom.").


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