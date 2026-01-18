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
			.list(Visited)
		&
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

/* Plans */

+!moveTowardsAdvanced(Objective):
	// They are in the same Room
            atRoom(CurrentRoom)
		&
            atRoom(Objective, CurrentRoom)
	<-
        move_towards(Objective);
        if (batteryLevel(_)) {
            !reduceBattery;
        };
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
        if (batteryLevel(_)) { // if battery is defined
            !reduceBattery;
        };
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
    if (batteryLevel(_)) {
        !reduceBattery;
    };
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
        if (batteryLevel(_)) {
            !reduceBattery;
        };
        if (not atRoom(CurrentRoom) | atDoor) {
            moveUp(Me);
            if (batteryLevel(_)) {
                !reduceBattery;
            };
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
        if (batteryLevel(_)) {
            !reduceBattery;
        };
        if (not atRoom(CurrentRoom) | atDoor) {
            moveUp(Me);
            if (batteryLevel(_)) {
                !reduceBattery;
            };
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
        if (batteryLevel(_)) {
            !reduceBattery;
        };
        if (not atRoom(CurrentRoom) | atDoor) {
            moveDown(Me);
            if (batteryLevel(_)) {
                !reduceBattery;
            };
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
        if (batteryLevel(_)) {
            !reduceBattery;
        };
        if (not atRoom(CurrentRoom) | atDoor) {
            moveDown(Me);
            if (batteryLevel(_)) {
                !reduceBattery;
            };
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
        if (batteryLevel(_)) {
            !reduceBattery;
        };
        if (not atRoom(CurrentRoom) | atDoor) {
            moveRight(Me);
            if (batteryLevel(_)) {
                !reduceBattery;
            };
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
        if (batteryLevel(_)) {
            !reduceBattery;
        };
        if (not atRoom(CurrentRoom) | atDoor) {
            moveRight(Me);
            if (batteryLevel(_)) {
                !reduceBattery;
            };
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
        if (batteryLevel(_)) {
            !reduceBattery;
        };
        if (not atRoom(CurrentRoom) | atDoor) {
            moveLeft(Me);
            if (batteryLevel(_)) {
                !reduceBattery;
            };
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
        if (batteryLevel(_)) {
            !reduceBattery;
        };
        if (not atRoom(CurrentRoom) | atDoor) {
            moveLeft(Me);
            if (batteryLevel(_)) {
                !reduceBattery;
            };
        }.


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