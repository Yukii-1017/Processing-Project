final class Star{
  public int starSize;
  private boolean inDisplay, beBoom, isMovingRight, isMovingLeft, isMissileRight, isMissileLeft, isScoreStar, isRebornStar;
  private PVector position, velocity;
  private final float FORCE = 0.99;
  private final float DAMPING = .97;
  private final PVector GRAVITY = new PVector(0, -.098); 
  
   Star(){
     this.starSize = 60;
     this.velocity = new PVector(0, 15) ;
     this.inDisplay = true;
     this.beBoom = false; 
     this.isMovingRight = false;
     this.isMovingLeft = false;
     this.isMissileRight = false;
     this.isMissileLeft = false;
     this.isScoreStar = false;
     this.isRebornStar = false;
   }
   
   
   void integrate(PVector direction) { 
      this.position.add(velocity) ;
      direction.mult(FORCE);
      this.velocity.add(direction);
      this.velocity.add(GRAVITY) ;
      this.velocity.mult(DAMPING) ;  
    } 
    
    void drawing(int i, PVector position){
      this.position = position;
      if(inDisplay){
        
            if(i < 10 && !beBoom && !isMissileLeft && !isMissileRight && !isScoreStar && !isRebornStar){
              image(starImg, position.x, position.y, starSize+starSize/4, starSize);
            }
            
            if(beBoom){
              image(boomImg, position.x, position.y, starSize+starSize/2, starSize);
            }
            
            if(isMovingRight){
              image(starImg, position.x, position.y, starSize+starSize/4, starSize);
              this.position.x++;
              if(this.position.x > 550 || this.position.x < 50){
                this.position.x = -this.position.x;
                isMovingRight = false;
                isMovingLeft = true;
              }
            }
            
            if(isMovingLeft){
              image(starImg, position.x, position.y, starSize+starSize/4, starSize);
              this.position.x--;
              if(this.position.x > 550 || this.position.x < 50){
                this.position.x = -this.position.x;
                isMovingRight = true;
                isMovingLeft = false;
              }
            }
            
            if(isMissileRight){
              image(missileRightImg, position.x, position.y, starSize+starSize/2, starSize);
              this.position.x++;
              if(this.position.x > 450 || this.position.x < 150){
                this.position.x = -this.position.x;
                this.isMissileRight = false;
                this.isMissileLeft = true;
              }
            }
            
            if(isMissileLeft){
              image(missileLeftImg, position.x, position.y, starSize+starSize/2, starSize);
              this.position.x--;
              if(this.position.x > 450 || this.position.x < 150){
                this.position.x = -this.position.x;
                this.isMissileRight = true;
                this.isMissileLeft = false;
              }
            }
            
            if(isScoreStar){
              image(scoreStarImg, position.x, position.y, starSize, starSize);
              fill(255);
              textSize(20);
              text("Score +100", position.x+90, position.y);
            }
            
            if(isRebornStar){
              image(rebornStarImg, position.x, position.y, starSize, starSize);
              fill(255);
              textSize(20);
              text("Reborn +1", position.x+70, position.y);
            }
      
            if(i == 10){
              // 30 is sued to make up the gap between real ground size and the ground picture size
              image(groundImg, position.x, position.y, WIDTH, GROUND_HEIGHT+30);
            }
      }      
    }
}
