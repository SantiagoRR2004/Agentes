{ include("movement.asl") }

/* Initial beliefs and rules */

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
		!goToCharger.

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
		-currentlyCleaning(Room).

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
	// TODO: Implement cleaning action
			atRoom(Room)
		&
		    dirty(Room)
	<-
	!moveRandomly.


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
