final int CHARACTER_RADIUS = 15;
final int BOSS_RADIUS = 20;

final int ENEMY_DETECTION = 60;

enum ENEMYSTATE {
  PATROL,
  COMBAT
}

int PLAYER_HEALTH_LIMIT = 100;
int PLAYER_MINATTACK = 30;
int PLAYER_MAXATTACK = 50;
int PLAYER_HEAL_COOLDOWN = 3;

class Character {
  private IDENTITY id;
  private int maxHealth;
  private int curHealth;
  private int minAttack;
  private int maxAttack;
  
  private int healcd;
  
  private PVector position;
  
  private float orientation;
  private boolean inMotion;
  private PVector motion; // unit vector
  private PVector destination;
  
  private boolean inCombat;
  
  private int eIdx;
  private int eLvl;
  private ENEMYSTATE eState;
  
  Character(int x, int y, IDENTITY id, int midx, int mlvl) {
    this.id = id;
    
    if(id == IDENTITY.PLAYER) {
      this.maxHealth = PLAYER_HEALTH_LIMIT;
      this.minAttack = PLAYER_MINATTACK;
      this.maxAttack = PLAYER_MAXATTACK;
    } else if(id == IDENTITY.MINOR) {
      this.maxHealth = 100 + (mlvl-1) * 30;
      this.minAttack = 20 + (mlvl-1) * 20;
      this.maxAttack = 35 + (mlvl-1) * 25;
    } else {
      this.maxHealth = 100 + mlvl * 35;
      this.minAttack = 20 + mlvl * 25;
      this.maxAttack = 40 + mlvl * 25;
    }
    this.curHealth = this.maxHealth;
    
    this.healcd = 0;
    
    this.position = new PVector(x, y);
    
    this.orientation = atan2(-15, 0); // Face upward
    this.inMotion = false;
    this.motion = new PVector(cos(orientation), sin(orientation));
    this.destination = new PVector(0, 0);
    
    this.inCombat = false;
    
    this.eIdx = midx;
    this.eLvl = mlvl;
    this.eState = ENEMYSTATE.PATROL;
  }
  
  IDENTITY getId() {
    return this.id;
  }
  
  PVector getPosition() {
    return this.position.copy();
  }
  
  PVector getDestination() {
    return this.destination.copy();
  }
  
  int getCurrentHealth() {
    return this.curHealth;
  }
  
  int getMaxHealth() {
    return this.maxHealth;
  }
  
  int getMinAttack() {
    return this.minAttack;
  }
  
  int getMaxAttack() {
    return this.maxAttack;
  }
  
  int getHealcd() {
    return this.healcd;
  }
  
  boolean inCombat() {
    return this.inCombat;
  }
  
  void setPosition(int x, int y) {
    this.position.set(new PVector(x, y)); 
  }
  
  void setCombat(boolean b) {
    this.inCombat = b;
  }
  
  void setHealth(int amount) {
    this.curHealth += amount;
    
    if(this.curHealth <= 0) this.curHealth = 0;
    if(this.curHealth >= maxHealth) this.curHealth = maxHealth;
  }
  
  void setMaxHealth(int amount) {
    this.maxHealth += amount;
  }
  
  void setMinAttack(int amount) {
    this.minAttack += amount;
  }
  
  void setMaxAttack(int amount) {
    this.maxAttack += amount;
  }
  
  void setHealcd(int cd) {
    this.healcd += cd;
    if(this.healcd <= 0) this.healcd = 0;
  }
  
  void reward(IDENTITY defeatType) {
    // Grow stronger
    maxHealth += GAME_LEVEL * (defeatType == IDENTITY.BOSS ? 25 : 20);
    minAttack += GAME_LEVEL * (defeatType == IDENTITY.BOSS ? 15 : 10);
    maxAttack += GAME_LEVEL * (defeatType == IDENTITY.BOSS ? 30 : 20);
    // Auto-heal without cd
    setHealth((int)(maxHealth*(defeatType == IDENTITY.BOSS ? 0.5 : 0.25)));
  }
  
  // 0-right, pi/2-bottom & -pi/2-up, +-pi-left
  // Snap orientation to motion/velocity
  void setMotion(int newx, int newy) {
    inMotion = true;
    orientation = atan2(newy-position.y, newx-position.x);
    motion.set(cos(orientation), sin(orientation));
    destination.set(newx, newy);
  }
  
  void patrol() {
    double move = Math.random();
    double moveVerDir = Math.random();
    double moveHorDir = Math.random();
    
    int patrolDist = 20 + eLvl * 20;
    
    float patrolVerDist = move >= 0.5 
      ? position.y 
      : moveVerDir >= 0.5 ? position.y+patrolDist : position.y-patrolDist;
    
    float patrolHorDist = move <= 0.5
      ? position.x
      : moveHorDir >= 0.5 ? position.x+patrolDist : position.x-patrolDist;
    
    setMotion((int)patrolHorDist, (int)patrolVerDist);
  }
  
  boolean playerInRange() {
    PVector pv = player.getPosition();
    
    return PVector.dist(position, pv) <= ENEMY_DETECTION;
  }
  
  int attack() {
    return (int) random(minAttack, maxAttack);
  }
  
  void draw() {
    if(curHealth <= 0) return;
    
    stroke(#000000);
    float actualRadius = id == IDENTITY.BOSS ? BOSS_RADIUS : CHARACTER_RADIUS;
    
    // Avatar
    switch(id) {
      case PLAYER: fill(#50C878); break;
      case MINOR: fill(#FF007F); break;
      case BOSS: fill(#FF0000); break;
      default: fill(#FFFFFF); break;
    }
    ellipse(position.x, position.y, actualRadius, actualRadius);
    // Orientation
    fill(#000000);
    PVector oriPos = new PVector(position.x+motion.x*(actualRadius/2), position.y+motion.y*(actualRadius/2));
    ellipse(oriPos.x,oriPos.y, 3,3);
    
    // Enemy detection range
    if(id == IDENTITY.MINOR || id == IDENTITY.BOSS) {
      noFill();
      stroke(#FF0000);
      ellipse(position.x, position.y, ENEMY_DETECTION, ENEMY_DETECTION);
    }
    
    // Enemy AI
    /*
      Decision tree:
        At rest: start patrol on random hor/ver direction
        In patrol:
          - If enemy & player on one direct sight line (without walls), start chase player
    */
    if(id == IDENTITY.MINOR) {
      switch(eState) {
        case PATROL:
          if(!inMotion) { 
            patrol(); 
          } else {
            if(playerInRange() && !player.inCombat()) {
              eState = ENEMYSTATE.COMBAT;
              this.inCombat = true;
              player.setCombat(true);
              combatTurn = 0;
              curCombat = this;
            }
          }
          break;
        case COMBAT:
          this.setMotion((int)player.getPosition().x, (int)player.getPosition().y);
          break;
        default: break;
      }
    }
    
    if(id == IDENTITY.BOSS) {
      switch(eState) {
        case PATROL:
          if(playerInRange()) {
            eState = ENEMYSTATE.COMBAT;
            this.inCombat = true;
            player.setCombat(true);
            combatTurn = 0;
            curCombat = this;
          }
          break;
        case COMBAT: 
          this.setMotion((int)player.getPosition().x, (int)player.getPosition().y);
          break;
        default: break;
      }
    }
    
    // Motion integration
    if(inMotion) {
      // Wall collision
      if(dungeon.isCollided(oriPos)) {
        inMotion = false; 
        return;
      }
      
      // Destination detection
      if(abs(position.x-destination.x) <= 1 && abs(position.y-destination.y) <= 1) {
        inMotion = false; 
        return;
      }
      
      position.add(motion);
    }
  }
}
