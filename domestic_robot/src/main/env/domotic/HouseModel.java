package domotic;

import jason.environment.grid.GridWorldModel;
import jason.environment.grid.Area;
import jason.environment.grid.Location;

import java.util.HashMap;
import java.util.Map;

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
  public final int DirtyPlacesNumber = GSize * GSize / 11;
                          
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
    Location lCharger = new Location(GSize - 2, 0); // (10,0)
    Location lFridge = new Location(2, 0); // (2,0)
    Location lTable = new Location(GSize / 2, GSize - 3); // (6,9)
	Location lBed2 = new Location(GSize + 2, 0); // (14,0) on //(12,0,8,4)
	Location lBed3 = new Location(GSize * 2 - 3, 0); // (21,0) on //(9,0,23,4)
	Location lBed1 = new Location(GSize + 1, GSize * 3 / 4); // (13,9) on //(13,7,20,11)

	// Initialization of the doors location on the domotic home scene 
	Location lDoorHome = new Location(0, GSize - 1); // (0,11)
	Location lDoorKit1 = new Location(0, GSize / 2); // (0,6)
	Location lDoorKit2 = new Location(GSize / 2 + 1, GSize / 2 - 1); // (7,5)
	Location lDoorSal1 = new Location(GSize / 4, GSize - 1); // (3,11)
	Location lDoorSal2 = new Location(GSize - 1, GSize / 2); // (11,6)
	Location lDoorBed1 = new Location(GSize + 1, GSize / 2); // (13,6)
	Location lDoorBath1 = new Location(GSize - 1, GSize / 3); // (11,4)
	Location lDoorBed3 = new Location(GSize * 2 - 1, GSize / 3); // (23,4)
	Location lDoorBed2 = new Location(GSize + 1, GSize / 3); // (13,4)
	Location lDoorBath2 = new Location(GSize * 2 - 4, GSize / 2 + 1); // (20,7)

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
	Map<String, Integer> dirtyRooms = new HashMap<>();
	
	Thread intruder = 
		new Thread(new Runnable() {
            	@Override
            	public void run() {
                	try {
                    	while (true) {
                        	createIntruder();
                        	Thread.sleep(60000);
                    	}
                	} catch (InterruptedException e) {
                    e.printStackTrace();
                	}
            	}
        });
	
	Thread dirtyPlaces = 
		new Thread(new Runnable() {
            	@Override
            	public void run() {
                	try {
                    	while (true) {
                        	createDirtyPlaces();
                        	Thread.sleep(40000);
                    	}
                	} catch (InterruptedException e) {
                    e.printStackTrace();
                	}
            	}
        });
	
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
	@Override
	 public void addWall(int x1, int y1, int x2, int y2) {
        for (int x = x1; x <= x2; x++) {
            for (int y = y1; y <= y2; y++) {
                set(OBSTACLE, x, y);
            }
        }
    }
    public HouseModel() {
        // create a GSize x 2GSize grid with at most 3 moving agents 
        super(2 * GSize, GSize, 3);
		
		// initial location of robot 
        // ag code 0 means the robot
        // setAgPos(0, 19, 10);  
		// setAgPos(0, GSize/3, 0);
		setAgPos(0, GSize * 2 - 2, GSize * 3 / 4); // (22,9)

        // initial location of robot 
 		
		setAgPos(1, 23, 8);

		Location locIntruder = getAgPos(2);

		// System.out.println("Hay un intruso en (" + locIntruder.x + ", "+locIntruder.y+").");

		// Do new methods to create literals for each object placed on
		// the model indicating their nature to inform agents their existence

		 
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
		
		addWall(GSize/2+1, 0, GSize/2+1, GSize/3);  				// KitchenRight(7,0,7,4)	
		add(DOOR, lDoorKit2);                              
		add(DOOR, lDoorSal1); 

		addWall(GSize/2+1, GSize/3, GSize-2, GSize/3);   			// HallwayUp1(7,4,10,4)
		add(DOOR, lDoorBath1); 
		
		addWall(GSize+2, GSize/3, GSize*2-2, GSize/3);   			// HallwayUp2(14,4,22,4)
		addWall(GSize*2-6, 0, GSize*2-6, GSize/4);					// Bed3Right(18,0,18,3)
		add(DOOR, lDoorBed1); 
		
		addWall(GSize, 0, GSize, GSize/3);  						// Bath1Right(12,0,12,4)
		add(DOOR, lDoorBed2); 
		
		addWall(1, GSize/2, GSize-2, GSize/2);            			// LivingUp(1,6,10,6)
		add(DOOR, lDoorKit1);                
		add(DOOR, lDoorSal2);

		addWall(GSize/4, GSize/2+1, GSize/4, GSize-2);            	// HallRight(3,7,3,10)
		
		addWall(GSize, GSize/2, GSize, GSize-1);  					// LivingRight(12,6,12,11)
		addWall(GSize*2-4, GSize/2+2, GSize*2-4, GSize-1);  		// Bath2Left(20,8,20,11)
		addWall(GSize+2, GSize/2, GSize*2-1, GSize/2);  			// HallwayDown(14,6,23,6)
 		add(DOOR, lDoorBed3);  
 		add(DOOR, lDoorBath2);  

		initRooms();

		dirtyPlaces.start();
		
		intruder.start();

    }

	void initRooms(){
		dirtyRooms.put("kitchen", 0);
		dirtyRooms.put("livingroom", 0);
		dirtyRooms.put("bath1", 0);
		dirtyRooms.put("bath2", 0);
		dirtyRooms.put("bedroom1", 0);
		dirtyRooms.put("bedroom2", 0);
		dirtyRooms.put("bedroom3", 0);
		dirtyRooms.put("hall", 0);
		dirtyRooms.put("hallway", 0);
	}
	
	void createIntruder(){
		Location loc = getFreePos();
		setAgPos(2, loc); 
	}

	void addDirty(Location loc){
		int val;
		add(DIRTY, loc);
		if (bath1.contains(loc)){
			val = dirtyRooms.get("bath1");
			val++;
			dirtyRooms.put("bath1", val);
		};
		if (bath2.contains(loc)){
			val = dirtyRooms.get("bath2");
			val++;
			dirtyRooms.put("bath2", val);
		};
		if (bedroom1.contains(loc)){
			val = dirtyRooms.get("bedroom1");
			val++;
			dirtyRooms.put("bedroom1", val);
		};
		if (bedroom2.contains(loc)){
			val = dirtyRooms.get("bedroom2");
			val++;
			dirtyRooms.put("bedroom2", val);
		};
		if (bedroom3.contains(loc)){
			val = dirtyRooms.get("bedroom3");
			val++;
			dirtyRooms.put("bedroom3", val);
		};
		if (hallway.contains(loc)){
			val = dirtyRooms.get("hallway");
			val++;
			dirtyRooms.put("hallway", val);
		};
		if (hall.contains(loc)){
			val = dirtyRooms.get("hall");
			val++;
			dirtyRooms.put("hall", val);
		};
		if (livingroom.contains(loc)){
			val = dirtyRooms.get("livingroom");
			val++;
			dirtyRooms.put("livingroom", val);
		};
		if (kitchen.contains(loc)){
			val = dirtyRooms.get("kitchen");
			val++;
			dirtyRooms.put("kitchen", val);
		};
		System.out.println("Suciedad en (" + loc.x + ", " + loc.y + ").");
	}

	boolean isFreeTable(int x, int y){
		return isFree(TABLE,x,y) & isFree(TABLE,x-1,y);
	}

	boolean isFreeSofa(int x, int y){
		return isFree(SOFA,x,y) & isFree(SOFA,x-1,y);
	}

	boolean isFreeBed(int x, int y){
		return isFree(BED,x,y) & isFree(BED,x-1,y) & isFree(BED,x-1,y-1) & isFree(BED,x,y-1);
	}

	boolean isFreeOfObject(int x, int y) {
		boolean free;
		free = isFree(DIRTY,x,y) && isFree(FRIDGE,x,y) && isFree(CHAIR,x,y);
		free = free && isFree(CHARGER,x,y) && isFree(WASHER,x,y);
		free = isFreeSofa(x,y) && isFreeTable(x,y) && isFreeBed(x,y);

		return free && isFreeOfObstacle(x,y);
	}

	void createDirtyPlaces(){
		Random rand = new Random();
		Location loc;
		for (int i = 0; i < DirtyPlacesNumber; i++) {
            int x = rand.nextInt(GSize*2-1); // entre 0 y GSize inclusive
            int y = rand.nextInt(GSize-1);
			String room1 = getRoom(new Location(x,y));
			String room2 = getRoom(getAgPos(1));

			if (isFreeOfObject(x,y)) {
			//if (isFree(x,y) && isFree(DIRTY,x,y) && isFree(FRIDGE,x,y) && isFree(CHAIR,x,y) &&
			//    isFree(CHARGER,x,y) && isFree(WASHER,x,y) && isFreeSofa(x,y) && isFreeTable(x,y) &&
			//	isFreeBed(x,y) && !room1.equals(room2)) {
			//if (hasObject(CLEAN, x, y)){
				addDirty(new Location(x,y));
			};
        }; 
		
		// This part of code will be comment on running
		for (String room : dirtyRooms.keySet()) {
    		if (dirtyRooms.get(room)>0) {
				System.out.println("La habitación: "+room+" está sucia");
			}
		}
	 }

  String getRoom(Location thing) {
		
		String byDefault = "kitchen";

		if (bath1.contains(thing)){
			byDefault = "bath1";
		};
		if (bath2.contains(thing)){
			byDefault = "bath2";
		};
		if (bedroom1.contains(thing)){
			byDefault = "bedroom1";
		};
		if (bedroom2.contains(thing)){
			byDefault = "bedroom2";
		};
		if (bedroom3.contains(thing)){
			byDefault = "bedroom3";
		};
		if (hallway.contains(thing)){
			byDefault = "hallway";
		};
		if (livingroom.contains(thing)){
			byDefault = "livingroom";
		};
		if (hall.contains(thing)){
			byDefault = "hall";
		};
		return byDefault;
	}

	boolean sit(int Ag, Location dest) { 
		Location loc = getAgPos(Ag);
		if (loc.isNeigbour(dest)) {
			setAgPos(Ag, dest);
		};
		return true;
	}

	boolean clean(int Ag) { 
		Location loc = getAgPos(Ag);
		int val;

		if (hasObject(DIRTY,loc)) {
			remove(DIRTY,loc.x,loc.y);
			
			if (bath1.contains(loc)){
				val = dirtyRooms.get("bath1");
				val--;
				dirtyRooms.put("bath1", val);
			};
			if (bath2.contains(loc)){
				val = dirtyRooms.get("bath2");
				val--;
				dirtyRooms.put("bath2", val);
			};
			if (bedroom1.contains(loc)){
				val = dirtyRooms.get("bedroom1");
				val--;
				dirtyRooms.put("bedroom1", val);
			};
			if (bedroom2.contains(loc)){
				val = dirtyRooms.get("bedroom2");
				val--;
				dirtyRooms.put("bedroom2", val);
			};
			if (bedroom3.contains(loc)){
				val = dirtyRooms.get("bedroom3");
				val--;
				dirtyRooms.put("bedroom3", val);
			};
			if (hallway.contains(loc)){
				val = dirtyRooms.get("hallway");
				val--;
				dirtyRooms.put("hallway", val);
			};
			if (hall.contains(loc)){
				val = dirtyRooms.get("hall");
				val--;
				dirtyRooms.put("hall", val);
			};
			if (livingroom.contains(loc)){
				val = dirtyRooms.get("livingroom");
				val--;
				dirtyRooms.put("livingroom", val);
			};
			if (kitchen.contains(loc)){
				val = dirtyRooms.get("kitchen");
				val--;
				dirtyRooms.put("kitchen", val);
			};
			System.out.println("Se ha limpiado suciedad en (" + loc.x + ", "+loc.y+").");
		};
		
		return true;
	}

	boolean isDirty(Location loc) { 
		return hasObject(DIRTY,loc);
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

	boolean canMoveTo (int Ag, int x, int y) {
		if (Ag < 1) {
			return (isFree(x,y) && !hasObject(FRIDGE,x,y) && !hasObject(WASHER,x,y) && !hasObject(TABLE,x,y) &&
		           !hasObject(SOFA,x,y) && !hasObject(CHAIR,x,y));
		} else { 
			return (isFree(x,y) && !hasObject(FRIDGE,x,y) && !hasObject(CHARGER,x,y) && !hasObject(WASHER,x,y) && !hasObject(TABLE,x,y));
		}
	}
	
	boolean moveLeft(int Ag) {
		Location r1 = getAgPos(Ag);
		if (canMoveTo(Ag,r1.x-1,r1.y)){
			r1.x--;
			setAgPos(Ag, r1); // move the agent in the grid 
		}
        return true;        
	}

	boolean moveRight(int Ag) {
		Location r1 = getAgPos(Ag);
		if (canMoveTo(Ag,r1.x+1,r1.y)){
			r1.x++;
			setAgPos(Ag, r1); // move the agent in the grid 
		}
        return true;        
	}
	
	boolean moveDown(int Ag) {
		Location r1 = getAgPos(Ag);
		if (canMoveTo(Ag,r1.x,r1.y+1)){
			r1.y++;
			setAgPos(Ag, r1); // move the agent in the grid 
		}
        return true;        
	}

	boolean moveUp(int Ag) {
		Location r1 = getAgPos(Ag);
		if (canMoveTo(Ag,r1.x,r1.y-1)){
			r1.y--;
			setAgPos(Ag, r1); // move the agent in the grid 
		}
        return true;        
	}

	boolean moveTowards(int Ag, Location dest) {
        Location r1 = getAgPos(Ag); 
        Location r2 = getAgPos(Ag); 
		
		if (r1.distance(dest)>0) {
			if (r1.x < dest.x && canMoveTo(Ag,r1.x+1,r1.y)) {
				r1.x++;
			}
			else if (r1.x > dest.x && canMoveTo(Ag,r1.x-1,r1.y)) {
				r1.x--;
			};
			
			if (r1.y < dest.y && r1.distance(dest)>0 && canMoveTo(Ag,r1.x,r1.y+1)) {
				r1.y++;
			}
			else if (r1.y > dest.y && r1.distance(dest)>0 && canMoveTo(Ag,r1.x,r1.y-1)) {  
				r1.y--;
			};
        };
		
		if (r1 == r2 && r1.distance(dest)>0) { // could not move the agent
			if (r1.x == dest.x && canMoveTo(Ag,r1.x+1,r1.y)) {
				r1.x++;
			}; 
			if (r1.x == dest.x && canMoveTo(Ag,r1.x-1,r1.y)) {
				r1.x--;
			};
			if (r1.y == dest.y && canMoveTo(Ag,r1.x,r1.y+1)) {
				r1.y++;
			};   
			if (r1.y == dest.y && canMoveTo(Ag,r1.x,r1.y-1)) { 
				r1.y--;
			};			
		};  
		
		setAgPos(Ag, r1); // move the agent in the grid 
		
        return true;        
    }  
}                                                                               

  
