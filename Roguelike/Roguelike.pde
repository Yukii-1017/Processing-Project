final int WIDTH = 1000;
final int HEIGHT = 600;

enum IDENTITY {
  PLAYER,
  MINOR,
  BOSS
}

boolean INTRO = true;
int GAME_LEVEL = 0;
int KILL_SCORE = 0;
boolean GAMEOVER = false;

Dungeon dungeon;
Character player;
ArrayList<Character> enemies;
Character boss;

Character curCombat;
int combatTurn;
String pDmgText;
String mDmgText;

void setup(){
  size(1000,600);
  

  initDungeon();
  player = new Character((int)dungeon.getEntrance().x+WALL_WIDTH/2, (int)dungeon.getEntrance().y+WALL_WIDTH/2, IDENTITY.PLAYER, 0, 0);
}

void draw(){
  background(#F98B88);
  
  if(INTRO) {
    fill(#FFFFFF);
    textAlign(CENTER,CENTER);
    textSize(24); 
    text("Press 'S' to start the game.", WIDTH/2, HEIGHT/2);
    text("Click mouse to control the player move around.", WIDTH/2, HEIGHT/2-30);
    text("Click key 1 to attack monster, key 2 to heal yourself.", WIDTH/2, HEIGHT/2-60);
    text("White block is where you born and black one is the path to next level.", WIDTH/2, HEIGHT/2-90);
  } else if(GAMEOVER) {
    fill(#FFFFFF);
    textAlign(CENTER,CENTER);
    textSize(24); 
    text("Game Over!", WIDTH/2, HEIGHT/2);
    
    textSize(20);
    text("Total level: " + GAME_LEVEL, WIDTH/2, HEIGHT/2+100);
    text("Total monster killed: " + KILL_SCORE, WIDTH/2, HEIGHT/2+200);
  } else {
    // Main game
    dungeon.draw();
    player.draw();
    boss.draw();
    for(Character c: enemies) c.draw();
    
    // Player data: (0,0) - (400,200)
    textSize(24);
    text("Dungeon Level " + GAME_LEVEL, 200, 25);
    text("Player Data", 200, 55);
    textSize(20);
    text("Health: " + player.getCurrentHealth() + "/" + player.getMaxHealth(), 100, 80);
    text("Attack: " + player.getMinAttack() + "-" + player.getMaxAttack(), 300, 80);
    text("Killed: " + KILL_SCORE, 100, 105);
    text("Treasure:" + (dungeon.isTreasureExist() ? "Not looted" : "Looted"), 300,105);
    
    // Combat data: (0,200) - (400, 600)
    textSize(24);
    text("Combat Information", 200,225);
    if(player.inCombat()) {
      textSize(16);
      
      String caughtStr = boss.inCombat() ? "You are caught by the stair guard!" : "You are caught by a monster!";
      setCombatState(caughtStr);
      
      setCurCombat();
    }
    
    textSize(24);
    text("Combat Decision", 200, 425);
    if(player.inCombat()) {
      textSize(16);
      text("[1] Attack: deal " + player.getMinAttack() + "-" + player.getMaxAttack() + " damage.", 200, 450);
      text("[2] Heal: heal 50% of max health (usable after " + player.getHealcd() + " turn)", 200, 475);
    }
    
    // Progress
    if(PVector.dist(new PVector(dungeon.getStair().x+10,dungeon.getStair().y+10),player.getPosition()) <= 5.0 && boss.getCurrentHealth() <= 0) {
      initDungeon();
      player.setPosition((int)dungeon.getEntrance().x+WALL_WIDTH/2, (int)dungeon.getEntrance().y+WALL_WIDTH/2);
    }
    
    // Get treasure
    if(PVector.dist(new PVector(dungeon.getTreasure().x+10,dungeon.getTreasure().y+10),player.getPosition()) <= 10.0 && dungeon.isTreasureExist()) {
      dungeon.loot();
      int bonus = (int)random(1,3);
      switch(bonus) { 
        case 1:
          player.setMaxHealth(10*GAME_LEVEL);
          break;
        case 2:
          player.setMinAttack(10*GAME_LEVEL);
          player.setMaxAttack(10*GAME_LEVEL);
        default: break;
      }
    }
    
    // Gameover
    if(player.getCurrentHealth() <= 0) {
      GAMEOVER = true;
    }
  } 
}

void setCombatState(String state) {
  text(state, 200, 250);
}

void setCurCombat() {
  text("Monster health: " + curCombat.getCurrentHealth(), 100, 275);
  text("Monster attack: " + curCombat.getMinAttack() + "-" + curCombat.getMaxAttack(), 300, 275);
  
  text("Combat turn: " + combatTurn, 200, 300);
  text(pDmgText, 200, 325);
  text(mDmgText, 200, 350);
}

void initDungeon() {
  GAME_LEVEL++;
  
  dungeon = new Dungeon();
  enemies = new ArrayList<Character>();
  
  pDmgText = "";
  mDmgText = "";
  
  for(float e = 1; e <= Math.ceil(GAME_LEVEL / 2.0)+1; e++) {
    enemies.add(new Character((int)random(21,49)*WALL_WIDTH, (int)random(1,29)*WALL_WIDTH, IDENTITY.MINOR, (int)e, GAME_LEVEL));
  }
  
  boss = new Character((int)dungeon.getStair().x+WALL_WIDTH/2, (int)dungeon.getStair().y+WALL_WIDTH/2, IDENTITY.BOSS, 0, GAME_LEVEL);
}

void keyPressed(){
  if(INTRO && (key == 'S' || key == 's')) INTRO = false;
  if(GAMEOVER) return;
  
  if(player.inCombat()) {
    if(key == '1') {
      combatTurn++;
      player.setHealcd(-1);
      
      int pDmg = player.attack();
      curCombat.setHealth(pDmg * -1);
      pDmgText = "You deal " + pDmg + " damage to monster!";
      
      if(curCombat.getCurrentHealth() > 0) {
        int mDmg = curCombat.attack();
        player.setHealth(mDmg * -1);
        mDmgText = "The monster deals " + mDmg + " damage to you!";
      } else {
        mDmgText = "The monster is dead! You grow stronger.";
        player.reward(curCombat.getId());
        
        KILL_SCORE++;
        player.setCombat(false);
      }
    } else if(key == '2') {
      combatTurn++;      
      player.setHealcd(-1);
      
      if(player.getHealcd() != 0) {
        pDmgText = "Heal not ready, you waste your turn!";
      } else {
        player.setHealth((int)(player.getMaxHealth()*0.5));
        player.setHealcd(PLAYER_HEAL_COOLDOWN);
        pDmgText = "You heal yourself for " + (int)(player.getMaxHealth()*0.5) + ".";
      }
      
      int mDmg = curCombat.attack();
      player.setHealth(mDmg * -1);
      mDmgText = "The monster deals " + mDmg + " damage to you!";
    }
  }
}

void mousePressed(){
  if(!INTRO && !GAMEOVER) {
    if(!player.inCombat()) {
      player.setMotion(mouseX, mouseY);
    }
  }
}
