!init.

/* Plans */

+!init
  <- .my_name(Me);
     .println("My name is ", Me);
     .random(X);
     if (X < 0.5) {
        .println("I am a guest (friendly).");
        +friendly;
     } else {
        .println("I am an intruder (hostile).");
        +hostile;
     }.

// plan to achieve the goal "order" for agent Ag
+!order(Product,Qtd)[source(Ag)] : true
  <- ?last_order_id(N);
     OrderId = N + 1;
     -+last_order_id(OrderId);  
     //deliver(Product,Qtd);  
	   .wait(3000);
     .send(Ag, tell, delivered(Product,Qtd,OrderId)).

+at(robot,intruder)
  <- .println("Me han pillado tengo que ir rápido a la cocina.");
     .wait(2000);
     move_towards(fridge);
     .println("Me desplazo en dirección a la nevera.").

+at(owner,intruder) : true
  <- .println("Estoy en shock. He de impedir que den la alarma.");
     .wait(5000);
     move_towards(owner);
     .println("Me desplazo hacia el owner para impedir que avise al 112.").



/*
// Primero, asegúrate de que el intruso pueda moverse bien
{ include("movement.asl") } 

// Plan para reaccionar cuando el owner le dice dónde ir
+useRoom(Room)[source(Sender)]
    <-
    .print("Entendido, gracias ", Sender, ". Iré a descansar a ", Room);
    
    // 1. Ir a la habitación asignada (usa lógica de movement.asl)
    !goToRoom(Room);
    
    // 2. Buscar dónde sentarse en esa habitación
    // (Lógica simplificada: intenta sentarse en cualquier cosa de la sala)
    ?atRoom(Object, Room); // Busca un objeto que esté en esa sala
    !sit(Object).          // Intenta sentarse

+!sit(Object)
    <-
    move_towards(Object);
    sit(Object). // Esta acción solo funcionará si el Owner ya ejecutó 'noAlert'

*/