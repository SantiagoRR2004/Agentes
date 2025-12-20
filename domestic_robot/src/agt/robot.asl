{ include("movement.asl") }

/* Initial beliefs and rules */

originalOwnerLimit(5).
ownerLimit(5).

maxBattery(400).
batteryLevel(400).

/* GOALS*/
!main.

/* Plans */

+at(Me, dirty):
	// Clean if dirty
	// Activate on belief
		.my_name(Me)
	<-
		!reduceBattery;
		clean(robot).

+at(Me, intruder):
	// Detect intruder
	// Activate on belief
		.my_name(Me)
	<-
		// Robot can't trigger the alert itself
		.println("INTRUDER ALERT! A RED SPY IS IN THE BASE!");
		.send(owner, tell, intruderDetected).

+at(Me, charger):
	// Recharge battery at charger
	// Activate on belief
		.my_name(Me)
	<-
		!resetBattery;
		.println("Battery recharged.").


+!main:
	// If battery depleted, it stops functioning
			batteryLevel(X)
		&
			X <= 0
	<-
		.println("Battery depleted.");
		wait(5);
		!main.

+!main:
	// Normal operation loop
		not batteryLevel(0)
	<-
		!cleaningLoop;
		!evadeOwner;
		!main.

-!main
	<-
		!main.


+!cleaningLoop:
	// If there is a dirty room, choose one to clean
			dirty(Room)
		&
			not currentlyCleaning(Room2)
	<-
		!chooseRoomToClean.

+!cleaningLoop:
	// If currently cleaning a room, go to it and clean
		currentlyCleaning(Room)
	<-
		!cleanRoom(Room).

+!cleaningLoop:
	// No dirty rooms, go to the charge station
		not dirty(Room)
	<-
		!goToCharger.


+!evadeOwner:
	// Count how many times near owner
			.my_name(Me)
		&
			at(Me, owner)
		&
			not ownerLimit(0)
		&
			ownerLimit(Limit)
	<-
		-ownerLimit(Limit);
		+ownerLimit(Limit-1).

+!evadeOwner:
	// Evade owner when limit reached
			.my_name(Me)
		&
			at(Me, owner)
		&
			ownerLimit(0)
	<-
		.println("Sorry owner, I will get out of your way.");
		!moveRandomly;
		!reduceBattery.

+!evadeOwner:
	// Reset owner limit when far from owner
			.my_name(Me)
		&
			not at(Me, owner)
		&
			originalOwnerLimit(OriginalOwnerLimit)
		&
			not ownerLimit(OriginalOwnerLimit)
	<-
		-ownerLimit(_);
		+ownerLimit(OriginalOwnerLimit).

+!evadeOwner
	// Default plan - do nothing when no evasion is needed
	<-
		?true.


+!chooseRoomToClean:
	// Choose the closest dirty room
	// The hallway is only chosen if there are no other options
			atRoom(CurrentRoom)
		&
            numberOfDoors(MaxDepth)
		&
			not currentlyCleaning(Room)
	<-
		.setof(X, dirty(X), Rooms);
		.shuffle(Rooms, ShuffledRooms);

		-bestRoom(_,_);
		+bestRoom(nil, MaxDepth+1);

		for ( .member(Room, ShuffledRooms) ) {
			if (shortestRoomPath(CurrentRoom, Room, Path, MaxDepth + 1)) {
				.length(Path, PathLength);

				?bestRoom(CurrentBest, BestLen);

				if ((PathLength < BestLen | CurrentBest = hallway) & (not Room =hallway | CurrentBest = nil)) {
					-bestRoom(_,_);
					+bestRoom(Room, PathLength);
				};
			};
		};

		?bestRoom(Room, _);
		if (Room = nil) {
			// TODO
			?not Room = nil;
			?false;
		};
		.println("Chosen room to clean: ", Room);
		!resetPatience;
		+currentlyCleaning(Room).

-!chooseRoomToClean:
	// Could not find a path, find doors
		couldBeDoor(Door, _)
	<-
		!findDoors.

-!chooseRoomToClean
	// Could not find a path
	<-
		.println("Error in chooseRoomToClean.").

+!cleanRoom(Room):
	// If the room is not dirty, stop cleaning
		not dirty(Room)
	<-
		-currentlyCleaning(Room);
		!resetSweep.


+!cleanRoom(Room):
	// Go to the dirty room if not there
			dirty(Room)
		&
			not atRoom(Room)
	<-
		!goToRoom(Room).

+!cleanRoom(Room):
	// Clean the room
			dirty(Room)
		&
			atRoom(Room)
	<-
		!sweepRoom(Room).


+!goToCharger:
	// Move towards the charger
			.my_name(Me)
		&
			not at(Me, charger)
	<-
		moveTowardsAdvanced(charger);
		!reducePatience.

+!goToCharger:
	// Already at the charger
			.my_name(Me)
		&
			at(Me, charger)
	<-
		// Empty plan
		?true.

+!reduceBattery:
        batteryLevel(B)
    <-
        -batteryLevel(B);
        +batteryLevel(B-1).

+!resetBattery:
        originalBatteryLevel(OBL)
    <-
        -batteryLevel(_);
        +batteryLevel(OBL).
