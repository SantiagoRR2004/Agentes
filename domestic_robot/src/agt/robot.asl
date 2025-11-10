{ include("movement.asl") }

/* Initial beliefs and rules */

originalHeight(6).
originalWidth(16).

/* GOALS*/
!main.

/* Plans */

+!main:
	// Clean if dirty
			.my_name(Me)
		&
			at(Me, dirty)
	<-
		clean(robot);
		!main.

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
		-movingUp.

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
		&
			verticalSweepA
	<-
		!verticalSweepA.


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
	// End the sweep
			width(0)
		&
			height(H)
		&
			verticalSweepA
		&
			originalWidth(W)
		&
			originalHeight(H)
	<-
		.println("Finished verticalSweepA.");
		-verticalSweepA;
		+horizontalSweepA;
		-width(0);
		+width(W);
		+height(H).

+!verticalSweepA:
	// Reach top or bottom
			height(0)
		&
			width(W)
		&
			not width(0)
		&
			originalHeight(H)
		&
			verticalSweepA
	<-
		!moveRightNoExit;
		-width(W);
		+width(W-1);
		-height(0);
		+height(H);
		if (movingUp) {
			-movingUp;
		}
		else {
			+movingUp;
		}.

+!verticalSweepA:
	// Moving up
			height(H)
		&
			width(W)
		&
			not height(0)
		&
			not width(0)
		&
			verticalSweepA
		&
			movingUp
	<-
		!moveUpNoExit;
		-height(H);
		+height(H-1).

+!verticalSweepA:
	// Moving down
			height(H)
		&
			width(W)
		&
			not height(0)
		&
			not width(0)
		&
			verticalSweepA
		&
			not movingUp
	<-
		!moveDownNoExit;
		-height(H);
		+height(H-1).









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
