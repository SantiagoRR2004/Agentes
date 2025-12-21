/* Initial beliefs and rules */

originalHeight(6).
height(6).
originalWidth(16).
width(16).

/* GOALS*/

/* Plans */

+!resetSweep:
	// Reset sweep-related beliefs
			originalHeight(H)
		&
			originalWidth(W)
	<-
		-height(X);
		+height(H);
		-width(Y);
		+width(W);
		-movingUp;
		-movingDown;
		-movingRight;
		-movingLeft;
		-verticalSweepA;
		-horizontalSweepA;
		-verticalSweepB;
		-horizontalSweepB.

+!startingDirection(Room):
    // Decide the direction based on the door
		roomDoorDirection(Room, Door, Direction)
    <-
		// TODO: Make sure the Door is the right one
		.println("Deciding starting direction from door ", Door);
		if (Direction = up) {
			// Sweep horizontally upwards
			+horizontalSweepB;
			.println("Starting horizontalSweepB.");
		};
		if (Direction = down) {
			// Sweep horizontally downwards
			+horizontalSweepA;
			.println("Starting horizontalSweepA.");

		};
		if (Direction = left) {
			// Sweep vertically to the left
			+verticalSweepB;
			.println("Starting verticalSweepB.");
		};
		if (Direction = right) {
			// Sweep vertically to the right
			+verticalSweepA;
			.println("Starting verticalSweepA.");
		}.

+!sweepRoom(Room):
	// Perform sweeping until room is clean
			atRoom(Room)
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
						!startingDirection(Room);
					};
				};
			};
		}.


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
