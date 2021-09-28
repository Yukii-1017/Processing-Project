/*
This is the code for CS4303 Practical4
*/
// ===== MAIN VARIABLES ===== 
//started and spaceCounter is used to prevent moving player before game start
public int playerSize, height, maxHeight, starCounter, spaceCounter, score, finalStar, reburnStarCounter, scoreStarCounter, test = 0;
public boolean started, gameOver, spacePressed, intro, pause, canReborn, notReborn, soundPause, backgroundFlag, restart; 
public PVector playerPos, direction, groundPos; 
float[] gapFlag = new float[16];
public final int WIDTH = 600, HEIGHT = 800,  
                  INTRO_BUTTON_WIDTH = 70, INTRO_BUTTON_HEIGHT = 30, 
                   GROUND_HEIGHT = 300,
                  PLAYER_SIZE = 20;//screen, button and player
// ===== CLASSES ===== 
Star[] stars;
PVector[] starPos = new PVector[16];
public int star_no = 10;
public int heightGap;
// ===== IMAGES AND MUSICS ===== 
public PImage introImg, starImg, groundImg, boomImg, missileRightImg, missileLeftImg, scoreStarImg, rebornStarImg, pauseImg, soundPauseImg, soundPlayImg, playerImg;
import ddf.minim.*;
Minim minim;
AudioPlayer startSound;//pong
AudioPlayer backgroundSound;//pong
AudioPlayer catchedSound;//ding
AudioPlayer goodStarSound;//cheer
AudioPlayer boomSound;//boom
AudioPlayer gameoverSound;//pong


void setup () {
// ===== MAIN SETUP ===== 
  size(600, 800) ;
  ellipseMode(CENTER);
  rectMode(CENTER);
  imageMode(CENTER);
  textAlign(CENTER, CENTER);
  spaceCounter = 0;
  score = 0;
  height = 0;
  maxHeight = 0;
  reburnStarCounter = 0;
  scoreStarCounter = 0;
  playerPos = new PVector(300, 490);
  playerSize = 20;
  groundPos = new PVector (WIDTH/2, 650);
  direction = new PVector (0,1);
// ===== MOUSE EVENT SETUP ===== 
  gameOver = false;
  spacePressed = false;
  intro = true;
  started = false;
  pause = false;
  notReborn = false;
  soundPause = false;
  canReborn = false;
  backgroundFlag = false;
  restart = false;
// ===== CLASSES SETUP ===== 
  stars = new Star[star_no+1]; 
  starPos[0] = new PVector (300 + (int)random(-200, 200), (int)random(780, 800));
  stars[0] = new Star();
  for (int i = 1; i < star_no; i++){
    stars[i] = new Star();
    heightGap = 800/star_no;
    starPos[i] = new PVector (300 + (int)random(-200, 200), starPos[i-1].y - heightGap - (int)random(-15, 15));
    // in case of crossing the ground 
    if(starPos[i].y > (500-stars[i].starSize) && starPos[i].y < (500+stars[i].starSize/2) ){
        starPos[i].y -= stars[i].starSize*2;
    }
  }
  stars[10] = new Star();
// ===== IMAGES AND MUSICS SETUP===== 
  // all images resources from: https://huaban.com/
  starImg = loadImage("star.png");
  groundImg = loadImage("ground.png");
  boomImg = loadImage("boom.png");
  missileRightImg = loadImage("missileRight.png");
  missileLeftImg = loadImage("missileLeft.png");
  scoreStarImg = loadImage("scoreStar.png");
  rebornStarImg = loadImage("rebornStar.png");
  introImg = loadImage("intro.png");
  pauseImg = loadImage("pause.png");
  soundPauseImg = loadImage("soundPause.png");
  soundPlayImg = loadImage("soundPlay.png");
  playerImg = loadImage("player.png");
  //all music resource from: https://www.epidemicsound.com/music/search/?moods=Romantic&term=funny
  minim = new Minim(this);
  backgroundSound = minim.loadFile("background.mp3");//light music
  catchedSound = minim.loadFile("catched.mp3");//ding
  goodStarSound = minim.loadFile("goodStar.mp3");//cheer
  boomSound = minim.loadFile("boom.mp3");//boom
  gameoverSound = minim.loadFile("gameOver.mp3");//pong
  startSound = minim.loadFile("start.mp3");
}



// ===== Utilities ===== 
void newStar(int i ){
  //initialize
  stars[i].inDisplay = true;
  stars[i].beBoom = false; 
  stars[i].isMovingRight = false;
  stars[i].isMovingLeft = false;
  stars[i].isMissileRight = false;
  stars[i].isMissileLeft = false;
  stars[i].isScoreStar = false;
  stars[i].isRebornStar = false;
  
  if(i == 0){
    starPos[0] = new PVector (300 + (int)random(-200, 200), starPos[9].y - 80 + (int)random(-15, 15));
  }else if ( 0 < i && i < 10){
    starPos[i] = new PVector (300 + (int)random(-200, 200), starPos[i-1].y - 80 + (int)random(-15, 15)); 
  }
  
  if(i != 10){
    stars[i].drawing(i, starPos[i]);
    stars[i].integrate(direction);    
  }
  
  // the flag makes sure each effect has ten persent chance to appear; and can add other randomflag to change the posibility
  int obsticalFlag = (int) random(0, 11);
  //some of the stars or obsticles will become smaller when climb to 1500
  if(height > 1500 && obsticalFlag == 0){
    stars[i].starSize = 40;
  }else{
    stars[i].starSize = 60;  
  }
  
  // there will be scored stars after 1500; 
  int scoreStarFlag = (int)random(0, 4);
  if(height > 1500 && obsticalFlag == 1 && scoreStarFlag == 0){
    stars[i].isScoreStar = true;
    score += 100;
  }
  
  //some stars will become booms when climb to 3000
  int boomFlag = (int)random(0,7);
  if(height > 3000 && obsticalFlag == 2 && boomFlag == 0){
    stars[i].beBoom = true;
  }
  
  // some stars start to moving when climb to 6000
  int movingFlag = (int)random(0,2);
  if(height > 6000 && obsticalFlag == 3 && movingFlag == 0 ){
    stars[i].isMovingRight = true;
  }else if(height > 0 && obsticalFlag == 3  && movingFlag == 1){
    stars[i].isMovingLeft = true;
  }
  
  // some stars become moving missiles which can not be touched when climb to 9000,
  int missileFlag = (int)random(0,7);
  if(height > 9000 && obsticalFlag == 4 && missileFlag == 0){
    stars[i].isMissileRight = true;
  }else if(height > 9000 && obsticalFlag == 4  && missileFlag == 1){
    stars[i].isMissileLeft = true;
  }
  
  // very rare star
  int reburnStarFlag = (int)random(0,21);
  if (obsticalFlag == 5 && reburnStarFlag == 0){
    stars[i].isRebornStar = true;
  } 
}

void newForce(){
  for(int i = 0; i < star_no+1; i++){
    stars[i]. velocity = new PVector(0, 15);
  }
}

void intro(){
  background(#00206A);
  textSize(20);
  fill(255);
  text("Press 'Space' to skip intro, press again to start jump!", WIDTH/2, 100, 300, 300);
  
  textSize(17);
  image(starImg, WIDTH/4-50, 200,  75, 60);//normal
  text("Catch the normal star to keep jump", WIDTH/4+150, 200);
  
  image(boomImg, WIDTH/4+50, 270, 90, 60);//boom
  text("Boom leads to death", WIDTH/4+180, 270);
  
  image(starImg, WIDTH/4+100, 340, 75, 60);//moving
  text("Well it is moving", WIDTH/4+220, 340);
  
  image(starImg, WIDTH/4-25, 580, 50, 40);//small
  text("Land more precision", WIDTH/4+100, 580);
  
  image(missileRightImg, WIDTH/4+30, 640, 90, 60);//missile
  text("Missile also leads to death, like a moving boom", WIDTH/4+200, 680);
  
  image(scoreStarImg, WIDTH/4-80, 450, 60, 60);//score
  text("100 score!", WIDTH/4+20, 450);
  
  image(rebornStarImg, WIDTH/4+75, 500, 60, 60);//reborn
  text("Give you one more chance to reburn", WIDTH/4+260, 500);
  
}

void pause(){
  image(pauseImg, WIDTH/2, HEIGHT/2, 300, 300);
  textSize(30) ;
  fill(255);
  text("Press 'Space' to restart", WIDTH/2, HEIGHT/2-200);
}

void rebornTag(){
  fill(255, 0, 0);
  rect(WIDTH/2, HEIGHT/2, 350, 150);
  fill(#8b0000);
  rect(WIDTH/2-70, HEIGHT/2 + 40, 50, 30);
  rect(WIDTH/2+70, HEIGHT/2 + 40, 50, 30);
  fill(255);
  textSize(20) ;
  text("Do you want to use a reborn star and reborn?", WIDTH/2, HEIGHT/2-30, 300, 300);
  text("Yes", WIDTH/2-70, HEIGHT/2 + 36);
  text("No", WIDTH/2+70, HEIGHT/2 + 36);
}

void gameOver(){
  if(!soundPause){gameoverSound.play();}
  background(#00206A);
  fill(255,255,255);
  textSize(24) ;
  text("GAMEOVER", WIDTH/2, HEIGHT/2-60);
  textSize(20) ;
  text("Score: " + score, WIDTH/2, HEIGHT/2-30);
//  if(){
  //  text("Congraduation to make the hightest score!" , WIDTH/2, HEIGHT/2+30);
  //}
  text("Press 'Space' to restart the game.", WIDTH/2, HEIGHT/2+30);
}

void gameReset(){
  stars = new Star[star_no+1]; 
  starPos[0] = new PVector (300 + (int)random(-200, 200), (int)random(780, 800));
  stars[0] = new Star();
  for (int i = 1; i < star_no; i++){
    stars[i] = new Star();
    heightGap = 800/star_no;
    starPos[i] = new PVector (300 + (int)random(-200, 200), starPos[i-1].y - heightGap - (int)random(-15, 15));
    // in case of crossing the ground 
    if(starPos[i].y > (500-stars[i].starSize) && starPos[i].y < (500+stars[i].starSize/2) ){
        starPos[i].y -= stars[i].starSize*2;
    }
  }
  stars[10] = new Star();
  
  spaceCounter = 0;
  score = 0;
  height = 0;
  maxHeight = 0;
  reburnStarCounter = 0;
  scoreStarCounter = 0;
  playerPos = new PVector(300, 490);
  playerSize = 20;
  groundPos = new PVector (WIDTH/2, 650);
  direction = new PVector (0,1);
  gameOver = false;
  spacePressed = false;
  intro = true;
  started = false;
  pause = false;
  notReborn = false;
  soundPause = false;
  canReborn = false;
  backgroundFlag = false;
  restart = false;
}

void soundPause(){
  catchedSound.pause();
  goodStarSound.pause();
  boomSound.pause();
  gameoverSound.pause();
  startSound.pause();
  backgroundSound.pause();
}

void backgroundSound(){
  backgroundSound.loop();
}




void draw () {  
// ===== INTRO & GAME OVER SCREEN ===== 
  background(#00206A);

  if(gameOver){
    started = false;
    restart = true;
    if(reburnStarCounter > 0){
      canReborn = true;
      gameOver = false;
    }else{
      gameOver();
    }
  }        
  
  if(canReborn){rebornTag();}
  if(notReborn){gameOver();}
  
  if(intro){intro();}
  if(pause){pause();}
  if(!soundPause && !backgroundFlag){
      backgroundFlag = true; 
      backgroundSound();
    }
  /*  
  if(!soundPause && )
      boomSound.loop();
  goodStarSound.loop();
  catchedSound.loop();
  */
  
  if(soundPause){
      image(soundPauseImg, WIDTH-55, 155, 55, 50);
      soundPause();
    }else{
      image(soundPlayImg, WIDTH-55, 155, 55, 50);
    }


  if(started){
      // ===== SCREEN DRAW ===== 
        fill(255, 0, 0);
        rect(WIDTH-INTRO_BUTTON_WIDTH+15, INTRO_BUTTON_HEIGHT, INTRO_BUTTON_WIDTH, INTRO_BUTTON_HEIGHT);  //intro button
        rect(WIDTH-INTRO_BUTTON_WIDTH+15, INTRO_BUTTON_HEIGHT*2.3, INTRO_BUTTON_WIDTH, INTRO_BUTTON_HEIGHT);  //pause button
        rect(WIDTH-INTRO_BUTTON_WIDTH+15, INTRO_BUTTON_HEIGHT*3.6, INTRO_BUTTON_WIDTH, INTRO_BUTTON_HEIGHT);  //restart button
        //ellipse(playerPos.x, playerPos.y, playerSize, playerSize);
        image(playerImg, playerPos.x, playerPos.y-8, 40, 45);// player
        
        fill(255);
        textSize(13) ;
        textAlign(CENTER, CENTER);
        text("TUTORIAL", WIDTH-INTRO_BUTTON_WIDTH+15, INTRO_BUTTON_HEIGHT-2);  //intro text
        text("PAUSE", WIDTH-INTRO_BUTTON_WIDTH+15, INTRO_BUTTON_HEIGHT*2.3-2);  //pause text
        text("RESTART", WIDTH-INTRO_BUTTON_WIDTH+15, INTRO_BUTTON_HEIGHT*3.6-2);  //restart text
        textSize(15) ;
        textAlign(CORNER, CORNER);
        text("Score: " + score, 30, 30);
        text("Stars: " + starCounter, 30, 50);
        text("Height: " + maxHeight, 30, 70);
        text("Reburn: " + reburnStarCounter, 30, 90);
        textAlign(CENTER, CENTER);

      // ===== CLASS DRAW & COLLISION ===== 
       //draw stars
        for(int i = 0; i < star_no; i++){
          stars[i].drawing(i, starPos[i]);
          // add force
          if(spacePressed){stars[i].integrate(direction);}
          
          //collision with the star or obsticals 
          if(dist(starPos[i].x, starPos[i].y, playerPos.x, playerPos.y) < (stars[i].starSize/2 + playerSize/2)
                  && stars[i].inDisplay && !stars[i].beBoom && !stars[i].isMissileRight && !stars[i].isMissileLeft){
                    
                  starCounter ++;
                  stars[i].inDisplay = false;
                  newForce(); 
                  
                  if(stars[i].isRebornStar){
                    reburnStarCounter++;
                  }else if (stars[i].isScoreStar) {
                    scoreStarCounter ++;
                  }
                       
                  if(!soundPause){
                    if(stars[i].isMissileLeft || stars[i].isMissileRight || stars[i].beBoom){
                      boomSound.rewind();
                    }else if(stars[i].isRebornStar || stars[i].isScoreStar){
                      goodStarSound.rewind();
                    }else{
                      catchedSound.rewind();
                    }
                  }
            
          }else if(dist(starPos[i].x, starPos[i].y, playerPos.x, playerPos.y) < (stars[i].starSize/2 + playerSize/2) && stars[i].inDisplay && 
                  (stars[i].beBoom || stars[i].isMissileRight ||  stars[i].isMissileLeft)
          
          ){
            gameOver = true;
            break;
          }  
      
          //out of boundry and generate new stars
          if (stars[i].position.y > 800){
            newStar(i);
            /*
            if(i == 0){
              finalStar = 9;
            }else{
              finalStar = i-1;
            }
            */
          }
          
          //count the height and score, and condition of fall down death
            height = (int)(groundPos.y-700);
            if(maxHeight < height ){
              score = (int)(height*0.1) + starCounter*10 + scoreStarCounter*90;
              maxHeight = height;
            }else{
              score = (int)(maxHeight*0.1) + starCounter*10 + scoreStarCounter*90;
            }
            
            //player fall down for while then game over
            if(maxHeight - height > 300){
              gameOver = true;
            }
        }
        
       //draw ground
        stars[10].drawing(10, groundPos);
        if(spacePressed){stars[10].integrate(direction);}
        
        //collision with edge and the ground and gameOver()
        if(playerPos.x > 600 || playerPos.x < 0 || playerPos.y + 10 > stars[10].position.y -150){
          gameOver = true;
        }
    }
}






void keyPressed () {
  if (keyCode == ' '){
    spaceCounter++;

    if(intro){
      intro = false;
      started = true;
      //loop();
      if(groundPos.y == 650){spaceCounter = 1;
      }else{spaceCounter = 2;}
    }
    
    if(pause){
      pause = false;
      started = true;
      if(groundPos.y == 650){spaceCounter = 1;
      }else{spaceCounter = 2;}
    }

    if(spaceCounter == 1){
        started = true;
        if(!soundPause){startSound.play();}
    }else if(keyCode == ' ' && spaceCounter > 1){
        spacePressed = true;
    }   
    
    //game over then press space to restart game
    if(restart){
      gameReset();
    }
  }
  
  if (keyCode == LEFT && started){
    playerPos.x -= 20;
  }else if(keyCode == RIGHT  && started){
    playerPos.x += 20;
  }
}



void  mouseReleased(){
  
  // buttons
  if(started && mouseX > (WIDTH - INTRO_BUTTON_WIDTH -20) && mouseX < (WIDTH-20) && mouseY > 20 && mouseY < 50){//tutorial
    intro = true;
    started = false;
  }else if(started && mouseX > (WIDTH - INTRO_BUTTON_WIDTH -20) && mouseX < (WIDTH-20) && mouseY > 55 && mouseY < 90){// pause
    pause = true;
    started = false;
  }else if(started && mouseX > (WIDTH - INTRO_BUTTON_WIDTH -20) && mouseX < (WIDTH-20) && mouseY > 95 && mouseY < 130){//restart
    gameReset();
  }else if(soundPause && mouseX > WIDTH-55-27.5 && mouseX < WIDTH-55+27.5 && mouseY > 115 + 15 && mouseY < 115 + 65){//music
    soundPause = false;
    backgroundFlag = false;
  }else if(!soundPause && mouseX > WIDTH-55-27.5 && mouseX < WIDTH-55+27.5 && mouseY > 115 + 15 && mouseY < 115 + 65){
    soundPause = true;
  }
  
  //reborn star
  if(mouseX > WIDTH/2-70-25 && mouseX < WIDTH/2-70+25 && mouseY > HEIGHT/2+30 && mouseY < HEIGHT/2+60 ){
    reburnStarCounter --;
    canReborn = false;
    started = true; 
    //give new force for new born player
    //TODO: yes need to be press twice, and reburnStarCounter reduce twice as well,  I do not know why 
    playerPos.x = 300;
    newForce();
    println("reborn" + test);
  }else if(mouseX > WIDTH/2+70-25 && mouseX < WIDTH/2+70+25 && mouseY > HEIGHT/2+30 && mouseY < HEIGHT/2+60 ){
     notReborn = true;
  }
}
