package domotic;

import jason.asSyntax.*;
import jason.environment.Environment;
import jason.environment.grid.Location;
import java.util.logging.Logger;

public class HouseEnv extends Environment {

  // common literals
  public static final Literal of = Literal.parseLiteral("open(fridge)");
  public static final Literal clf = Literal.parseLiteral("close(fridge)");
  public static final Literal gb = Literal.parseLiteral("get(drug)");
  public static final Literal hb = Literal.parseLiteral("hand_in(drug)");
  public static final Literal sb = Literal.parseLiteral("sip(drug)");
  public static final Literal hob = Literal.parseLiteral("has(owner,drug)");

  public static final Literal af = Literal.parseLiteral("at(robot,fridge)");
  public static final Literal ao = Literal.parseLiteral("at(robot,owner)");
  public static final Literal ad = Literal.parseLiteral("at(robot,delivery)");
  public static final Literal ab1 = Literal.parseLiteral("at(robot,bed1)");
  public static final Literal ab2 = Literal.parseLiteral("at(robot,bed2)");
  public static final Literal ab3 = Literal.parseLiteral("at(robot,bed3)");
  public static final Literal ac1 = Literal.parseLiteral("at(robot,chair1)");
  public static final Literal ac2 = Literal.parseLiteral("at(robot,chair2)");
  public static final Literal ac3 = Literal.parseLiteral("at(robot,chair3)");
  public static final Literal ac4 = Literal.parseLiteral("at(robot,chair4)");
  public static final Literal asf = Literal.parseLiteral("at(robot,sofa)");
  public static final Literal ach = Literal.parseLiteral("at(robot,charger)");
  public static final Literal oa = Literal.parseLiteral("at(owner,robot)");
  public static final Literal oaf = Literal.parseLiteral("at(owner,fridge)");
  public static final Literal ob1 = Literal.parseLiteral("at(owner,bed1)");
  public static final Literal ob2 = Literal.parseLiteral("at(owner,bed2)");
  public static final Literal ob3 = Literal.parseLiteral("at(owner,bed3)");
  public static final Literal oac1 = Literal.parseLiteral("at(owner,chair1)");
  public static final Literal oac2 = Literal.parseLiteral("at(owner,chair2)");
  public static final Literal oac3 = Literal.parseLiteral("at(owner,chair3)");
  public static final Literal oac4 = Literal.parseLiteral("at(owner,chair4)");
  public static final Literal oasf = Literal.parseLiteral("at(owner,sofa)");
  public static final Literal od = Literal.parseLiteral("at(owner,delivery)");
  public static final Literal och = Literal.parseLiteral("at(owner,charger)");

  public static final Literal ai = Literal.parseLiteral("at(robot,intruder)");
  public static final Literal oai = Literal.parseLiteral("at(owner,intruder)");

  public static final Literal at = Literal.parseLiteral("at(robot,dirty)");
  public static final Literal oat = Literal.parseLiteral("at(owner,dirty)");

  static Logger logger = Logger.getLogger(HouseEnv.class.getName());

  HouseModel model; // the model of the grid

  @Override
  public void init(String[] args) {
    model = new HouseModel();

    if (args.length == 1 && args[0].equals("gui")) {
      HouseView view = new HouseView(model);
      model.setView(view);
    }

    updatePercepts();
  }

  void updateAgentsPlace() {
    // get the robot location
    Location lRobot = model.getAgPos(0);
    // get the robot room location
    String RobotPlace = model.getRoom(lRobot);
    addPercept("robot", Literal.parseLiteral("atRoom(" + RobotPlace + ")"));
    addPercept("owner", Literal.parseLiteral("atRoom(robot," + RobotPlace + ")"));
    // get the owner location
    Location lOwner = model.getAgPos(1);
    // get the owner room location
    String OwnerPlace = model.getRoom(lOwner);
    addPercept("owner", Literal.parseLiteral("atRoom(" + OwnerPlace + ")"));
    addPercept("robot", Literal.parseLiteral("atRoom(owner," + OwnerPlace + ")"));

    if (lRobot.distance(model.lDoorHome) == 0
        || lRobot.distance(model.lDoorKit1) == 0
        || lRobot.distance(model.lDoorKit2) == 0
        || lRobot.distance(model.lDoorSal1) == 0
        || lRobot.distance(model.lDoorSal2) == 0
        || lRobot.distance(model.lDoorBath1) == 0
        || lRobot.distance(model.lDoorBath2) == 0
        || lRobot.distance(model.lDoorBed1) == 0
        || lRobot.distance(model.lDoorBed2) == 0
        || lRobot.distance(model.lDoorBed3) == 0) {
      addPercept("robot", Literal.parseLiteral("atDoor"));
    }
    ;

    if (lOwner.distance(model.lDoorHome) == 0
        || lOwner.distance(model.lDoorKit1) == 0
        || lOwner.distance(model.lDoorKit2) == 0
        || lOwner.distance(model.lDoorSal1) == 0
        || lOwner.distance(model.lDoorSal2) == 0
        || lOwner.distance(model.lDoorBath1) == 0
        || lOwner.distance(model.lDoorBath2) == 0
        || lOwner.distance(model.lDoorBed1) == 0
        || lOwner.distance(model.lDoorBed2) == 0
        || lOwner.distance(model.lDoorBed3) == 0) {
      addPercept("owner", Literal.parseLiteral("atDoor"));
    }
    ;
  }

  void updateThingsPlace() {

    String chargerPlace = model.getRoom(model.lCharger);
    addPercept(Literal.parseLiteral("atRoom(charger, " + chargerPlace + ")"));
    String fridgePlace = model.getRoom(model.lFridge);
    addPercept(Literal.parseLiteral("atRoom(fridge, " + fridgePlace + ")"));
    String sofaPlace = model.getRoom(model.lSofa);
    addPercept(Literal.parseLiteral("atRoom(sofa, " + sofaPlace + ")"));
    String chair1Place = model.getRoom(model.lChair1);
    addPercept(Literal.parseLiteral("atRoom(chair1, " + chair1Place + ")"));
    String chair2Place = model.getRoom(model.lChair2);
    addPercept(Literal.parseLiteral("atRoom(chair2, " + chair2Place + ")"));
    String chair3Place = model.getRoom(model.lChair3);
    addPercept(Literal.parseLiteral("atRoom(chair3, " + chair3Place + ")"));
    String chair4Place = model.getRoom(model.lChair4);
    addPercept(Literal.parseLiteral("atRoom(chair4, " + chair4Place + ")"));
    String deliveryPlace = model.getRoom(model.lDeliver);
    addPercept(Literal.parseLiteral("atRoom(delivery, " + deliveryPlace + ")"));
    String bed1Place = model.getRoom(model.lBed1);
    addPercept(Literal.parseLiteral("atRoom(bed1, " + bed1Place + ")"));
    String bed2Place = model.getRoom(model.lBed2);
    addPercept(Literal.parseLiteral("atRoom(bed2, " + bed2Place + ")"));
    String bed3Place = model.getRoom(model.lBed3);
    addPercept(Literal.parseLiteral("atRoom(bed3, " + bed3Place + ")"));

    String doorHomePlace = model.getRoom(model.lDoorHome);
    addPercept(Literal.parseLiteral("atRoom(doorHome, " + doorHomePlace + ")"));
    String doorBed1Place = model.getRoom(model.lDoorBed1);
    addPercept(Literal.parseLiteral("atRoom(doorBed1, " + doorBed1Place + ")"));
    String doorBed2Place = model.getRoom(model.lDoorBed2);
    addPercept(Literal.parseLiteral("atRoom(doorBed2, " + doorBed2Place + ")"));
    String doorBed3Place = model.getRoom(model.lDoorBed3);
    addPercept(Literal.parseLiteral("atRoom(doorBed3, " + doorBed3Place + ")"));
    String doorKit1Place = model.getRoom(model.lDoorKit1);
    addPercept(Literal.parseLiteral("atRoom(doorKit1, " + doorKit1Place + ")"));
    String doorKit2Place = model.getRoom(model.lDoorKit2);
    addPercept(Literal.parseLiteral("atRoom(doorKit2, " + doorKit2Place + ")"));
    String doorSal1Place = model.getRoom(model.lDoorSal1);
    addPercept(Literal.parseLiteral("atRoom(doorSal1, " + doorSal1Place + ")"));
    String doorSal2Place = model.getRoom(model.lDoorSal2);
    addPercept(Literal.parseLiteral("atRoom(doorSal2, " + doorSal2Place + ")"));
    String doorBath1Place = model.getRoom(model.lDoorBath1);
    addPercept(Literal.parseLiteral("atRoom(doorBath1, " + doorBath1Place + ")"));
    String doorBath2Place = model.getRoom(model.lDoorBath2);
    addPercept(Literal.parseLiteral("atRoom(doorBath2, " + doorBath2Place + ")"));
  }

  /** creates the agents percepts based on the HouseModel */
  void updatePercepts() {
    // clear the percepts of the agents
    clearAllPercepts();
    // clearPercepts();
    // clearPercepts("robot");
    // clearPercepts("owner");
    // clearPercepts("repartidor");

    updateAgentsPlace();
    updateThingsPlace();

    Location lRobot = model.getAgPos(0);
    Location lOwner = model.getAgPos(1);
    Location lIntruder = model.getAgPos(2);
    if (lIntruder != null) {
    } else {
    }

    if (lRobot.distance(model.lFridge) < 2) {
      addPercept("robot", af);
    }

    if (lOwner.distance(model.lFridge) < 2) {
      addPercept("owner", oaf);
    }

    if (lRobot.distance(model.lCharger) < 1) {
      addPercept("robot", ach);
    }
    if (lOwner.distance(model.lCharger) < 2) {
      addPercept("owner", och);
    }

    if (lRobot.distance(lOwner) == 1) {
      addPercept("robot", ao);
      addPercept("owner", oa);
    }

    if (lIntruder != null && lRobot.distance(lIntruder) == 1) {
      addPercept("robot", ai);
    }

    if (lIntruder != null && lOwner.distance(lIntruder) == 1) {
      addPercept("owner", oai);
    }

    if (model.isDirty(lRobot)) {
      addPercept("robot", at);
    }

    if (model.isDirty(lOwner)) {
      addPercept("owner", oat);
    }

    if (lRobot.distance(model.lDeliver) == 1) {
      addPercept("robot", ad);
    }
    if (lOwner.distance(model.lDeliver) == 0) {
      addPercept("owner", od);
    }

    if (lOwner.distance(model.lBed1) == 0) {
      addPercept("owner", ob1);
    }
    if (lRobot.distance(model.lBed1) == 1) {
      addPercept("robot", ab1);
    }

    if (lOwner.distance(model.lBed2) == 0) {
      addPercept("owner", ob2);
    }
    if (lRobot.distance(model.lBed2) == 1) {
      addPercept("robot", ab2);
    }

    if (lOwner.distance(model.lBed3) == 0) {
      addPercept("owner", ob3);
    }
    if (lRobot.distance(model.lBed3) == 1) {
      addPercept("robot", ab3);
    }

    if (lOwner.distance(model.lChair1) == 0) {
      addPercept("owner", oac1);
    }
    if (lRobot.distance(model.lChair1) == 1) {
      addPercept("robot", ac1);
    }

    if (lOwner.distance(model.lChair2) == 0) {
      addPercept("owner", oac2);
    }
    if (lRobot.distance(model.lChair2) == 1) {
      addPercept("robot", ac2);
    }

    if (lOwner.distance(model.lChair3) == 0) {
      addPercept("owner", oac3);
    }
    if (lRobot.distance(model.lChair3) == 1) {
      addPercept("robot", ac3);
    }

    if (lOwner.distance(model.lChair4) == 0) {
      addPercept("owner", oac4);
    }
    if (lRobot.distance(model.lChair4) == 1) {
      addPercept("robot", ac4);
    }

    if (lOwner.distance(model.lSofa) == 0) {
      addPercept("owner", oasf);
    }
    if (lRobot.distance(model.lSofa) == 1) {
      addPercept("robot", asf);
    }

    // add drug "status" the percepts
    if (model.fridgeOpen) {
      addPercept("robot", Literal.parseLiteral("stock(drug," + model.availableDrugs + ")"));
    }
    if (model.sipCount > 0) {
      addPercept("robot", hob);
      addPercept("owner", hob);
    }

    for (String room : model.dirtyRooms.keySet()) {
      if (model.dirtyRooms.get(room) > 0) {
        addPercept("robot", Literal.parseLiteral("dirty(" + room + ")"));
        addPercept("owner", Literal.parseLiteral("dirty(" + room + ")"));
      }
    }
  }

  @Override
  public boolean executeAction(String ag, Structure action) {

    // java.util.List<Literal> perceptsOwner = consultPercepts("owner");
    // java.util.List<Literal> perceptsRobot = consultPercepts("robot");
    // System.out.println("[owner] has the following percepts: "+perceptsOwner);
    // System.out.println("[robot] has the following percepts: "+perceptsRobot);

    boolean result = false;
    if (action.getFunctor().equals("sit")) {
      String l = action.getTerm(0).toString();
      Location dest = null;
      switch (l) {
        case "bed1":
          dest = model.lBed1;
          break;
        case "bed2":
          dest = model.lBed2;
          break;
        case "bed3":
          dest = model.lBed3;
          break;
        case "chair1":
          dest = model.lChair1;
          break;
        case "chair2":
          dest = model.lChair2;
          break;
        case "chair3":
          dest = model.lChair3;
          break;
        case "chair4":
          dest = model.lChair4;
          break;
        case "sofa":
          dest = model.lSofa;
          break;
      }
      ;
      try {
        if (ag.equals("robot")) {
          result = model.sit(0, dest);
        } else {
          result = model.sit(1, dest);
        }
      } catch (Exception e) {
        e.printStackTrace();
      }
    } else if (action.equals(of)) { // of = open(fridge)
      result = model.openFridge();

    } else if (action.equals(clf)) { // clf = close(fridge)
      result = model.closeFridge();

    } else if (action.getFunctor().equals("move_towards")) {
      String l = action.getTerm(0).toString();
      Location dest = null;
      switch (l) {
        case "fridge":
          dest = model.lFridge;
          break;
        case "owner":
          dest = model.getAgPos(1);
          break;
        case "delivery":
          dest = model.lDeliver;
          break;
        case "bed1":
          dest = model.lBed1;
          break;
        case "bed2":
          dest = model.lBed2;
          break;
        case "bed3":
          dest = model.lBed3;
          break;
        case "chair1":
          dest = model.lChair1;
          break;
        case "chair2":
          dest = model.lChair2;
          break;
        case "chair3":
          dest = model.lChair3;
          break;
        case "chair4":
          dest = model.lChair4;
          break;
        case "sofa":
          dest = model.lSofa;
          break;
        case "charger":
          dest = model.lCharger;
          break;
        case "table":
          dest = model.lTable;
          break;
        case "doorBed1":
          dest = model.lDoorBed1;
          break;
        case "doorBed2":
          dest = model.lDoorBed2;
          break;
        case "doorBed3":
          dest = model.lDoorBed3;
          break;
        case "doorKit1":
          dest = model.lDoorKit1;
          break;
        case "doorKit2":
          dest = model.lDoorKit2;
          break;
        case "doorSal1":
          dest = model.lDoorSal1;
          break;
        case "doorSal2":
          dest = model.lDoorSal2;
          break;
        case "doorBath1":
          dest = model.lDoorBath1;
          break;
        case "doorBath2":
          dest = model.lDoorBath2;
          break;
      }
      try {
        if (ag.equals("robot")) {
          result = model.moveTowards(0, dest);
        } else {
          result = model.moveTowards(1, dest);
        }
      } catch (Exception e) {
        e.printStackTrace();
      }

    } else if (action.getFunctor().equals("alert")) { // clf = close(fridge)
      result = true;
      /*
      Incluir acciones moveLeft, moveRight, clean
      Incluir percepciones dirty(Room)

      */
    } else if (action.getFunctor().equals("clean")) {
      if (ag.equals("robot")) {
        result = model.clean(0);
      } else {
        result = model.clean(1);
      }
    } else if (action.getFunctor().equals("moveUp")) {
      if (ag.equals("robot")) {
        result = model.moveUp(0);
      } else {
        result = model.moveUp(1);
      }
    } else if (action.getFunctor().equals("moveDown")) {
      if (ag.equals("robot")) {
        result = model.moveDown(0);
      } else {
        result = model.moveDown(1);
      }
    } else if (action.getFunctor().equals("moveLeft")) {
      if (ag.equals("robot")) {
        result = model.moveLeft(0);
      } else {
        result = model.moveLeft(1);
      }
    } else if (action.getFunctor().equals("moveRight")) {
      if (ag.equals("robot")) {
        result = model.moveRight(0);
      } else {
        result = model.moveRight(1);
      }
    } else {
    }

    if (result) {
      updatePercepts();
      try {
        Thread.sleep(300);
      } catch (Exception e) {
      }
    }
    return result;
  }
}
