{ include("movement.asl") }

/* Initial beliefs and rules */

originalHeight(6).
originalWidth(16).

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
		!main.

+!main:
	// If currently cleaning a room, go to it and clean
		currentlyCleaning(Room)
	<-
		!cleanRoom(Room);
		!main.

+!main:
	// No dirty rooms, go to the charge station
		not dirty(Room)
	<-
		!goToCharger;
		!main.

-!main
	<-
		!main.


+!chooseRoomToClean:
	// TODO: Choose the closest dirty room
		dirty(Room)
	<-
		.println("Chosen room to clean: ", Room);
		!resetPatience;
		+currentlyCleaning(Room).


+!cleanRoom(Room):
	// If the room is not dirty, stop cleaning
		not dirty(Room)
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
		-height(X);
		+height(X-1);
		if (X-1 == 0) {
			+bottomReached;
			-height(X-1);
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
		-width(Y);
		+width(Y-1);
		if (Y-1 == 0) {
			+leftReached;
			-width(Y-1);
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
			+horizontalSweepA;
			-width(0);
			+width(OW);
			+height(OH);
		} else {
			if (not width(0) & height(0)) {
				// Reach top or bottom
				!moveRightNoExit;
				-width(W);
				+width(W-1);
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
					-height(H);
					+height(H-1);
				} else {
					if (not width(0) & not height(0) & not movingUp) {
						// Moving down
						!moveDownNoExit;
						-height(H);
						+height(H-1);
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
			+verticalSweepB;
			+width(OW);
			-height(0);
			+height(OH);
		} else {
			if (not height(0) & width(0)) {
				// Reach left or right
				!moveDownNoExit;
				-height(H);
				+height(H-1);
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
					-width(W);
					+width(W-1);
				} else {
					if (not height(0) & not width(0) & not movingRight) {
						// Moving left
						!moveLeftNoExit;
						-width(W);
						+width(W-1);
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
			+horizontalSweepB;
			-width(0);
			+width(OW);
			+height(OH);
		} else {
			if (not width(0) & height(0)) {
				// Reach top or bottom
				!moveLeftNoExit;
				-width(W);
				+width(W-1);
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
					-height(H);
					+height(H-1);
				} else {
					if (not width(0) & not height(0) & not movingDown) {
						// Moving up
						!moveUpNoExit;
						-height(H);
						+height(H-1);
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
			+verticalSweepA;
			+width(OW);
			-height(0);
			+height(OH);
		} else {
			if (not height(0) & width(0)) {
				// Reach left or right
				!moveUpNoExit;
				-height(H);
				+height(H-1);
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
					-width(W);
					+width(W-1);
				} else {
					if (not height(0) & not width(0) & not movingLeft) {
						// Moving right
						!moveRightNoExit;
						-width(W);
						+width(W-1);
					} else {
						// Should not happen
						.println("Error in horizontalSweepB logic.");
					};
				};
			};
		}.







/*
// when the supermarket makes a delivery, try the 'has' goal again
+delivered(drug, _Qtd, _OrderId)[source(repartidor)]
  :  true
  <- +delivered;
	 .wait(2000). 
	 
	 // Code changed from original example 
	 // +available(drug, fridge);
     // !has(owner, drug).

// When the fridge is opened, the drug stock is perceived
// and thus the available belief is updated
+stock(drug, 0)
   :  available(drug, fridge)
   <- -available(drug, fridge). 
   
+stock(drug, N)
   :  N > 0 & not available(drug, fridge)
   <- +available(drug, fridge).     
   
+chat(Msg)[source(Ag)] : answer(Msg, Answ) <-  
	.println("El agente ", Ag, " me ha chateado: ", Msg);
	.send(Ag, tell, msg(Answ)). 
                                     
+?time(T) : true
  <-  time.check(T).
*/
