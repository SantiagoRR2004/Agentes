{ include("movement.asl") }

/* Initial beliefs and rules */

originalHeight(6).
originalWidth(16).

originalOwnerLimit(5).
ownerLimit(5).

/* GOALS*/
!main.

/* Plans */

+at(Me, dirty):
	// Clean if dirty
	// Activate on belief
		.my_name(Me)
	<-
		clean(robot).

+at(Me, intruder):
	// Detect intruder
	// Activate on belief
		.my_name(Me)
	<-
		alert("INTRUDER ALERT! A RED SPY IS IN THE BASE!");
		.send(owner, tell, intruderDetected).

+!main:
	// If there is a dirty room, choose one to clean
			dirty(Room)
		&
			not currentlyCleaning(Room2)
	<-
		!chooseRoomToClean;
		!evadeOwner.

+!main:
	// If currently cleaning a room, go to it and clean
		currentlyCleaning(Room)
	<-
		!cleanRoom(Room);
		!evadeOwner.

+!main:
	// No dirty rooms, go to the charge station
		not dirty(Room)
	<-
		!goToCharger;
		!evadeOwner.

-!main
	<-
		!evadeOwner.

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
		+ownerLimit(Limit-1);
		!main.


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
		!main.

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
		+ownerLimit(OriginalOwnerLimit);
		!main.

+!evadeOwner
	<-
		!main.


+!chooseRoomToClean:
	// Choose the closest dirty room
	// The hallway is only chosen if there are no other options
			atRoom(CurrentRoom)
		&
            numberOfDoors(MaxDepth)
	<-
		.setof(X, dirty(X), Rooms);
		.shuffle(Rooms, ShuffledRooms);

		-bestRoom(_,_);
		+bestRoom(nil, MaxDepth+1);

		for ( .member(Room, ShuffledRooms) ) {
			?shortestRoomPath(CurrentRoom, Room, Path, MaxDepth);
			.length(Path, PathLength);

			?bestRoom(CurrentBest, BestLen);

			if ((PathLength < BestLen | CurrentBest = hallway) & (not Room =hallway | CurrentBest = nil)) {
				-bestRoom(_,_);
				+bestRoom(Room, PathLength);
			};
		};

		?bestRoom(Room, _);
		.println("Chosen room to clean: ", Room);
		!resetPatience;
		+currentlyCleaning(Room).


+!cleanRoom(Room):
	// If the room is not dirty, stop cleaning
		not dirty(Room)
	<-
		!resetCleaning.

+!resetCleaning
	<-
		-currentlyCleaning(Room);
		-bottomReached;
		-leftReached;
		-height(X);
		-width(Y);
		-movingUp;
		-movingDown;
		-movingRight;
		-movingLeft;
		-verticalSweepA;
		-horizontalSweepA;
		-verticalSweepB;
		-horizontalSweepB.

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


+!sweepRoom(Room):
	// Start going down
			atRoom(Room)
		&
		    dirty(Room)
		&
			originalHeight(Height)
		&
			not bottomReached
		&
			not height(X)
	<-
	!moveUpNoExit;
	+height(Height).

+!sweepRoom(Room):
	// Go down until bottom reached
			atRoom(Room)
		&
		    dirty(Room)
		&
			not bottomReached
		&
			height(X)
		&
			originalHeight(H)
	<-
		!moveDownNoExit;
		if (height(0)) {
			+bottomReached;
			-height(0);
			+height(H);
			.println("Bottom reached");
		}.

+!sweepRoom(Room):
	// Start going left
			atRoom(Room)
		&
		    dirty(Room)
		&
			bottomReached
		&
			not leftReached
		&
			originalWidth(Width)
		&
			not width(Y)
	<-
		+width(Width).

+!sweepRoom(Room):
	// Go left until left reached
			atRoom(Room)
		&
			dirty(Room)
		&
			bottomReached
		&
			not leftReached
		&
			width(Y)
		&
			originalWidth(W)
	<-
		!moveLeftNoExit;
		if (width(0)) {
			+leftReached;
			-width(0);
			+width(W);
			+verticalSweepA;
			+movingUp;
			.println("Left reached");
		}.

+!sweepRoom(Room):

			atRoom(Room)
		&
			dirty(Room)
		&
			bottomReached
		&
			leftReached
	<-
		if (verticalSweepA) {
			!verticalSweepA;
		} else {
			if (horizontalSweepA) {
				!horizontalSweepA;
			} else {
				if (verticalSweepB) {
					!verticalSweepB;
				} else {
					if (horizontalSweepB) {
						!horizontalSweepB;
					} else {
						.println("Finished cleaning room: ", Room);
					};
				};
			};
		}.


+!goToCharger:
	// Go to the charging station if not already there
	// TODO: Fix the environment to add the charger location
		not at(bath1)
	<-
		!goToRoom(bath1).

+!goToCharger:
	// Already at the charging station
		at(bath1)
	<-
		true.


+!verticalSweepA:
			width(W)
		&
			height(H)
		&
			verticalSweepA
		&
			originalWidth(OW)
		&
			originalHeight(OH)
	<-
		if (height(OH) & width(0)) {
			// End the sweep
			.println("Finished verticalSweepA.");
			-verticalSweepA;
			+horizontalSweepB;
			-width(0);
			+width(OW);
			+height(OH);
		} else {
			if (not width(0) & height(0)) {
				// Reach top or bottom
				!moveRightNoExit;
				-height(0);
				+height(OH);
				if (movingUp) {
					-movingUp;
				}
				else {
					+movingUp;
				};
			} else {
				if (not width(0) & not height(0) & movingUp) {
					// Moving up
					!moveUpNoExit;
				} else {
					if (not width(0) & not height(0) & not movingUp) {
						// Moving down
						!moveDownNoExit;
					} else {
						// Should not happen
						.println("Error in verticalSweepA logic.");
					};
				};
			};
		}.


+!horizontalSweepA:
			width(W)
		&
			height(H)
		&
			horizontalSweepA
		&
			originalWidth(OW)
		&
			originalHeight(OH)
	<-
		if (width(OW) & height(0)) {
			// End the sweep
			.println("Finished horizontalSweepA.");
			-horizontalSweepA;
			+verticalSweepA;
			+width(OW);
			-height(0);
			+height(OH);
		} else {
			if (not height(0) & width(0)) {
				// Reach left or right
				!moveDownNoExit;
				-width(0);
				+width(OW);
				if (movingLeft) {
					-movingLeft;
				}
				else {
					+movingLeft;
				};
			} else {
				if (not height(0) & not width(0) & movingLeft) {
					// Moving left
					!moveLeftNoExit;
				} else {
					if (not height(0) & not width(0) & not movingLeft) {
						// Moving right
						!moveRightNoExit;
					} else {
						// Should not happen
						.println("Error in horizontalSweepA logic.");
					};
				};
			};
		}.


+!verticalSweepB:
			width(W)
		&
			height(H)
		&
			verticalSweepB
		&
			originalWidth(OW)
		&
			originalHeight(OH)
	<-
		if (height(OH) & width(0)) {
			// End the sweep
			.println("Finished verticalSweepB.");
			-verticalSweepB;
			+horizontalSweepA;
			-width(0);
			+width(OW);
			+height(OH);
		} else {
			if (not width(0) & height(0)) {
				// Reach top or bottom
				!moveLeftNoExit;
				-height(0);
				+height(OH);
				if (movingDown) {
					-movingDown;
				}
				else {
					+movingDown;
				};
			} else {
				if (not width(0) & not height(0) & movingDown) {
					// Moving down
					!moveDownNoExit;
				} else {
					if (not width(0) & not height(0) & not movingDown) {
						// Moving up
						!moveUpNoExit;
					} else {
						// Should not happen
						.println("Error in verticalSweepB logic.");
					};
				};
			};
		}.


+!horizontalSweepB:
			width(W)
		&
			height(H)
		&
			horizontalSweepB
		&
			originalWidth(OW)
		&
			originalHeight(OH)
	<-
		if (width(OW) & height(0)) {
			// End the sweep
			.println("Finished horizontalSweepB.");
			-horizontalSweepB;
			+verticalSweepB;
			+width(OW);
			-height(0);
			+height(OH);
		} else {
			if (not height(0) & width(0)) {
				// Reach left or right
				!moveUpNoExit;
				-width(0);
				+width(OW);
				if (movingRight) {
					-movingRight;
				}
				else {
					+movingRight;
				};
			} else {
				if (not height(0) & not width(0) & movingRight) {
					// Moving right
					!moveRightNoExit;
				} else {
					if (not height(0) & not width(0) & not movingRight) {
						// Moving left
						!moveLeftNoExit;
					} else {
						// Should not happen
						.println("Error in horizontalSweepB logic.");
					};
				};
			};
		}.
