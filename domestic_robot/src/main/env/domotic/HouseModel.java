package domotic;

import jason.environment.grid.Area;
import jason.environment.grid.GridWorldModel;
import jason.environment.grid.Location;
import java.util.Random;

/** class that implements the Model of Domestic Robot application */
public class HouseModel extends GridWorldModel {

  // constants for the grid objects

  public static final int COLUMN = 4;
  public static final int CHAIR = 8;
  public static final int SOFA = 16;
  public static final int FRIDGE = 32;
  public static final int WASHER = 64;
  public static final int DOOR = 128;
  public static final int CHARGER = 256;
  public static final int TABLE = 512;
  public static final int BED = 1024;
  public static final int DIRTY = 2048;

  // the grid size
  public static final int GSize = 12; // Cells
  public final int GridSize = 1080; // Width
  public final int DirtyPlacesNumber = GSize * GSize / 17;

  boolean fridgeOpen = false; // whether the fridge is open
  boolean carryingDrug = false; // whether the robot is carrying drug
  int sipCount = 0; // how many sip the owner did
  int availableDrugs = 2; // how many drugs are available

  Location outHouse = new Location(-1, -1);

  // Initialization of the objects Location on the domotic home scene
  Location lSofa = new Location(GSize / 2, GSize - 2); // (6,10)
  Location lChair1 = new Location(GSize / 2 + 2, GSize - 3); // (8,9)
  Location lChair3 = new Location(GSize / 2 - 1, GSize - 3); // (5,9)
  Location lChair2 = new Location(GSize / 2 + 1, GSize - 4); // (7,8)
  Location lChair4 = new Location(GSize / 2, GSize - 4); // (6,8)
  Location lDeliver = new Location(0, GSize - 1); // (0,11)
  Location lCharger = new Location(GSize / 3, 0); // (4,0)
  Location lFridge = new Location(2, 0); // (2,0)
  Location lTable = new Location(GSize / 2, GSize - 3); // (6,9)
  Location lBed2 = new Location(GSize + 2, 0); // (14,0) on //(12,0,8,4)
  Location lBed3 = new Location(GSize * 2 - 3, 0); // (21,0) on //(9,0,23,4)
  Location lBed1 = new Location(GSize + 1, GSize * 3 / 4); // (13,9) on //(13,7,20,11)

  // Initialization of the doors location on the domotic home scene
  Location lDoorHome = new Location(0, GSize - 1);
  Location lDoorKit1 = new Location(0, GSize / 2);
  Location lDoorKit2 = new Location(GSize / 2 + 1, GSize / 2 - 1);
  Location lDoorSal1 = new Location(GSize / 4, GSize - 1);
  Location lDoorSal2 = new Location(GSize + 1, GSize / 2);
  Location lDoorBed1 = new Location(GSize - 1, GSize / 2);
  Location lDoorBath1 = new Location(GSize - 1, GSize / 4 + 1);
  Location lDoorBed3 = new Location(GSize * 2 - 1, GSize / 4 + 1);
  Location lDoorBed2 = new Location(GSize + 1, GSize / 4 + 1);
  Location lDoorBath2 = new Location(GSize * 2 - 4, GSize / 2 + 1);

  // Initialization of the area modeling the home rooms
  Area kitchen = new Area(0, 0, GSize / 2 + 1, GSize / 2 - 1); // (0,0,7,5)
  Area livingroom = new Area(GSize / 3, GSize / 2 + 1, GSize, GSize - 1); // (4,7,12,11)
  Area bath1 = new Area(GSize / 2 + 2, 0, GSize - 1, GSize / 3); // (8,0,11,4)
  Area bath2 = new Area(GSize * 2 - 3, GSize / 2 + 1, GSize * 2 - 1, GSize - 1); // (21,7,23,11)
  Area bedroom1 = new Area(GSize + 1, GSize / 2 + 1, GSize * 2 - 4, GSize - 1); // (13,7,20,11)
  Area bedroom2 = new Area(GSize + 1, 0, GSize * 4 / 3 + 1, GSize / 3); // (13,0,17,4)
  Area bedroom3 = new Area(GSize * 4 / 3 + 3, 0, GSize * 2 - 1, GSize / 3); // (19,0,23,4)
  Area hall = new Area(0, GSize / 2 + 1, GSize / 4, GSize - 1); // (0,7,3,11)
  Area hallway = new Area(GSize / 2 + 2, GSize / 2 - 1, GSize * 2 - 1, GSize / 2); // (8,7,23,6)

  /*
  Modificar el modelo para que la casa sea un conjunto de habitaciones
  Dar un codigo a cada habitación y vincular un Area a cada habitación
  Identificar los objetos de manera local a la habitación en que estén
  Crear un método para la identificación del tipo de agente existente
  Identificar objetos globales que precisen de un único identificador
  */

  /*
  Thread intruder = new Thread(new Runnable() {
             	@Override
             	public void run() {
                 	try {
                     	while (true) {
                         	update();
                         	Thread.sleep(481);
                     	}
                 	} catch (InterruptedException e) {
                     e.printStackTrace();
                 	}
             	}
         	});
  */
  @Override
  public void setAgPos(int ag, Location l) {
    Location oldLoc = getAgPos(ag);
    if (oldLoc != null) {
      remove(AGENT, oldLoc.x, oldLoc.y);
    }
    agPos[ag] = l;
    if (l.x > -1 && l.y > -1) {
      add(AGENT, l.x, l.y);
    }
  }

  public HouseModel() {
    // create a GSize x 2GSize grid with at most 3 moving agents
    super(2 * GSize, GSize, 3);

    createDirtyPlaces();

    // initial location of robot
    // ag code 0 means the robot
    // setAgPos(0, 19, 10);
    // setAgPos(0, GSize/3, 0);
    setAgPos(0, GSize * 2 - 2, GSize * 3 / 5);

    // initial location of robot

    setAgPos(1, 23, 8);

    setAgPos(2, GSize * 2 - 1, GSize * 3 / 5);

    add(DIRTY, GSize * 2 - 2, GSize * 3 / 5);

    // remove(2, GSize*2-1, GSize*3/5);

    Location locIntruder = getAgPos(2);

    // System.out.println("Hay un intruso en (" + locIntruder.x + ", "+locIntruder.y+").");

    // setAgPos(2, outHouse);

    // Do new methods to create literals for each object placed on
    // the model indicating their nature to inform agents their existence

    // add(DIRTY, 2, 2);

    // initial location of visual objects
    add(FRIDGE, lFridge);
    add(CHARGER, lCharger);
    add(DOOR, lDeliver);
    add(SOFA, lSofa);
    add(CHAIR, lChair2);
    add(CHAIR, lChair3);
    add(CHAIR, lChair4);
    add(CHAIR, lChair1);
    add(TABLE, lTable);
    add(BED, lBed1);
    add(BED, lBed2);
    add(BED, lBed3);

    addWall(GSize / 2 + 1, 0, GSize / 2 + 1, GSize / 2 - 2);
    add(DOOR, lDoorKit2);
    // addWall(GSize/2+1, GSize/2-1, GSize/2+1, GSize-2);
    add(DOOR, lDoorSal1);

    addWall(GSize / 2 + 1, GSize / 4 + 1, GSize - 2, GSize / 4 + 1);
    // addWall(GSize+1, GSize/4+1, GSize*2-1, GSize/4+1);
    add(DOOR, lDoorBath1);
    // addWall(GSize+1, GSize*2/5+1, GSize*2-2, GSize*2/5+1);
    addWall(GSize + 2, GSize / 4 + 1, GSize * 2 - 2, GSize / 4 + 1);
    addWall(GSize * 2 - 6, 0, GSize * 2 - 6, GSize / 4);
    add(DOOR, lDoorBed1);

    addWall(GSize, 0, GSize, GSize / 4 + 1);
    // addWall(GSize+1, GSize/4+1, GSize, GSize/4+1);
    add(DOOR, lDoorBed2);

    addWall(1, GSize / 2, GSize - 1, GSize / 2);
    add(DOOR, lDoorKit1);
    add(DOOR, lDoorSal2);

    addWall(GSize / 4, GSize / 2 + 1, GSize / 4, GSize - 2);

    addWall(GSize, GSize / 2, GSize, GSize - 1);
    addWall(GSize * 2 - 4, GSize / 2 + 2, GSize * 2 - 4, GSize - 1);
    addWall(GSize + 2, GSize / 2, GSize * 2 - 1, GSize / 2);
    add(DOOR, lDoorBed3);
    add(DOOR, lDoorBath2);
  }

  void createDirtyPlaces() {
    Random rand = new Random();
    for (int i = 0; i < DirtyPlacesNumber; i++) {
      int x = rand.nextInt(GSize * 2 - 1); // entre 0 y GSize inclusive
      int y = rand.nextInt(GSize - 1);
      if (isFree(x, y)
          && isFreeOfObstacle(x, y)
          && isFree(FRIDGE, x, y)
          && isFree(CHAIR, x, y)
          && isFree(CHARGER, x, y)
          && isFree(WASHER, x, y)
          && isFree(SOFA, x, y)
          && isFree(TABLE, x, y)) {
        // if (hasObject(CLEAN, x, y)){
        add(DIRTY, x, y);
        System.out.println("Suciedad en (" + x + ", " + y + ").");
      }
      ;
    }
    ;
  }

  String getRoom(Location thing) {

    String byDefault = "kitchen";

    if (bath1.contains(thing)) {
      byDefault = "bath1";
    }
    ;
    if (bath2.contains(thing)) {
      byDefault = "bath2";
    }
    ;
    if (bedroom1.contains(thing)) {
      byDefault = "bedroom1";
    }
    ;
    if (bedroom2.contains(thing)) {
      byDefault = "bedroom2";
    }
    ;
    if (bedroom3.contains(thing)) {
      byDefault = "bedroom3";
    }
    ;
    if (hallway.contains(thing)) {
      byDefault = "hallway";
    }
    ;
    if (livingroom.contains(thing)) {
      byDefault = "livingroom";
    }
    ;
    if (hall.contains(thing)) {
      byDefault = "hall";
    }
    ;
    return byDefault;
  }

  boolean sit(int Ag, Location dest) {
    Location loc = getAgPos(Ag);
    if (loc.isNeigbour(dest)) {
      setAgPos(Ag, dest);
    }
    ;
    return true;
  }

  boolean clean(int Ag) {
    Location loc = getAgPos(Ag);
    if (hasObject(DIRTY, loc)) {
      remove(DIRTY, loc.x, loc.y);
    }
    ;
    return true;
  }

  boolean isDirty(Location loc) {
    return hasObject(DIRTY, loc);
  }

  boolean openFridge() {
    if (!fridgeOpen) {
      fridgeOpen = true;
      return true;
    } else {
      return false;
    }
  }

  boolean closeFridge() {
    if (fridgeOpen) {
      fridgeOpen = false;
      return true;
    } else {
      return false;
    }
  }

  boolean canMoveTo(int Ag, int x, int y) {
    if (Ag < 1) {
      return (isFree(x, y)
          && !hasObject(FRIDGE, x, y)
          && !hasObject(WASHER, x, y)
          && !hasObject(TABLE, x, y)
          && !hasObject(SOFA, x, y)
          && !hasObject(CHAIR, x, y));
    } else {
      return (isFree(x, y)
          && !hasObject(FRIDGE, x, y)
          && !hasObject(CHARGER, x, y)
          && !hasObject(WASHER, x, y)
          && !hasObject(TABLE, x, y));
    }
  }

  boolean moveLeft(int Ag) {
    Location r1 = getAgPos(Ag);
    r1.x--;
    setAgPos(Ag, r1); // move the agent in the grid

    return true;
  }

  boolean moveRight(int Ag) {
    Location r1 = getAgPos(Ag);
    r1.x++;
    setAgPos(Ag, r1); // move the agent in the grid

    return true;
  }

  boolean moveDown(int Ag) {
    Location r1 = getAgPos(Ag);
    r1.y++;
    setAgPos(Ag, r1); // move the agent in the grid

    return true;
  }

  boolean moveUp(int Ag) {
    Location r1 = getAgPos(Ag);
    r1.y--;
    setAgPos(Ag, r1); // move the agent in the grid

    return true;
  }

  boolean moveTowards(int Ag, Location dest) {
    Location r1 = getAgPos(Ag);
    Location r2 = getAgPos(Ag);

    if (r1.distance(dest) > 0) {
      if (r1.x < dest.x && canMoveTo(Ag, r1.x + 1, r1.y)) {
        r1.x++;
      } else if (r1.x > dest.x && canMoveTo(Ag, r1.x - 1, r1.y)) {
        r1.x--;
      }
      ;

      if (r1.y < dest.y && r1.distance(dest) > 0 && canMoveTo(Ag, r1.x, r1.y + 1)) {
        r1.y++;
      } else if (r1.y > dest.y && r1.distance(dest) > 0 && canMoveTo(Ag, r1.x, r1.y - 1)) {
        r1.y--;
      }
      ;
    }
    ;

    if (r1 == r2 && r1.distance(dest) > 0) { // could not move the agent
      if (r1.x == dest.x && canMoveTo(Ag, r1.x + 1, r1.y)) {
        r1.x++;
      }
      ;
      if (r1.x == dest.x && canMoveTo(Ag, r1.x - 1, r1.y)) {
        r1.x--;
      }
      ;
      if (r1.y == dest.y && canMoveTo(Ag, r1.x, r1.y + 1)) {
        r1.y++;
      }
      ;
      if (r1.y == dest.y && canMoveTo(Ag, r1.x, r1.y - 1)) {
        r1.y--;
      }
      ;
    }
    ;

    setAgPos(Ag, r1); // move the agent in the grid

    return true;
  }
}
