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