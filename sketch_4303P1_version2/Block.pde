
final class Block{
  private PVector position;
  
  private boolean inDisplay;
  
  private final int weight = 100;
  private final int height = 50;
  
  Block(int initX, int initY){
    this.position = new PVector(initX, initY);
    this.inDisplay = true;
  }
  
  public PVector getBlockPos(){
    return this.position;
  }
  
  boolean isInDisplay () {
    return this.inDisplay;
  }
  
  public void clear() {
    this.inDisplay = false;
  }
  
  void draw(){
    if(!this.inDisplay) return;
    
    fill(#9ac867);
    stroke(255);
    rect(this.position.x, this.position.y, weight, height);
  }
}
