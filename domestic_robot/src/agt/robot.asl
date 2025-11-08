{ include("movement.asl") }

/* Initial beliefs and rules */

/* GOALS*/
!main.

/* Plans to check dirty rooms */
+!print_dirty_rooms 
    <- .findall(Room, dirty(Room), DirtyRooms);
       if (.length(DirtyRooms, 0)) {
           .println("No dirty rooms found.");
       } else {
           .println("Dirty rooms: ", DirtyRooms);
       }.

/* Plans */

+!main
	:
	dirty(Room)
	<-
	!gotToDirtyRoom(Room);
	!main.

-!main
	<-
	!main.

// +!searchDirtyRooms(Room)
// 	:
// 	dirty(Room)
// 	<-
// 	!gotToDirtyRoom(Room).

+!gotToDirtyRoom(Room) : dirty(Room) & atRoom(Room) <-
	.println("I am already in the room: ", Room);
	!sweepRoom(Room).

+!gotToDirtyRoom(Room) : dirty(Room) & not atRoom(Room) <-
	.println("I am not in the room ", Room, " to clean it.");
	!goToRoom(Room);
	!gotToDirtyRoom(Room).

+!sweepRoom(Room) : atRoom(Room) <-
	.println("I am already in the room: ", Room);
	clean(robot);
	!moveRandomly.
























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

