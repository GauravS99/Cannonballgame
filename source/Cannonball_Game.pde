import ddf.minim.*;


boolean aPressed, dPressed, leftPressed, rightPressed, wPressed, sPressed, spacePressed, shiftPressed, upPressed, downPressed, qPressed, ePressed, periodPressed, slashPressed;
PImage background, tankOneTop, tankOneBottom, tankTwoTop, tankTwoBottom, title, end, title2, 
marioBullet, bowserBullet, wall;
boolean marioFired, bowserFired;

AudioPlayer player, marioPlayer, bowserPlayer, mExplosionPlayer, bExplosionPlayer;
Minim minim;//audio context


void setup() {
  background= loadImage("Background.jpg"); 
  tankOneTop= loadImage("mariotanktop.png"); 
  tankTwoTop= loadImage("bowsertanktop.png"); 
  tankOneBottom= loadImage("mariotankbottom.png"); 
  tankTwoBottom= loadImage("bowsertankbottom.png"); 
  marioBullet=loadImage("CannonballRight.png"); 
  bowserBullet=loadImage("CannonballLeft.png");
  title=loadImage("title.png") ;
  end=loadImage("end.png");
  wall=loadImage("brick.png");
  title2=loadImage("title2.png");

  minim = new Minim(this);
  player = minim.loadFile("music.wav");
  marioPlayer = minim.loadFile("fire.wav");
  bowserPlayer = minim.loadFile("fire.wav");
  mExplosionPlayer = minim.loadFile("explosion.wav");
  bExplosionPlayer = minim.loadFile("explosion.wav");

  
  
  player.play();

  image(title, 0, 0);

  size(800, 500);

  reset();
}

void reset() {

  aPressed=false;
  dPressed=false;
  wPressed=false;
  sPressed=false;
  leftPressed=false;
  rightPressed=false;
  spacePressed=false;
  shiftPressed=false;
  marioFired=false;
  bowserFired=false;
  upPressed=false;
  downPressed=false;
}


int marioX=200;  //marios X pos
int bowserX=600;// Bowser's X pos
int marioRotation= 0;  //marios angle
int bowserRotation= 0;  // bowsers angle
int marioOriginalFire; // where the mario tank is after firing
int bowserOriginalFire; // where the bowser tank is after firing
int marioHits=0;
int bowserHits=0;
boolean hard=false;
int stage=0; // the current stage of game
double marioV= 75;  //the velocity of their cannons. REMOVES THE NEED OF A getVelocity() METHODd
double bowserV = 75; //  ^^^  75 is the DEFULT


final int UPPER_ROTATION_LIMIT = 90;
final int LOWER_ROTATION_LIMIT = 0;
final double WIDTH_OF_SCREEN = 500;
final double LENGTH_OF_SCREEN = 800; 
final double LENGTH_AND_WIDTH_OF_TANK = 100; // the images are squares
final double WIDTH_OF_CANNONBALL = 31; // # of pixels
final double LENGTH_OF_CANNONBALL = 23; // # of pixels
final int LENGTH_OF_SONG= 218000;
final int TANK_Y = 365; //the Y position of both the tanks
final int WALL_HIEGHT = 200;
final int WALL_WIDTH = 75;
final int HITS_TO_WIN = 5;

int wallX =  360; 
int wallY = TANK_Y - 100;

Cannonball marioBall = new Cannonball(75, marioRotation);
Cannonball bowserBall = new Cannonball(75, bowserRotation);


void draw() {
 
if(stage==0){     //title
  
  player.play();
  
  image(title, 0, 0);
  
}

if(stage==1){  //instructions 
  
  image(title2,0,0); 
  if (key == 'h') 
      hard=true;
    
  if(hard){
    textSize(14);
    fill(150,0,0);
    text("HARD MODE ENABLED!", 360,380);
  }

}

if(stage==2){  //game
  
  image(background, 0, 0);
  
  if(hard){
   image(wall, wallX, wallY); 
  } 

  if (aPressed && inBounds(1)!=1)
    marioX-=2;
  else if (dPressed && inBounds(1)!=2)
    marioX+=2;

  if (leftPressed && inBounds(2)!=1)
    bowserX-=2;
  else if (rightPressed && inBounds(2)!=2)
    bowserX+=2; 


  if (!marioFired)
    marioBall.updateAngle(marioRotation);
  if (!bowserFired)
    bowserBall.updateAngle(bowserRotation);



  image(tankOneBottom, marioX, TANK_Y);
  image(tankTwoBottom, bowserX, TANK_Y);
  
  fill(0);
  
  
  
  fireHandler();
  guiHandler();
  velocityHandler();
  rotationHandler();
  
  if(marioHits >= HITS_TO_WIN || bowserHits>= HITS_TO_WIN){
  stage=3;
  reset();
  }
  
   
}

if(stage==3){ // end screen
  String winner;
  
  image(end, 0, 0);
  
  if(marioHits > bowserHits)
  winner="Mario";
  else
  winner="Bowser";
  
  fill(0);
  textSize(30);
  text("The winner is : " + winner, 250, 430);

  textSize(12);
  text("Click anywhere to play again", 330, 450 );
  
} 
  
}

void mouseClicked(){  //handles changing stages
  
  if(stage==0)
  stage=1;
  else if(stage==3){
    stage=1;
    marioHits=0;
    bowserHits=0;  
}
  else if(stage==1)
  stage=2;
  
} 

void keyPressed() {
  switchBoolean(true);
} 

void keyReleased() {
  switchBoolean(false);
} 


void velocityHandler(){
  final int UPPER_LIMIT=100;
  final int LOWER_LIMIT= 30;
  
 if(qPressed && marioV> LOWER_LIMIT)
  marioV-=0.5; 
 else if(ePressed && marioV< UPPER_LIMIT)
  marioV+=0.5;
  
 if(periodPressed && bowserV> LOWER_LIMIT)
 bowserV-=0.5;
 else if(slashPressed && bowserV< UPPER_LIMIT)
 bowserV+=0.5;
 

}


void  guiHandler(){ //handles all gui elements while the game is being run
  
 textSize(20);
  
  fill(20,247, 255);
  text("Score :" + marioHits,20.0,40.0);
  text("Score :" + bowserHits, (float)(LENGTH_OF_SCREEN - 150), 40.0); 
 
  fill(0);
  text("Velocity :" + marioV,20.0,80.0);
  text("Velocity :" + bowserV, (float)(LENGTH_OF_SCREEN - 150), 80.0);
  

  
}


void fireHandler() { //handles all aspects of shooting

  final int OFFSET_X = 30; // serves to make the ball appear to be coming from the tank
  final int OFFSET_Y = 25;

  if (spacePressed && !marioFired) {
    marioFired=true;
    marioPlayer.play();
    marioPlayer.rewind();
    marioOriginalFire=marioX;
    marioBall.setVelocity(marioV);
  }

  if (shiftPressed && !bowserFired) {
    bowserFired=true;
    bowserPlayer.play();
    bowserPlayer.rewind();
    bowserOriginalFire=bowserX;
    bowserBall.setVelocity(bowserV);
  }

  float marioBallPosX=(float)(marioBall.getHorizontal() +  marioOriginalFire + OFFSET_X);  //this code determines where mario's/bowser's cannonball will be ON THE SCREEN 
  float marioBallPosY=(float)(-marioBall.getVertical()+ TANK_Y + OFFSET_Y);
  float bowserBallPosX= (float)( -bowserBall.getHorizontal()  + bowserOriginalFire + OFFSET_X);
  float bowserBallPosY=(float)(-bowserBall.getVertical()+ TANK_Y+ OFFSET_Y);


  if (marioFired) {
    image(marioBullet, marioBallPosX, marioBallPosY);   
    marioBall.updatePos();
  }
  if (bowserFired) {
    image(bowserBullet, bowserBallPosX, bowserBallPosY);   
    bowserBall.updatePos();
  }


  double marioHitPointX=marioBallPosX + LENGTH_OF_CANNONBALL;   // the point on the cannonball that registers a hit for the cannonball is the point defined by these two values
  double marioHitPointY=marioBallPosY + WIDTH_OF_CANNONBALL;      //if that makes any sense
  double bowserHitPointX=bowserBallPosX;      
  double bowserHitPointY=bowserBallPosY + WIDTH_OF_CANNONBALL;      
  final double OFFSET = 50;  //serves to make the hitbox smaller
  boolean marioHitted=false;
  boolean bowserHitted= false;


  //hits other tank
  if ((marioHitPointX >= bowserX && marioHitPointX <= bowserX + LENGTH_AND_WIDTH_OF_TANK) &&                  //<-------- basically this is:  "  if(hitsEnemyTank)  "
  (marioHitPointY >= TANK_Y + OFFSET  && marioHitPointY <= TANK_Y + LENGTH_AND_WIDTH_OF_TANK)) {
    marioHitted=true;
    marioHits++;
  }

  if ((bowserHitPointX >= marioX && bowserHitPointX <= marioX + LENGTH_AND_WIDTH_OF_TANK) &&                // <------ so is this
  (bowserHitPointY >= TANK_Y + OFFSET  && bowserHitPointY <= TANK_Y + LENGTH_AND_WIDTH_OF_TANK)) {
    bowserHitted=true;
    bowserHits++;
  }
  
  
  //hits wall
  
  if(hard){
  if((marioHitPointX >= wallX && marioHitPointX <= wallX+ WALL_WIDTH) &&               // <-------------- this is basically "  if(hitsWall)   "
     (marioHitPointY >= wallY && marioHitPointY <= wallY+ WALL_HIEGHT))                // WALL IS ONLY WHEN "HARD" IS ENABLED!
     marioHitted=true;
 
  if((bowserHitPointX >= wallX && bowserHitPointX <= wallX+ WALL_WIDTH) &&
     (bowserHitPointY >= wallY && bowserHitPointY <= wallY+ WALL_HIEGHT))
     bowserHitted=true;   
  } 
     
   if(marioHitted){
   mExplosionPlayer.play();
   mExplosionPlayer.rewind();
   }
   else if(bowserHitted){
   bExplosionPlayer.play();
   bExplosionPlayer.rewind();
   }
   
   
   
   if (marioHitPointY >= TANK_Y + LENGTH_AND_WIDTH_OF_TANK || marioHitted) {       // these two get rid of the cannonball if it hits the ground  or a tank  
    marioFired=false ;
    marioBall.reset();
  }
  if (bowserHitPointY >= TANK_Y + LENGTH_AND_WIDTH_OF_TANK || bowserHitted) {
    bowserFired=false ;
    bowserBall.reset();
  }
} 

void rotationHandler() { //handlles all rotation



  if (sPressed && marioRotation > LOWER_ROTATION_LIMIT)
    marioRotation-=2;
  else if (wPressed && marioRotation < UPPER_ROTATION_LIMIT)
    marioRotation+=2;



  if (downPressed && bowserRotation > LOWER_ROTATION_LIMIT)
    bowserRotation-=2;
  else if (upPressed && bowserRotation < UPPER_ROTATION_LIMIT)
    bowserRotation+=2;


  pushMatrix();
  pushMatrix();
  translate(marioX + 50, TANK_Y + 50);
  rotate(radians(-marioRotation));
  translate(-50, -50);
  image(tankOneTop, 0, 0);
  popMatrix();
  translate(bowserX + 60, TANK_Y + 50);
  rotate(radians(bowserRotation));
  translate(-60, -50);
  image(tankTwoTop, 0, 0);
  popMatrix();
}


void switchBoolean(boolean pressed) {   //handles all the key presses

  if (key == 'a')
    aPressed=pressed;
  else if (key == 'd')
    dPressed=pressed;
  else if (keyCode == LEFT)
    leftPressed=pressed;
  else if (keyCode == RIGHT)
    rightPressed=pressed;
  else if (key == 'w')
    wPressed=pressed;
  else if (key == 's')
    sPressed=pressed;
  else if (key == ' ')
    spacePressed=pressed;
  else if (keyCode == SHIFT )
    shiftPressed=pressed;
  else if (keyCode == UP )
    upPressed=pressed;
  else if (keyCode == DOWN )
    downPressed=pressed;
  else if (key == '.')
    periodPressed=pressed;
  else if (key == '/')
    slashPressed=pressed;
  else if (key == 'q')
    qPressed=pressed;
  else if (key == 'e')
    ePressed=pressed;

}

int inBounds(int cannonNum) {      // gives 1 if the specified tank is out of bounds on the left boundry(different for each tank), 2 if out of bounds on right boundry (different for each tank)
                                                                                              //or -1 if not out of bounds;
  if (cannonNum == 2) {
    if ((bowserX + LENGTH_AND_WIDTH_OF_TANK) > 750)
      return 2;
    else if ((bowserX + LENGTH_AND_WIDTH_OF_TANK) < 500)
      return 1;
  } 
  else {
    if (marioX < 50 )
      return 1;
    else if (marioX > 300)
      return 2;
  }

  return -1;
}



import java.text.DecimalFormat;

class Cannonball {

  private final double DELTA_T; // the amount of change
  private final double GRAVITY; // the effect of gravity (m/sec^2)5g
  private double t; // the time (seconds)
  private double vX; // the velocity in the x direction
  private double vY; // the velocity in the y direction
  private double vert; // the vertical position
  private double hor; // the horixibtal position
  private double v;
  private double a;

  private DecimalFormat f = new DecimalFormat("#.##");  //added to round numbers to the hundreths place, is imediately changed back into a double after the rounding. 

  /**
   * Creates a cannonball object given a velocity and angle
   * 
   * @param v the initial velocity
   * @param a the angle of the shot
   */
  public Cannonball(double v, double a) {

    DELTA_T = 0.1;
    GRAVITY = 9.81;
    this.v = v;
    this.a = a;

    if (a != 90)
      vX = v * Math.cos(Math.toRadians(a));
    else
      vX = 0;

    vY = v * Math.sin(Math.toRadians(a));

    vert = 0;
    hor = 0;
    t = 0;
  }


  /**
   * Updates many of the variables after the time DELTA_T has passed
   */
  public void updatePos() {

    vert += vY * DELTA_T;
    hor += vX * DELTA_T;
    vY -= GRAVITY * DELTA_T;
    t = Double.parseDouble(f.format(t + DELTA_T));
  }

  /**
   * Returns the vertical value
   * @return the vertical value
   */
  public double getVertical() {
    return vert;
  }

  /**
   * returns the horizontal value
   * @return the horizontal value
   */
  public double getHorizontal() {
    return hor;
  }

  /**
   * resets the cannonball
   *
   */
  public void reset() {
    vert=0;
    hor=0;
  }
  
   /**
   * sets the velocity
   * @return v the velocity
   */
  public void setVelocity(double v) {
   reset();
   this.v=v;
   updateAngle(a);
    
  }
  
  public void updateAngle(double a) {
    
    this.a=a;
   
    if (a != 90)
      vX = v * Math.cos(Math.toRadians(a));
    else
      vX = 0;

    vY = v * Math.sin(Math.toRadians(a));
    
  }


  /**
   * returns the current time
   * @return the current time
   */
  public double getT() {
    return t;
  }
}



