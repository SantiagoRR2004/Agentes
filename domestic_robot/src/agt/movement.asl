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

!findPossibleDoors.

/* Plans */

+!findPossibleDoors
    // Find all the possible doors in the environment
    <-
    .setof(Object, atRoom(Object ,_), Objects);
    for ( .member(O, Objects) ) {
        ?atRoom(O, Room);
        .term2string(O, OStr);
        // TODO move_towards(doorHome)
        if (.substring("door", OStr, 0) & not "doorHome"=OStr) {
            .println(O, " could be a door in ", Room);
            +couldBeDoor(O, Room);
        };
    };
    .my_name(Me);
    ?atRoom(Room);
    .broadcast(achieve, removeDoorPossibility(Me, Room)).

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
        .println(Object, " couldn't be a door.");
        .broadcast(achieve, removeDoorPossibility(Object, Room)).


+!removeDoorPossibility(Object, Room)[source(Sender)]
    <-
        .println("Removing door possibility for ", Object, " in ", Room, " from ", Sender);
        -couldBeDoor(Object, Room).


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
        if (batteryLevel(_)) {
            !reduceBattery;
        };
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


+!findDoors:
    // Searching for a door that can't be
            currentlyDooring(Object)
        &
            not couldBeDoor(Object, Room)
    <-
        -currentlyDooring(Object).

+!findDoors:
    // Find a possible door
            not currentlyDooring(_)
        &
            atRoom(CurrentRoom)
        &
            couldBeDoor(Object, Room)
        &
            numberOfDoors(MaxDepth)
        &
            findPathRoom(CurrentRoom, Room, _2, Path, MaxDepth + 2)
    <-
        .println("Search if ", Object, " is a door.");
        +currentlyDooring(Object).

+!findDoors:
    // Search if there is another object in the room
            atDoor
        &
            atRoom(Room)
        &
            currentlyDooring(Object)
        &
            .setof(Object2, couldBeDoor(Object2, Room), Objects)
        &
            .length(Objects, Len)
        &
            Len > 1
    <-
        -currentlyDooring(Object);
        ?(.member(Object2, Objects) & not Object2 = Object);
        .println("Changing to ", Object2);
        +currentlyDooring(Object2);
        !moveTowardsAdvanced(Object2).

+!findDoors:
    // There is no other object except a door
            atDoor
        &
            atRoom(Room)
        &
            currentlyDooring(Object)
        &
            .setof(Object2, couldBeDoor(Object2, Room), Objects)
        &
            .length(Objects, Len)
        &
            Len = 1
    <-
        !findConnection(Object);
        -currentlyDooring(Object).

+!findDoors:
    // Searching for a door and it can still be
            currentlyDooring(Object)
        &
            couldBeDoor(Object, Room)
    <-
        !moveTowardsAdvanced(Object).


+!findConnection(Door):
    // Try to find a connection for the door
            atRoom(Room1)
        &
            couldBeDoor(Door, Room1)
    <-
        moveUp;
        if (batteryLevel(_)) {
            !reduceBattery;
        };
        if (not atDoor) {
            ?atRoom(Room2);
            if (not Room1 = Room2) {
                !addConnection(Room1, Room2, Door);
            } else {
                moveDown;
                if (batteryLevel(_)) {
                    !reduceBattery;
                };
            };
        };
        // Check that it returned to the door
        ?atDoor;
        moveLeft;
        if (batteryLevel(_)) {
            !reduceBattery;
        };
        if (not atDoor) {
            ?atRoom(Room2);
            if (not Room1 = Room2) {
                !addConnection(Room1, Room2, Door);
            } else {
                moveRight;
                if (batteryLevel(_)) {
                    !reduceBattery;
                };
            };
        };
        // Check that it returned to the door
        ?atDoor;
        moveDown;
        if (batteryLevel(_)) {
            !reduceBattery;
        };
        if (not atDoor) {
            ?atRoom(Room2);
            if (not Room1 = Room2) {
                !addConnection(Room1, Room2, Door);
            } else {
                moveUp;
                if (batteryLevel(_)) {
                    !reduceBattery;
                };
            };
        };
        // Check that it returned to the door
        ?atDoor;
        moveRight;
        if (batteryLevel(_)) {
            !reduceBattery;
        };
        if (not atDoor) {
            ?atRoom(Room2);
            if (not Room1 = Room2) {
                !addConnection(Room1, Room2, Door);
            } else {
                moveLeft;
                if (batteryLevel(_)) {
                    !reduceBattery;
                };
            };
        };
        // Check that it returned to the door
        ?atDoor.

-!findConnection(Door)
    // Could not find a connection
    <-
        // TODO the front door of the class
        ?true.


+!addConnection(Room1, Room2, Door)
    <-
        +connect(Room1, Room2, Door);
        +connect(Room2, Room1, Door);
        // Send the belief to all other agents
        .broadcast(tell, connect(Room1, Room2, Door));
        .broadcast(tell, connect(Room2, Room1, Door));
        .println("Added connection: ", Room1, " <-> ", Room2, " via ", Door).

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