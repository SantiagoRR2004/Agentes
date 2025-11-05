/* Initial beliefs and rules */

connect(kitchen, hall, doorKit1).
connect(kitchen, hallway, doorKit2).
connect(hall, kitchen, doorKit1).
connect(hallway, kitchen, doorKit2).
connect(bath1, hallway, doorBath1).
connect(bath2, bedroom1, doorBath2).
connect(hallway, bath1, doorBath1).
connect(bedroom1, bath2, doorBath2).
connect(bedroom1, hallway, doorBed1).
connect(hallway, bedroom1, doorBed1).
connect(bedroom2, hallway, doorBed2).
connect(hallway, bedroom2, doorBed2).
connect(bedroom3, hallway, doorBed3).
connect(hallway, bedroom3, doorBed3).
connect(hall, livingroom, doorSal1).
connect(livingroom, hall, doorSal1).
connect(hallway, livingroom, doorSal2).       
connect(livingroom, hallway, doorSal2).


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
	.wait(1000).

+!gotToDirtyRoom(Room) : dirty(Room) & not atRoom(Room) <-
	.println("I am not in the room ", Room, " to clean it.");
	!goToRoom(Room);
	!gotToDirtyRoom(Room).

+!goToRoom(Room): connect(Room, _, Door) & at(robot, Door) <-
	.println("I am already at the door: ", Door).

+!goToRoom(Room): connect(Room, _, Door) & not at(robot, Door) <-
	move_towards(Door).

+!sweepRoom(Room) : atRoom(Room) <-
	.println("I am already in the room: ", Room);
	moveLeft(robot);
	moveLeft(robot);
	moveUp(robot);
	moveUp(robot).
























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

