
final class Tank{
  private float X;
  
  private final float Y = 475;
  private final int WIDTH = 100;
  private final int HEIGHT = 50;
  
  private Shell shell;

  Tank(float initX){
    this.X = initX;
    this.shell = new Shell();
  }
    
  public float getTankX(){
    return this.X;
  }
  
  public void setTankX(float tankX){
    this.X = tankX;
  }
  
  public void fire(PVector v, float strength, float angle){
    this.shell.setInMotion(true);
    this.shell.setPosition(new PVector(this.X, this.Y));
    this.shell.setAngle(angle);
    
    PVector fireForceNormal = v.sub(new PVector(this.X, this.Y)).normalize();
    PVector fireForce = fireForceNormal.mult(strength/10);
    
    this.shell.addForce(fireForce);
    this.shell.addForce(new PVector(0.5*(int)windSpeed, 0));
  }

  void draw(){
    noStroke();
    fill(#f16d7a);
    ellipse(this.X, Y, WIDTH, HEIGHT);  
    
    this.shell.draw();
  }
  
}
