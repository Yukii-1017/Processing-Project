
final class Shell{
  
  private PVector position, velocity;//strength is acceleration given by players
  private float angle;
  private boolean inMotion;
  
  Shell() {
    this.position = new PVector(0,0);
    this.velocity = new PVector(0,0);
    this.angle = 0;
    this.inMotion = false;
  }
  
  public PVector getShellPos(){
    return this.position;
  }
  
  public void setShellPos(PVector shellPos){
    this.position = shellPos;
  }
  
  public void setAngle(float angle) {
    this.angle = angle;
  }
  
  public float getAngle(){
    return this.angle;
  }
  
  void integrate() {
    this.position.add(velocity) ;
    
    this.velocity.sub(new PVector(0, -0.098));
  }
  
  void setPosition(PVector v) {
    this.position.set(v);
  }
  
  void setInMotion(boolean b) {
    this.inMotion = b;
  }
  
  public void clear() {
    this.inMotion = false;
    this.position = new PVector(0, 0);
    this.velocity = new PVector(0, 0);
  }
  
  void addForce(PVector v) {
    this.velocity.add(v);
  } 
  
  void draw() {
      if(!this.inMotion) return;
      
      fill(#f16d7a);    
      ellipse(this.position.x, this.position.y,20,10);
    
      this.integrate() ;
      
      if(this.position.x <= 0 || this.position.x >= 1000 || this.position.y >= 500) {
        this.clear();
      }      
       
      //collision wiht blocks, becasue I want to aviod to distinguish shells drom different side
      for(Block b: blocks) {
        if(!b.isInDisplay()) continue;
        
        if( (b.getBlockPos().x < this.position.x+10) && (b.getBlockPos().x+100 > this.position.x - 10)
            && (b.getBlockPos().y < this.position.y-5)){ 
          this.clear();
          b.clear();
          //println("block disappear",b.position);
        } else {
          //println("here");
        }
        
      }

      
      
   }
   
   
   
}
