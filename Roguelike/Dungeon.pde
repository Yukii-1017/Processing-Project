final int WALL_WIDTH = 20;
final int DOOR_WIDTH = 60;

enum WALLTYPE {
  WALL,
  DOOR,
  ENTRANCE,
  STAIR,
  TREASURE
}

class Dungeon {
  
  // Inner wall class, only used in collision detection
  class Wall {
    PVector wpoint;
    float wwidth;
    float wheight;
    WALLTYPE wtype;
    
    Wall(float x, float y, float w, float h, WALLTYPE wt) {
      this.wpoint = new PVector(x, y);
      this.wwidth = w;
      this.wheight = h;
      this.wtype = wt;
    }
    
    boolean inWallRange(PVector v) {
      float x1 = wpoint.x;
      float x2 = wpoint.x+wwidth;
      float y1 = wpoint.y;
      float y2 = wpoint.y+wheight;
      
      boolean inX = (v.x >= x1) && (v.x <= x2);
      boolean inY = (v.y >= y1) && (v.y <= y2);
      
      return inX && inY;
    }
    
    PVector getCoor() {
      return this.wpoint.copy();
    }
    
    void draw() {
      if(wtype == WALLTYPE.DOOR) {
        stroke(#FFFFFF);
        fill(#F98B88);
      }else if (wtype == WALLTYPE.STAIR){
        fill(0);
      }else if(wtype == WALLTYPE.ENTRANCE){
        fill(#FFFFFF);
      }else if(wtype == WALLTYPE.TREASURE) {
        fill(#DAA520);
      }
      rect(wpoint.x,wpoint.y, wwidth,wheight);
    }
  }
  
  private int dx;
  private int dy;
  private PVector point1;
  private PVector point2a;
  private PVector point2b;
  private ArrayList<Wall> walls;
  private ArrayList<Wall> doors;
  private Wall entrance;
  private Wall stair;
  private Wall treasure;
  private boolean treasureExist;

  Dungeon(){
    // First cross-point
    this.point1 = new PVector(400+WALL_WIDTH+(int)Math.floor(random(10, 20))*WALL_WIDTH, (int)Math.floor(random(10, 20))*WALL_WIDTH);
    // Second cross-points
    this.dx = (int)Math.floor(random(4, 8))*WALL_WIDTH;
    this.dy = (int)Math.floor(random(4, 8))*WALL_WIDTH;
    this.point2a = new PVector(point1.x-dx, point1.y-dy);
    this.point2b = new PVector(point1.x+dx, point1.y+dy);
    
    this.walls = new ArrayList<Wall>();
    this.doors = new ArrayList<Wall>();
    
    this.treasureExist = true;
    
    // Outer boundaries
    walls.add(new Wall(400,0, WALL_WIDTH,600, WALLTYPE.WALL));
    walls.add(new Wall(1000-WALL_WIDTH,0, WALL_WIDTH,600, WALLTYPE.WALL));
    walls.add(new Wall(400,0, 600,WALL_WIDTH, WALLTYPE.WALL));
    walls.add(new Wall(400,600-WALL_WIDTH, 600,WALL_WIDTH, WALLTYPE.WALL));
    
    // Cross-point walls
    walls.add(new Wall(point1.x,WALL_WIDTH, WALL_WIDTH,600-WALL_WIDTH, WALLTYPE.WALL)); // Ver.
    walls.add(new Wall(400+WALL_WIDTH,point1.y, 600,WALL_WIDTH, WALLTYPE.WALL)); // Hor.
    
    // 2nd level cross-point walls
    if (point1.x > 700) { // Left > right
      if(point1.y > 300) { // Up > bottom
        // LU
        walls.add(new Wall(point2a.x,WALL_WIDTH, WALL_WIDTH,point1.y, WALLTYPE.WALL));
        walls.add(new Wall(400+WALL_WIDTH,point2a.y, point1.x-400-WALL_WIDTH,WALL_WIDTH, WALLTYPE.WALL));
        
        doors.add(new Wall(500-DOOR_WIDTH/2+point1.x/2,point1.y, DOOR_WIDTH,WALL_WIDTH, WALLTYPE.DOOR));
        doors.add(new Wall(point1.x,300-DOOR_WIDTH/2+point1.y/2, WALL_WIDTH,DOOR_WIDTH, WALLTYPE.DOOR));
        
        doors.add(new Wall(point2a.x+(dx+WALL_WIDTH)/2-DOOR_WIDTH/2,point2a.y, DOOR_WIDTH,WALL_WIDTH, WALLTYPE.DOOR));
        doors.add(new Wall(point2a.x, (point2a.y+WALL_WIDTH)/2-DOOR_WIDTH/2, WALL_WIDTH, DOOR_WIDTH, WALLTYPE.DOOR));
        doors.add(new Wall(400+(point2a.x+WALL_WIDTH-400)/2-DOOR_WIDTH/2,point2a.y, DOOR_WIDTH,WALL_WIDTH, WALLTYPE.DOOR));
        doors.add(new Wall(400+(point2a.x+WALL_WIDTH-400)/2-DOOR_WIDTH/2,point1.y, DOOR_WIDTH,WALL_WIDTH, WALLTYPE.DOOR)); 
        
        //in/out    
        entrance = new Wall(point1.x+(1000-point1.x-WALL_WIDTH)/2,point1.y+(600-point1.y-WALL_WIDTH)/2, WALL_WIDTH,WALL_WIDTH, WALLTYPE.ENTRANCE);
        stair = new Wall(point2a.x+dx/2,point2a.y+dy/2, WALL_WIDTH,WALL_WIDTH, WALLTYPE.STAIR);

    } else { // Bottom > up
        // LB
        walls.add(new Wall(point2a.x,point1.y, WALL_WIDTH,600-WALL_WIDTH-point1.y, WALLTYPE.WALL));
        walls.add(new Wall(400+WALL_WIDTH,point2b.y, point1.x-400-WALL_WIDTH,WALL_WIDTH, WALLTYPE.WALL));
        
        doors.add(new Wall(500-DOOR_WIDTH/2+point1.x/2,point1.y, DOOR_WIDTH,WALL_WIDTH, WALLTYPE.DOOR));
        doors.add(new Wall(point1.x,(point1.y+ WALL_WIDTH)/2-DOOR_WIDTH/2, WALL_WIDTH,DOOR_WIDTH, WALLTYPE.DOOR));
        
        doors.add(new Wall(point2a.x,point1.y+(dy+WALL_WIDTH)/2-DOOR_WIDTH/2, WALL_WIDTH,DOOR_WIDTH, WALLTYPE.DOOR));
        doors.add(new Wall(400+(point2a.x+WALL_WIDTH-400)/2-DOOR_WIDTH/2,point2b.y, DOOR_WIDTH,WALL_WIDTH, WALLTYPE.DOOR));
        doors.add(new Wall(point2a.x,point2b.y+(600-point2b.y)/2-DOOR_WIDTH/2, WALL_WIDTH, DOOR_WIDTH, WALLTYPE.DOOR));
        doors.add(new Wall(point1.x,point2b.y+(600-point2b.y)/2-DOOR_WIDTH/2, WALL_WIDTH, DOOR_WIDTH, WALLTYPE.DOOR)); 
        
        //in/out    
        entrance = new Wall(point1.x+(1000-point1.x-WALL_WIDTH)/2,point1.y/2, WALL_WIDTH,WALL_WIDTH, WALLTYPE.ENTRANCE);
        stair = new Wall(point2a.x+dx/2,point1.y+dy/2, WALL_WIDTH,WALL_WIDTH, WALLTYPE.STAIR);
      }
    } else { // Right > Left
      if(point1.y > 300) { // Up > bottom
        // RU
        walls.add(new Wall(point2b.x,WALL_WIDTH, WALL_WIDTH,point1.y, WALLTYPE.WALL));
        walls.add(new Wall(point1.x,point2a.y, 1000-point1.x,WALL_WIDTH, WALLTYPE.WALL));
        
        doors.add(new Wall(400+(point1.x-400+WALL_WIDTH)/2-DOOR_WIDTH/2, point1.y, DOOR_WIDTH,WALL_WIDTH, WALLTYPE.DOOR));
        doors.add(new Wall(point1.x,300-DOOR_WIDTH/2+point1.y/2, WALL_WIDTH,DOOR_WIDTH, WALLTYPE.DOOR));
        
        doors.add(new Wall(point2b.x,point2a.y+(dy+WALL_WIDTH)/2-DOOR_WIDTH/2, WALL_WIDTH,DOOR_WIDTH, WALLTYPE.DOOR));
        doors.add(new Wall(point2b.x+(1000-point2b.x)/2-DOOR_WIDTH/2,point2a.y, DOOR_WIDTH,WALL_WIDTH, WALLTYPE.DOOR));
        doors.add(new Wall(point2b.x, (point2a.y+WALL_WIDTH)/2-DOOR_WIDTH/2, WALL_WIDTH,DOOR_WIDTH, WALLTYPE.DOOR));
        doors.add(new Wall(point1.x,(point2a.y+WALL_WIDTH)/2-DOOR_WIDTH/2, WALL_WIDTH,DOOR_WIDTH, WALLTYPE.DOOR)); 
        
        //in/out    
        entrance = new Wall(400+(point1.x-400)/2,point1.y+(600-point1.y-WALL_WIDTH)/2, WALL_WIDTH,WALL_WIDTH, WALLTYPE.ENTRANCE); 
        stair = new Wall(point1.x+dx/2,point1.y-dy/2, WALL_WIDTH,WALL_WIDTH, WALLTYPE.STAIR);
      } else { // Bottom > up
        // RB
        walls.add(new Wall(point2b.x,point1.y, WALL_WIDTH,600-WALL_WIDTH-point1.y, WALLTYPE.WALL));
        walls.add(new Wall(point1.x,point2b.y, 1000-point1.x,WALL_WIDTH, WALLTYPE.WALL));
        
        doors.add(new Wall(400+(point1.x-400+WALL_WIDTH)/2-DOOR_WIDTH/2, point1.y, DOOR_WIDTH,WALL_WIDTH, WALLTYPE.DOOR));
        doors.add(new Wall(point1.x,(point1.y+ WALL_WIDTH)/2-DOOR_WIDTH/2, WALL_WIDTH,DOOR_WIDTH, WALLTYPE.DOOR));
        
        doors.add(new Wall(point1.x+(dx+WALL_WIDTH)/2-DOOR_WIDTH/2,point2b.y, DOOR_WIDTH,WALL_WIDTH, WALLTYPE.DOOR));
        doors.add(new Wall(point2b.x,point2b.y+(600-point2b.y)/2-DOOR_WIDTH/2, WALL_WIDTH,DOOR_WIDTH, WALLTYPE.DOOR));
        doors.add(new Wall(point2b.x+(1000-point2b.x)/2-DOOR_WIDTH/2,point2b.y, DOOR_WIDTH,WALL_WIDTH, WALLTYPE.DOOR));
        doors.add(new Wall(point2b.x+(1000-point2b.x)/2-DOOR_WIDTH/2, point1.y, DOOR_WIDTH,WALL_WIDTH, WALLTYPE.DOOR)); 
        //in/out    
        entrance = new Wall(400+(point1.x-400)/2,point1.y/2, WALL_WIDTH,WALL_WIDTH, WALLTYPE.ENTRANCE);
        stair = new Wall(point1.x+dx/2,point1.y+dy/2, WALL_WIDTH,WALL_WIDTH, WALLTYPE.STAIR);
      }
    }
    
    treasure = new Wall(random(21,49)*20, random(1,19)*20, WALL_WIDTH,WALL_WIDTH, WALLTYPE.TREASURE);
  }
  
  //
  boolean isCollided(PVector position) {
    for(Wall d: doors) {
      if(d.inWallRange(position)) return false;
    }
    
    for(Wall w: walls) {
      if(w.inWallRange(position)) return true;
    }
    
    return false;
  }
  
  PVector getEntrance() {
    return this.entrance.getCoor();
  }
  
  PVector getStair() {
    return this.stair.getCoor();
  }
  
  PVector getTreasure() {
    return this.treasure.getCoor();
  }
  
  boolean isTreasureExist() {
    return this.treasureExist;
  }
  
  void loot() {
    this.treasureExist = false;
  }

  void draw(){
    // Grid
    stroke(#FFFFFF);
    for(int i = 0; i <= 600; i += WALL_WIDTH) {
      line(400,i, 1000,i);
      line(400+i,0, 400+i,600);
    }
    
    // Outer boundaries
    noStroke();
    fill(#A4D792);
    
    // Walls
    for(Wall w: walls) {
      w.draw();
    }
    
    // Doors
    fill(#000000);
    for(Wall d: doors) {
      d.draw();
    }
    
    entrance.draw();
    stair.draw();
    if(treasureExist) treasure.draw();
  }
  
}
