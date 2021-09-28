
final class Cloud {
  private int X, weight, height;
  
  private final int Y = 125;
  
  Cloud(int initX, int initWei, int initHei){
    this.X = initX;
    this.weight = initWei;
    this.height = initHei;
  }
  
  public int getX() {
    return this.X;
  }
  
  public void setX(int x) {
    this.X = x;
  }
  
  void draw(){
    fill(255);
    this.X += windSpeed;
    ellipse(this.X,Y,this.weight,this.height);
  }
  
}
