/* Initial beliefs and rules */

originalHeight(6).
originalWidth(16).

/* GOALS*/

/* Plans */

+!resetSweep
	// Reset sweep-related beliefs
	<-
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


+!sweepRoom(Room):
	// Start going down
			atRoom(Room)
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
	// Perform sweeping until room is clean
			atRoom(Room)
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
