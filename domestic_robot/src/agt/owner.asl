{ include("movement.asl") }

/* Initial Beliefs */
sittable([sofa, chair1, chair2, chair3, chair4]).
sleepOn([bed1, bed2, bed3]).

/* Initial goals */

!main.

/* Plans */

// +intruderDetected[source(robot)]
// 	// Handle intruder alert from robot
// 	<-
// 		// Only the owner can trigger the alert
// 		alert("He could be you, he could be me, he could even be-");
		
// 		+intruderDetected(intruder).


+at(Me, F): 
		my_name(Me)
	&
		intruderDetected(_)
	<-
		.random(R);
		if (R < 0.25) { moveObjectUp(F); }
		else { if (R < 0.5) { moveObjectDown(F); }
		else { if (R < 0.75) { moveObjectLeft(F); }
		else { moveObjectRight(F); }}}.


+batteryRecharged[source(Sender)]
	// Handle battery recharged alert from robot
	<-
		-needToCharge(Sender).

+batteryDepleted[source(Sender)]
	// Handle battery depleted alert from robot
	<-
		+needToCharge(Sender).


+!main:
		// First objective is to run from intruder if detected
		intruderDetected(Intruder)
	<-
		!runFromIntruder(Intruder);
		!main.

+!main:
	// Charge the robot if needed
	needToCharge(Robot)
	<-
		!recharge(Robot);
		!main.

+!main:
	// Go to check on the unknown agent
		unknownAgentDetected(Agent, Room)
	<-
		!greetIntruder(Agent, Room);
		!main.

+!main:
	wantToSit(Object)
	<-
	!sitOnObjective;
	!main.

+!main:
	wantToSleep(Object)
	<-
	!sleepOnObjective;
	!main.

+!main
	<-
	!chooseObjective;
	!main.

-!main
	<-
	!main.

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/* Plan to greet a known intruder (Guest) */

// PLAN 1 de "greetIntruder": si tengo que saludar pero no se encuentra al lado del intruso, se acerca
+!greetIntruder(Agent, Room):
		not atRoom(Room)
    <-   
		// Se procede el owner a desplazarse hacia el intruso
		!goToRoom(Room). 


// PLAN 2 de "greetIntruder": En el momento de estar al lado del intruso, se ejecuta el saludo y mandarlo a una habitación
+!greetIntruder(Agent, Room):
			atRoom(Room)
		& 
			sittable(FurnitureList)  // Obtener la lista de muebles donde puede sentarse
    <-
		.send(Agent, askOne, friendly, Response, 1000);

		if (Response) {
			.print("Estoy con ", Agent, ". Iniciando protocolo de bienvenida.");

			// Ejecutar noAlert inmediatamente (ya se esta con el intruso)
			noAlert;
			
			// Esta linea de codigo se puede quitar si no se quiere avisar al robot aunque seria recomendable tenerlo en cuenta
			// para que el robot no grite alarma al ver al intruso nuevamente por algun casual si lo llega a ver otra vez
			//.send(robot, tell, friend(Agent));
			
			// Elegir habitación seleccionando un mueble al azar de la lista (similar a la lógica de chooseSittingPlace)
			.length(FurnitureList, Len);
			.random(R);
			Index = math.floor(R * Len);
			.nth(Index, FurnitureList, ChosenFurniture);
			?atRoom(ChosenFurniture, Room);
			
			// Comunicar al invitado la habitación asignada y enviarle el mensaje para que se dirija allí
			// La creencia temporal se tendria que gestionar luego en el plan del intruso para que sepa donde ir y tambien borrarla luego
			.print("Hola ", Agent, ", bienvenido. Puedes descansar en: ", Room);
			.send(Agent, tell, useRoom(Room));

			// Se borra el objetivo para que el owner intente saludar al intruso nuevamente si vuelve a detectarlo (en bucle)
			-goGreetIntruder(Agent, Room);
		} else {
			alert("He could be you, he could be me, he could even be-");

			-goGreetIntruder(Agent, Room);
			+intruderDetected(Agent);
		}.

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

+!recharge(Robot):
	// Owner is not carrying the robot
			needToCharge(Robot)
		&
			not carryOn
		&
			.my_name(Me)
		&
			not at(Me, Robot)
	<-
		!moveTowardsAdvanced(Robot).

+!recharge(Robot):
	// Owner is not carrying the robot
			needToCharge(Robot)
		&
			not carryOn
		&
			.my_name(Me)
		&
			at(Me, Robot)
	<-
		take.

+!recharge(Robot):
	// Owner is carrying the robot
			needToCharge(Robot)
		&
			carryOn
		&
			.my_name(Me)
		&
			not at(Me, charger)
	<-
		!moveTowardsAdvanced(charger).

+!recharge(Robot):
	// Owner is carrying the robot
			needToCharge(Robot)
		&
			carryOn
		&
			.my_name(Me)
		&
			at(Me, charger)
	<-
		drop.


+!chooseObjective
	<-
	.random(X);
	// 50% chance to want to sit
	if (X < 0.5) {
		!chooseSittingPlace;
	} else {
		// 50% chance to want to sleep
		!chooseSleepingPlace;
	};
	!resetPatience.


+!chooseSittingPlace:
		sittable(SittableList)
	<-
		// Randomly choose a sitting place
		.random(R);
		.length(SittableList, Len);
		Index = (R * Len);
		IndexInt = math.floor(Index);
		.nth(IndexInt, SittableList, ChosenPlace);
		.println("Owner wants to sit on ", ChosenPlace);
		+wantToSit(ChosenPlace).


+!chooseSleepingPlace:
		sleepOn(SleepableList)
	<-
		// Randomly choose a sleeping place
		.random(R);
		.length(SleepableList, Len);
		Index = (R * Len);
		IndexInt = math.floor(Index);
		.nth(IndexInt, SleepableList, ChosenPlace);
		.println("Owner wants to sleep on ", ChosenPlace);
		+wantToSleep(ChosenPlace).


+!sitOnObjective:
	// Owner is not where he wants to sit
			wantToSit(ChosenPlace)
		&
			.my_name(Me)
		&
			not at(Me, ChosenPlace)
	<-
		!moveTowardsAdvanced(ChosenPlace).

+!sitOnObjective:
	// Owner is where he wants to sit
			wantToSit(ChosenPlace)
		&
			.my_name(Me)
		&
			at(Me, ChosenPlace)
	<-
		sit(ChosenPlace);
		.random(X);
		// Between 1 and 2 seconds
		.wait(X*1000+1000);
		.random(Y);
		// 10% change to want to do something else
		if (Y < 0.1) {
			-wantToSit(ChosenPlace);
		}.


+!sleepOnObjective:
	// Owner is not where he wants to sleep
			wantToSleep(ChosenPlace)
		&
			.my_name(Me)
		&
			not at(Me, ChosenPlace)
	<-
		!moveTowardsAdvanced(ChosenPlace).

+!sleepOnObjective:
	// Owner is where he wants to sleep
			wantToSleep(ChosenPlace)
		&
			.my_name(Me)
		&
			at(Me, ChosenPlace)
	<-
		sit(ChosenPlace);
		.random(X);
		// Between 2 and 7 seconds
		.wait(X*5000+2000);
		.random(Y);
		// 10% change to want to do something else
		if (Y < 0.1) {
			-wantToSleep(ChosenPlace);
		}.


///////////////////////////////////////////////////////////////////////////////////////////////////
/* Elegir la habitación más lejana y huir */
+!runFromIntruder(Intruder):
        atRoom(CurrentRoom) & numberOfDoors(MaxDepth)
	<-
		.setof(Room, atRoom(_,Room), Rooms);
		-furthestRoom(_,_); +furthestRoom(CurrentRoom,-1);
		for (.member(R,Rooms) & not R = CurrentRoom) {
			if (shortestRoomPath(CurrentRoom,R,Path,MaxDepth+1)) {
				.length(Path,L); ?furthestRoom(_,BestL);
				if (L > BestL) { -furthestRoom(_,_); +furthestRoom(R,L); };
			};
		};
		?furthestRoom(SafeRoom,_);
		!escapeToRoom(SafeRoom,Intruder).

+!escapeToRoom(SafeRoom,Intruder):
        intruderDetected(Intruder) & not atRoom(SafeRoom)
	<-
		!moveTowardsAdvanced(SafeRoom);
		!escapeToRoom(SafeRoom,Intruder).

+!escapeToRoom(SafeRoom,Intruder):
        atRoom(SafeRoom)
	<-
    	-intruderDetected(Intruder).
