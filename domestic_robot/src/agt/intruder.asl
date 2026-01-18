{ include("movement.asl") }
/* Initial Beliefs */

connect(kitchen, hall, doorKit1).
connect(hall, kitchen, doorKit1).
connect(hallway, kitchen, doorKit2).
connect(kitchen, hallway, doorKit2).
connect(bath1, hallway, doorBath1).
connect(hallway, bath1, doorBath1).
connect(bath2, bedroom1, doorBath2).
connect(bedroom1, bath2, doorBath2).
connect(bedroom1, hallway, doorBed1).
connect(hallway, bedroom1, doorBed1).
connect(bedroom2, hallway, doorBed2).
connect(hallway, bedroom2, doorBed2).
connect(bedroom3, hallway, doorBed3).
connect(hallway, bedroom3, doorBed3).
connect(livingroom, hallway, doorSal1).
connect(hallway, livingroom, doorSal1).
connect(robotroom, livingroom, doorSal2).
connect(livingroom, robotroom, doorSal2).

/* Initial goals */

!init.

/* Plans */

+!init
  <- 
      .my_name(Me);
      .println("My name is ", Me);
      .random(X);
      if (X < 0.5) {
         .println("I am a guest (friendly).");
         +friendly;
      } else {
         .println("I am an intruder (hostile).");
         +hostile;
      }
      // TODO: Fix the environment to make the intruder know the room he is in
      +atRoom(kitchen);
      +atRoom(livingroom);
      +atRoom(hallway);
      +atRoom(bath1);
      +atRoom(bedroom1);
      +atRoom(bedroom2);
      +atRoom(bedroom3);
      +atRoom(bath2);
      +atRoom(robotroom);
      .wait(1000);
      !main.


+!main:
         useRoom(Room)
      &
         friendly
   <-
      !goingToSit(Room);
      !main.

+!main:
         not useRoom(Room)
      &
         friendly
   <-
      .wait(1000);
      move_towards(owner);
      !main.

+!main:
      hostile
   <-
      move_towards(owner);
      !main.

-!main
	<-
	!main.


+!goingToSit(Room):
   // Not in the desired room yet
      useRoom(Room)
   &
      not atRoom(Room)
   <-
      !goToRoom(Room).

+!goingToSit(Room):
   // In the desired room, but not sitting yet
      useRoom(Room)
   &
      atRoom(Room)
   &
      atRoom(Object, Room)
   &
      .my_name(Me)
   &
      not at(Me, Object)
   <-
      move_towards(Object).

+!goingToSit(Room):
   // In the desired room and sitting
      useRoom(Room)
   &
      atRoom(Room)
   &
      atRoom(Object, Room)
   &
      .my_name(Me)
   &
      at(Me, Object)
   <-
      sit(Object);
      .wait(1000).

+!removeDoorPossibility(Object, Room)[source(Sender)]
   // Empty plan to avoid warnings
   <-
      ?true.

+!addConnectionBroad(Room1, Room2, Door)[source(Sender)]
   // Empty plan to avoid warnings
   <-
      ?true.
