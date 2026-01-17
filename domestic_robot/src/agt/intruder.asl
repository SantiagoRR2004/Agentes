{ include("movement.asl") }
/* Initial Beliefs */

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
      !main.

+!main:
      hostile
   <-
      .wait(1000);
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
