{ include("movement.asl") }

/* Initial Beliefs */


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


+!goToRoom(ObjectiveRoom):
    // Could not find a path, find doors
            couldBeDoor(Door, _)
        &
            atRoom(CurrentRoom)
        &
            numberOfDoors(MaxDepth)
        &
            not shortestRoomPath(CurrentRoom, ObjectiveRoom, Path, MaxDepth + 1)
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
    // TODO Maybe do a sweep instead of hallway
            not currentlyDooring(_)
        &
            atRoom(CurrentRoom)
        &
            couldBeDoor(Object, Room)
        &
            numberOfDoors(MaxDepth)
        &
            not findPathRoom(CurrentRoom, Room, _2, Path, MaxDepth + 2)
    <-
        if (not atRoom(hallway)) {
            !goToRoom(hallway);
        } else {
            move_towards(Object);
            if (atDoor) {
                !findConnection(Object);
            };
        }.

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
                +roomDoorDirection(Room1, Door, down);
                .broadcast(tell, roomDoorDirection(Room1, Door, down));
                +roomDoorDirection(Room2, Door, up);
                .broadcast(tell, roomDoorDirection(Room2, Door, up));
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
            ?atRoom(Room3);
            if (not Room1 = Room3) {
                !addConnection(Room1, Room3, Door);
                +roomDoorDirection(Room1, Door, right);
                .broadcast(tell, roomDoorDirection(Room1, Door, right));
                +roomDoorDirection(Room3, Door, left);
                .broadcast(tell, roomDoorDirection(Room3, Door, left));
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
            ?atRoom(Room4);
            if (not Room1 = Room4) {
                !addConnection(Room1, Room4, Door);
                +roomDoorDirection(Room1, Door, up);
                .broadcast(tell, roomDoorDirection(Room1, Door, up));
                +roomDoorDirection(Room4, Door, down);
                .broadcast(tell, roomDoorDirection(Room4, Door, down));
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
            ?atRoom(Room5);
            if (not Room1 = Room5) {
                !addConnection(Room1, Room5, Door);
                +roomDoorDirection(Room1, Door, left);
                .broadcast(tell, roomDoorDirection(Room1, Door, left));
                +roomDoorDirection(Room5, Door, right);
                .broadcast(tell, roomDoorDirection(Room5, Door, right));
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


+!addConnectionBroad(Room1, Room2, Door)[source(Sender)]
    <-
        +connect(Room1, Room2, Door);
        +connect(Room2, Room1, Door);
        -couldBeDoor(Door, Room1);
        -couldBeDoor(Door, Room2);
        .println("Added connection: ", Room1, " <-> ", Room2, " via ", Door, " from ", Sender, ".").

+!addConnection(Room1, Room2, Door)
    <-
        .broadcast(achieve, addConnectionBroad(Room1, Room2, Door));
        !addConnectionBroad(Room1, Room2, Door).
