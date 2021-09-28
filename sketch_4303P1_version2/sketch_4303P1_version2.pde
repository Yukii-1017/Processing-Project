
//values about players turn
boolean player1;
int score1;
int score2;
boolean gameOver;
boolean intro = true;

//values about value patterns
String a1 = "Strength: "+0;
String b1 = "Elevator: "+0+"°";
String a2 = "Strength: "+0;
String b2 = "Elevator: "+0+"°";

//values about tanks
Tank tank1;
Tank tank2;
float tank1X = 150;
float tank2X = 850;

// values about strength and angle
float strength = 0;
float alpha = 0;
float angle1 = 0;
float angle2 = 0;
float radiant = 0;

//values about wind force presented by cloud speed
double windSpeed = Math.floor(random(-2,2));
Cloud cloud1;
Cloud cloud2;
Cloud cloud3;
int cloud1X = 150;
int cloud2X = 100;
int cloud3X = 200;

//values about blocks
int blockY;
Block[] blocks;
final int NO_BLOCKS = 12;
boolean blockInMotion;



public void settings(){
    size(1000,600);
}




void setup(){    
    frameRate(60);
    player1 = true;
    blockInMotion = true;
    gameOver = false;
    score1 = 0;
    score2 = 0;
    
    // set tanks
    tank1 = new Tank(tank1X);
    tank2 = new Tank(tank2X);
    
    // set clouds
    cloud1 = new Cloud(cloud1X, 100,50);
    cloud2 = new Cloud(cloud2X,40,25);
    cloud3 = new Cloud(cloud3X,40,25);
    
    //set blocks
    blocks = new Block[NO_BLOCKS];
    for(int i = 0; i< 6; i++) {
      blocks[i] = new Block(200+i*100, 450);
    }
    setUpperBlocks();
}

void draw(){
    
    if(intro){
      background(255);

      noStroke();
      fill(#f16d7a);
      rect(0,400,1000,600);
         
      fill(#f16d7a);
      textSize(30); 
      textAlign(CENTER,CENTER);
      text("You can use 'A' and 'D' to control the tank on the right;", 500, 70);
      text("use 'right' and 'left' arrow keys to control the tank on the left.", 500, 120);
      text("Both tank can shot by mouse.", 500, 170);
      text("The power bars present the shotting strength,", 500, 220);
      text("and the direction of the mouse pressent the shotting angles.", 500, 270);
      text("NB: Strength less than 30 might lead you to shot yourself!", 500, 320);
      
      fill(#f1ccb8);
      textSize(35); 
      text("Press 'S' to start the game.", 500, 450);
      
      

      

      
    }else{
                background(#c3e5de);

                // draw ground level
                noStroke();
                fill(#f8c071);
                rect(0,500,1000,600);
                
                fill(255);
                textSize(26); 
                textAlign(CENTER,CENTER);
                if(player1 && score1 < 3 && score2 < 3){
                  text("Left player's turn", 500, 300);
                }else if((!player1) && (score1 < 3) && (score2 < 3)){
                  text("Right player's turn", 500, 300);
                }
                
                // draw blocks
                for(Block b: blocks) {
                  b.draw();
                  if(!blockInMotion) return;
                }
            
                //draw tanks
                tank1.draw();
                tank2.draw();
                
                // draw default value patterns and changing
                fill(#f16d7a);
                
                textSize(15); 
                text(a1,tank1.getTankX(),530);
                text(b1,tank1.getTankX(),545);  
                text(a2,tank2.getTankX(),530);
                text(b2,tank2.getTankX(),545);
                if (player1){
                  fill(#f16d7a, alpha);
                  rect(tank1.getTankX()-50, 505, strength, 10);
                  
                  fill(#f16d7a);
                  textSize(15); 
                  a1 = "Strength: "+(int)strength;
                  b1 = "Elevator: "+(int)angle1+"°";  
                }else{
                  fill(#f16d7a, alpha);
                  rect(tank2.getTankX()-50, 505, strength, 10);  
                  
                  fill(#f16d7a);
                  textSize(15); 
                  a2 = "Strength: "+(int)strength;
                  b2 = "Elevator: "+(int)angle2+"°";
                }
                
                //draw clouds
                cloud1.draw();
                cloud2.draw();
                cloud3.draw();
                if((cloud3.getX() + 20) <= 0 ){
                  cloud1.setX(1070);
                  cloud2.setX(1020);
                  cloud3.setX(1120);
                }else if((cloud2.getX() - 20) >= 1000){
                  cloud1.setX(-70);
                  cloud2.setX(-120);
                  cloud3.setX(-20);
                }
                
                // draw top bar
                stroke(255);
                fill(#f1ccb8);
                rect(0,0,500,50);
                rect(500,0,500,50);
             
                fill(#c17e61);
                textAlign(CENTER,CENTER);
                textSize(26); 
                text("Wind: "+(float)windSpeed,250,25);
                text("Score: "+score1+" VS "+score2,725,25);
                
                 
                  //collision with tanks
                      //tank1(left) shot itself through test if the shell is falling back
                      if((tank1.shell.getAngle()>=3) && tank1.shell.velocity.y >= 0  && ((tank1.shell.getShellPos().x +10) > (tank1.getTankX()-50)) 
                        && ((tank1.shell.getShellPos().x - 10) < (tank1.getTankX() + 50)) && tank1.shell.getShellPos().y > 450){
                        tank1.shell.clear();
                        score2 += 1;
                        
                      //tank1 shot tank2(right)
                      }else if((tank1.shell.getAngle()>=3) && (tank1.shell.velocity.y >= 0)  && ((tank1.shell.getShellPos().x + 10) > (tank2.getTankX()-50)) 
                            && ((tank1.shell.getShellPos().x -10) < (tank2.getTankX() + 50)) && tank1.shell.getShellPos().y > 450){
                        tank1.shell.clear();
                        score1 += 1;
                      
                      //tank2 shot itself *define the angle they won't be regart as shot themself, because velocity will decrase soon
                      }else if((tank2.shell.getAngle()>=3) && (tank2.shell.velocity.y >= 0)  && ((tank2.shell.getShellPos().x + 10) > (tank2.getTankX()-50)) 
                            && ((tank2.shell.getShellPos().x - 10) < (tank2.getTankX() + 50)) && tank2.shell.getShellPos().y > 450){
                        tank2.shell.clear();
                        score1 += 1;
                        
                      //tank2 shot tank1
                      }else if((tank2.shell.getAngle()>=3) && (tank2.shell.velocity.y >= 0)  && ((tank2.shell.getShellPos().x + 10) > (tank1.getTankX()-50)) 
                            && ((tank2.shell.getShellPos().x - 10) < (tank1.getTankX()+50)) && tank2.shell.getShellPos().y > 450){
                        tank2.shell.clear();
                        score2 += 1;
                      }
                      
                      
                //test winner
                if(score1 >= 3){
                  fill(#c17e61);
                  textAlign(CENTER,CENTER);
                  textSize(26); 
                  text("Left Player Won! Press 'R' to restart. ", 500, 300);
                  gameOver = true;
                }else if(score2 >= 3){
                  fill(#c17e61);
                  textAlign(CENTER,CENTER);
                  textSize(26); 
                  text("Right Player Won! Press 'R' to restart. ", 500, 300);
                  gameOver = true;
                }
        }  
}

//random floor
void setUpperBlocks(){
    int numSnd = (int) Math.floor(random(3,5));
    int numTrd = (int) 6 - numSnd;
    
    int[] sndFloor = new int[numSnd];
    int[] trdFloor = new int[numTrd];

    for(int i = 0; i < numSnd; i++){
      int blockx = (int) Math.floor(random(2, 8))*100; 
      blockY = 400;  
      
      sndFloor[i] = blockx;
      blocks[6+i] = new Block(blockx, blockY);
    }
    
    for(int i = 0; i < numTrd; i++) {
      int basex = sndFloor[i];
      blockY = 350;
      
      trdFloor[i] = basex;
      blocks[6+numSnd+i] = new Block(basex, blockY);
    }   
}


//tanks move
void keyPressed(){
  if(intro){
    if(key == 'S' || key == 's'){intro = false;}
  }
  
  if(gameOver){
    if (key == 'r' || key == 'R'){
      setup();
    }else{return;}
  }
  
  if((key == 'a' || key == 'A') && (tank1.getTankX() - 50  > 0) ){
      tank1.setTankX(tank1.getTankX() - 10);
  }else if((key == 'd' || key == 'D') && (tank1.getTankX() + 50  < 200)){
      tank1.setTankX(tank1.getTankX() + 10);
  }else if((keyCode == LEFT) && (tank2.getTankX() - 50  > 800)){
      tank2.setTankX(tank2.getTankX() - 10);
  }else if((keyCode == RIGHT) && (tank2.getTankX() + 50  < 1000) ){
      tank2.setTankX(tank2.getTankX() + 10);
  }
  
  
}

//press and draw a line to the shotting direction to get strength and angle 
void mouseDragged(){
  if(gameOver) return;
  
  strength = strength + 1;
  if(strength >= 100){strength = 100;}
  alpha = alpha + 1;
  
  if(player1){
      radiant = acos((mouseX - tank1.getTankX())/sqrt((mouseX - tank1.getTankX())*(mouseX - tank1.getTankX())+(mouseY - 475)*(mouseY - 475)));

  }else{
      radiant = acos((mouseX - tank2.getTankX())/sqrt((mouseX - tank2.getTankX())*(mouseX - tank2.getTankX())+(mouseY - 475)*(mouseY - 475)));
  }  

  angle1 = (float)degrees(radiant);
  angle2 = (float)degrees(PI - radiant);
  if(mouseY > 475){angle1 = 0; angle2 = 0;};
}


void mouseReleased(){
  if(gameOver) return;
  
  PVector mouse = new PVector(mouseX, mouseY);
  
  if(player1){
    tank1.fire(mouse, strength, angle1);
  }else{
    tank2.fire(mouse, strength, angle2);
  }  
  
  println(tank1.shell.getAngle(), tank2.shell.getAngle());
  
  strength = 0;
  alpha = 0;
  angle1 = 0;
  angle2 = 0;
  player1 = !player1;
}
