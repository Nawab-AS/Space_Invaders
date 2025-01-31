boolean moveRight, moveLeft, shoot = false; //<>//
int[] controls = {39, 37, 32}; // [0] = right, [1] = left, [2] = shoot
Player player = new Player();
laser playerLaser = new laser(true, -1);
int numberOfAliens;
Alien[] aliens;
PImage[] greenAlienImages;
PImage playerImage;
PImage splashScreen;
int rowSize;
int columnSize;
int alienUpdateSpeed;
int[] alienDir;
float alienDrop[];
int changeKey = -1;
int lastDeadAlien;
int wait;
int score;
int highscore = 0;
int state = 6; // 0 = main menu, 1 = game, 2 = win screen, 3 = settings, 4 = lose screen, 5 = instructions, splash screen = 6

// setup
void setup() {
  size(600, 500);
  rectMode(CENTER);
  imageMode(CENTER);
  textAlign(CENTER);
  setVariables();
}

void setVariables() {
  player.setVariables();
  playerLaser.setVariables();
  
  // load images
  greenAlienImages = new PImage[2];
  greenAlienImages[0] = loadImage("greenAlien1.png");
  greenAlienImages[1] = loadImage("greenAlien2.png");
  playerImage = loadImage("player.png");
  splashScreen = loadImage("splashScreen.png");
  
  // initialize aliens
  rowSize = 9;
  columnSize = 4;
  numberOfAliens = rowSize * columnSize;

  aliens = new Alien[numberOfAliens];
  for (int i = 0; i< aliens.length; i++) {
    aliens[i] = new Alien();
    aliens[i].setVariables(i);
  }
  alienUpdateSpeed = 1000;
  alienDir = new int[aliens.length/rowSize]; // 1 = Right, -1 = left
  for (int i = 0; i<alienDir.length; i++) {
    alienDir[i] = 1;
  }
  alienDrop = new float[aliens.length/rowSize];
  
  // win/lose effects
  lastDeadAlien = -1;
  wait = millis()+1500;
  
  score = 0;
}

void draw() {
  background(#000000);
  switch (state) {
  case 0:
    drawMenu();
    break;
  case 1:
    drawGame();
    break;
  case 2:
    drawWinScreen();
    break;
  case 3:
    drawSettings();
    break;
  case 4:
    drawLoseScreen();
    break;
  case 5:
    drawInstructionsScreen();
    break;
  case 6:
    drawSplashScreen();
    break;
  }
}

void drawSplashScreen(){
  background(splashScreen);
  
  if (wait<millis()){
    state = 0; // splash screen -> main menu
  }
}

void drawInstructionsScreen() {
  drawStars();

  textSize(80);
  oscillatingColor();
  text("INSTRUCTIONS", width/2, height/6);


  String[] instructions = {
    "Welcome to Space Invaders by Nawab_AS",
    "                                       ",
    "The objective of this game is to destroy",
    "all of the aliens that are invading planet",
    "Earth, as default use the arrow keys to", 
    "move your ship and the spacebar to shoot.",
    "Additionally, you can customize your controls",
    "through the settings from the main menu.",
    "                                        ", 
    "Good Luck"
  };
  
  // display instructions array as a paragraph
  textSize(25);
  fill(#FFFFFF);
  for (int i = 0; i<instructions.length; i++) {
    text(instructions[i], width/2, 140 + i*30);
  }

  // go back button
  fill(#FFFFFF);
  rect(width/2, height - 45, 200, 50, 10);

  oscillatingColor();
  textSize(40);
  if (mouseX> width/2 - 200/2  &&  mouseX< width/2 + 200/2  && mouseY>height - 45 - 50/2  && mouseY<height - 45 + 50/2) {
    if (mousePressed) {
      state = 0; // settings -> menu
    }
    fill(#FF0000);
  }
  text("GO BACK", width/2, height-30);
}


void drawLoseScreen() {
  drawStars();
  displayScore();

  textSize(80);
  fill(#FF0000);
  text("You Lose", width/2, height/6);

  // flashing player
  if ((millis() - wait)%1000 < 500) {
    player.draw();
  }
  
  // draw all aliens
  for (int i = 0; i< aliens.length; i++) {
    aliens[i].draw();
  }

  // reset to main menu after 2.5 seconds
  if (millis() - wait >= 2500) {
    state = 0; // win screen -> menu
  }
}

void drawWinScreen() {
  drawStars();
  displayScore();

  textSize(80);
  oscillatingColor();
  text("You Win", width/2, height/6);

  // flashing last shot alien
  if ((millis() - wait)%1000 < 500) {
    aliens[lastDeadAlien].isAlive = true;
  } else {
    aliens[lastDeadAlien].isAlive = false;
  }

  player.draw();
  aliens[lastDeadAlien].draw(); // draws only if alien is alive

  if (millis() - wait >= 2500) {
    state = 0; // win screen -> menu after 2.5 seconds
  }
}

void drawSettings() {
  drawStars();

  textSize(80);
  oscillatingColor();
  text("SETTINGS", width/2, height/6);


  // iterable array of key descriptions
  String[] buttonStrings = {"Move Right", "Move Left", "Shoot"};
  
  
  textSize(30);
  for (int i = 0; i<controls.length; i++) { // for each key
    // key mapping text
    fill(#FFFFFF);
    textAlign(LEFT);
    text(buttonStrings[i] + (changeKey != i ? " : key #" + controls[i] : "  : Detecting"), 50, height/6*2 + height/6*i*1.5);
    
    // change key mapping button
    rect(width - 150, height/6*2 + height/6*i*1.5 - 15, 150, 40, 10);
    fill(#000000);
    if (mouseX> width - 150 - 150/2  &&  mouseX< width - 150 + 150/2
      &&  mouseY>height/6*2 + height/6*i*1.5 - 5 - 40/2  &&  mouseY<height/6*2 + height/6*i*1.5 - 5 + 40/2) {
      if (mousePressed) {
        changeKey = i;
      }
      fill(#00FF00);
    }
    textAlign(CENTER);
    text("Change", width - 150, height/6*2 + height/6*i*1.5 - 5);
  }

  // go back button
  fill(#FFFFFF);
  rect(width/2, height - 45, 200, 50, 10);

  oscillatingColor();
  textSize(40);
  if (mouseX> width/2 - 200/2  &&  mouseX< width/2 + 200/2  && mouseY>height - 45 - 50/2  && mouseY<height - 45 + 50/2) {
    if (mousePressed) {
      state = 0; // settings -> menu
    }
    fill(#FF0000);
  }
  text("GO BACK", width/2, height-30);
}

void oscillatingColor() {
  // transitions from green to blue (and vice versa) every 45 frames (~0.75 seconds)
  // blue: (28, 96, 188)    green: (16, 222, 27)
  if (frameCount%90 < 45) {
    // blue -> green
    fill( map(frameCount%90, 0, 45, 28, 16), map(frameCount%90, 0, 45, 96, 222), map(frameCount%90, 0, 45, 188, 27) );
  } else {
    // green -> blue
    fill( map(frameCount%90, 45, 90, 16, 28), map(frameCount%90, 45, 90, 222, 96), map(frameCount%90, 45, 90, 27, 188) );
  }
}

void drawMenu() {
  drawStars();

  textSize(80);
  oscillatingColor();
  text("SPACE\nINVADERS", width/2, height/6);

  // play button
  fill(#FFFFFF);
  rect(width/2, height/6*3, 250, 100, 10);

  oscillatingColor();
  if (mouseX> width/2 - 250/2  &&  mouseX< width/2 + 250/2  &&  mouseY> height/6*3 - 100/2  &&  mouseY< height/6*3 + 100/2) {
    if (mousePressed) {
      setVariables();
      state = 1; // menu -> game
    }
    fill(#FF0000);
  }
  text("PLAY", width/2, height/6*3+30);


  // settings button
  fill(#FFFFFF);
  rect(width/2, height/6*4, 200, 50, 10);

  oscillatingColor();
  textSize(40);
  if (mouseX> width/2 - 200/2  &&  mouseX< width/2 + 200/2  &&  mouseY> height/6*4 - 50/2  &&  mouseY< height/6*4 + 50/2) {
    if (mousePressed) {
      state = 3; // menu -> settings
      changeKey = -1;
    }
    fill(#00FF00);
  }
  text("SETTINGS", width/2, height/6*4.25 - 10);

  // settings button
  fill(#FFFFFF);
  rect(width/2, height/6*4.7, 275, 50, 10);

  oscillatingColor();
  textSize(40);
  if (mouseX> width/2 - 275/2  &&  mouseX< width/2 + 275/2  &&  mouseY> height/6*4.7 - 50/2  &&  mouseY< height/6*4.7 + 50/2) {
    if (mousePressed) {
      state = 5; // menu -> instructions
      changeKey = -1;
    }
    fill(#00FF00);
  }
  text("INSTRUCTIONS", width/2, height/6*5 - 10);

  // highscore text
  fill(#FFFFFF);
  text("Highscore: " + highscore, width/2, height/6*5.5);
}

void displayScore() { // displays score at top left corner
  push();
  textAlign(LEFT);
  textSize(30);
  fill(#FFFFFF);
  text("Score: " + score, 25, 25);
  pop();
}

void drawGame() {
  drawStars();
  displayScore();

  // update and draw aliens  and also counting number of dead aliens (for win condition)
  int numberOfDeadAliens = 0;
  for (int i = 0; i< aliens.length; i++) {
    aliens[i].update();
    aliens[i].draw();
    if (!aliens[i].isAlive) {
      numberOfDeadAliens++;
    }
  }
  updateAlienSpeed();
  
  if (numberOfDeadAliens == aliens.length) { // win condition
    state = 2; // game -> win screen
    wait = millis();
  }

  player.update();
  playerLaser.update();
  playerLaser.draw();
  player.draw();
}

// alien class
class Alien {
  int updateTime, index;
  PVector pos;
  final int alienSize = 30;
  final int margin = 15; // margin between aliens
  laser Laser; // alien laser
  boolean isAlive;
  int animationFrame;

  void setVariables(int index) {
    this.index = index;
    isAlive = true;
    
    // set position
    pos = new PVector();
    pos.x = (index%rowSize) * (alienSize+margin) + (width-rowSize* (alienSize+margin))/2;
    pos.y = index/rowSize * (alienSize+margin) + 50;
    
    // set movement/animation
    updateTime = millis() + 500 + 200*((aliens.length-1-index)/rowSize);
    animationFrame = 0;
    
    // set alien laser
    Laser = new laser(false, index);
    Laser.setVariables();
  }

  void update() {

    //count number of dead aliens in it's row,if yes, then allow allow above row to drop infinitely
    int deadAliensInThisRow = 0;
    for (int i = 0; i< rowSize; i++) {
      if (!aliens[index/rowSize*rowSize+i].isAlive) {
        deadAliensInThisRow++;
      }
    }
    
    if (deadAliensInThisRow == rowSize) {
      alienDrop[index/rowSize] = height*100;
    }

    // don't update movement if dead
    if (!isAlive) {
      return;
    }

    // flip row direction if it hit a wall
    boolean hitWall = false;
    if (pos.x+alienSize+5 >= width) {
      alienDir[index/rowSize] = -1;
      hitWall = true;
    } else if (pos.x-alienSize-5 <= 0) {
      alienDir[index/rowSize] = 1;
      hitWall = true;
    }
    
    // drop it's row only if the row under is beneath me (to prevent row from intersecting to the row below me)
    if (hitWall &&  index+1>aliens.length - rowSize) { // if I am part of the last row
      alienDrop[index/rowSize]++;
    } else if (hitWall && alienDrop[index/rowSize]<alienDrop[(index+rowSize)/rowSize]) {
      alienDrop[index/rowSize]++;
    }

    boolean isBottom = true; // if there are no aliens below me, 2.5/1000 chance of randomly firing a laser
    for (int i = index+rowSize; i<=aliens.length-1; i+=rowSize) {
      if (aliens[i].isAlive) {
        isBottom = false;
      }
    }

    if (random(1000)<=2.5 && isBottom && !Laser.isFired) {
      Laser.shoot();
    }
    Laser.update();


    // laggy movement
    if (millis()>=updateTime) {
      pos.x+= map(alienUpdateSpeed, 400, 50, 7, 20) * alienDir[index/rowSize];
      // set next movement
      updateTime += alienUpdateSpeed;
      animationFrame = (animationFrame+1)%greenAlienImages.length;
    }

    // sync row Y position
    pos.y = index/rowSize * (alienSize+margin) + 50 + 2*alienDrop[index/rowSize];

    // destroy if it hit the player's laser
    if (playerLaser.pos.x<pos.x+alienSize/2 && playerLaser.pos.x>pos.x-alienSize/2 &&
      playerLaser.pos.y<pos.y+alienSize/2 && playerLaser.pos.y>pos.y-alienSize/2) {
      isAlive = false;
      playerLaser.hit(); // reset player laser
      lastDeadAlien = index; // setup win effect
      
      score+=5; // update score
      if (score>highscore) { // update highscore if score is bigger
        highscore = score;
      }
    }

    // hit player or lower than player
    if ((pos.x+30/2 > player.pos.x - 24/2  &&  pos.x-30/2 < player.pos.x + 30/2  &&  pos.y+30/2 > player.pos.y - 30/2)  || pos.y+30/2 > player.pos.y - 30/2) {
      state = 4; // game -> lose screen
      lastDeadAlien = index;
      wait = millis();
    }
  }

  void draw() {
    if (isAlive) {
      image(greenAlienImages[animationFrame], pos.x, pos.y);
      Laser.draw();
    }
  }
}

void updateAlienSpeed() {
  int numberOfDeadAliens = 0;
  for (int i = 0; i< aliens.length; i++) {
    if (!aliens[i].isAlive) {
      numberOfDeadAliens++;
    }
  }
  alienUpdateSpeed = (int)map(numberOfDeadAliens, 0, aliens.length, 400, 50); // lerp speed based of number of dead aliens
}

// player class
class Player {
  final int speed = 4;
  final int playerSize = 30;
  PVector pos;

  void setVariables() {
    // set position
    pos = new PVector(width/2, height-75);
  }

  void update() {
    if (moveRight) {
      pos.x = min(pos.x+speed, width-playerSize/2);
    }
    if (moveLeft) {
      pos.x = max(pos.x-speed, playerSize+playerSize/2);
    }

    if (shoot && !playerLaser.isFired) {
      playerLaser.shoot();
    }

    // hit by alien laser
    for (int i = 0; i<aliens.length; i++) {
      if (aliens[i].isAlive && aliens[i].Laser.pos.x < pos.x -15 +30/2 && aliens[i].Laser.pos.x > pos.x -15 -30/2
        && aliens[i].Laser.pos.y < pos.y -10 +20/2 && aliens[i].Laser.pos.y > pos.y -10 -20/2) {
        state = 4; // game -> lose screen
        wait = millis();// setup lose screen effect
      }
    }
  }

  void draw() {
    fill(#FFFFFF);
    image(playerImage, pos.x-15, pos.y-10);
  }
}

class laser {
  PVector pos;
  boolean isFired;
  int shootDisabled;
  boolean isPlayerLaser;
  int alienIndex;

  laser(boolean byPlayer, int alienIndex) { // constructor to differentiate between player and alien lasers
    isPlayerLaser = byPlayer;
    this.alienIndex = alienIndex;
  }

  void setVariables() {
    isFired = false;
    pos = new PVector(-1, -1);
    shootDisabled = millis();
  }

  void hit() {
    shootDisabled = millis()+200;// disable shooting for 0.2 seconds
    isFired = false;
    
     // reset position to player or alien
    if (isPlayerLaser) {
      pos = new PVector(player.pos.x, player.pos.y);
    } else if (!isPlayerLaser && alienIndex != -1) {
      pos = new PVector(aliens[alienIndex].pos.x, aliens[alienIndex].pos.y);
    }
  }

  void shoot() {
    if (millis()>shootDisabled) {
      isFired = true;
      if (isPlayerLaser) {
        pos.x = player.pos.x - player.playerSize/2;
        pos.y = player.pos.y+5;
      } else if (!isPlayerLaser && alienIndex != -1) {
        pos.x = aliens[alienIndex].pos.x - aliens[alienIndex].alienSize/2;
        pos.y = aliens[alienIndex].pos.y+5;
      }
    }
  }

  void draw() {
    if (isFired) {
      // white laser from player and green laser from aliens
      if (isPlayerLaser) {
        fill(#FFFFFF);
      } else if (!isPlayerLaser && alienIndex != -1) {
        fill(#229B1B);
      }
      rect(pos.x-2, pos.y-5, 4, 10);
    }
  }

  void update() {
    if (isFired) {
      // move up if player or move down if alien
      if (isPlayerLaser) {
        pos.y-=15;
      } else if (!isPlayerLaser && alienIndex != -1) {
        pos.y+=5;
      }
      
      // reset if out of bounds
      if (pos.y<=25 || pos.y>=height-25) {
        hit();
      }
    }
  }
}

void drawStars() {
  fill(#AAAAAA);
  for (int x = 0; x<100; x++) {
    rect(random(width), random(height), 3, 3);
  }
}


void keyPressed() {
  println(keyCode);
  
  // remap key if editing key maps
  if (state == 3 && changeKey != -1) {
    controls[changeKey] = keyCode;
    changeKey = -1;
  }

  if (keyCode == controls[0]) {
    moveRight = true;
  }
  if (keyCode == controls[1]) {
    moveLeft = true;
  }
  if (keyCode == controls[2]) {
    shoot = true;
  }
}

void keyReleased() {
  if (keyCode == controls[0]) {
    moveRight = false;
  }
  if (keyCode == controls[1]) {
    moveLeft = false;
  }
  if (keyCode == controls[2]) {
    shoot = false;
  }
}
