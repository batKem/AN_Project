float depth = 2000.0;
float fovy = PI/3.0;



//global rotation values
	PVector gravityForce;
	float gravityConstant;
	PShape cylinder;
	ArrayList<PVector> cylinders;
  float rotationScale=1.0;

float rx=0 ;
float rz=0 ;

float boardX, boardY;

boolean shiftMode;
PGraphics gameSurface;

Mover ball;

void settings() {
	size(1000, 1000, P3D);
}

void setup() {
	noStroke();

  gameSurface = createGraphics(width, (int)(height*0.8), P3D);

	ball =new Mover();
	gravityForce= new PVector();
	gravityConstant = -0.8;

	cylinders= new ArrayList<PVector>();
	cylinder = loadShape("cylinder.obj");
  
  boardX = 1000;
  boardY = 1000;
  
	shiftMode=false;
}

void draw() {
  drawGame(gameSurface);
  image(gameSurface,0,0);

}

void drawGame(PGraphics s){
  s.beginDraw();
  
  s.camera(s.width/2, s.height/2, depth, s.width/2, s.height/2, 0, 0, 1, 0);
 
  s.directionalLight(50, 100, 125, 0, 1, 0);
  s.ambientLight(102, 102, 102);
  s.background(200);
  s.translate(s.width/2.0, s.height/2.0, 0);



  if (!shiftMode){
   s.perspective(fovy,s.width/s.height, 1,30000);
  run(s);
  }
  else{
    s.ortho(-boardX, boardX, -boardY*( s.height/(float)s.width), boardY*( s.height/(float)s.width), -depth*2, depth*2) ;

  shiftMode(s);}
  s.endDraw();
  
}

void run(PGraphics s){
	grav();
  s.translate(0,400,0);
	s.pushMatrix();
	//rotating on the X axis first so that this axis 
	//remains a global axis, and the Z axis will be a local axis
	s.rotateX(rz);
	s.rotateZ(rx);

	//ball's matrix
	s.pushMatrix();
	ball.update();
	ball.checkEdges();
	//Working on this
	ball.checkCylinderCollision(cylinders);
	//End of Working on this
	ball.display(s);

	s.popMatrix();

  s.pushMatrix();
  
  
  for (PVector v : cylinders){
    s.pushMatrix();
    
    s.translate(v.x,-100,v.z);
    s.scale(100,100,100);
    s.shape(cylinder);
    s.popMatrix();
  }
 

	s.popMatrix();

	//arbitrary size for the box, you can modify this as you like
	s.translate(0,80,0);
	s.box(boardX,60,boardY);

	s.popMatrix();
}


  void shiftMode(PGraphics s){
      s.pushMatrix();
    //rotating on the X axis first so that this axis 
    //remains a global axis, and the Z axis will be a local axis

    //ball's matrix
    s.pushMatrix();
    s.rotateX(-PI/2);
    ball.display(s);

    s.popMatrix();

    s.pushMatrix();
  
  
    for (PVector v : cylinders){
      
      s.pushMatrix();
     s.rotateX(PI/2);
      s.translate(v.x,0,-v.z);
      s.scale(100,100,100);
      s.shape(cylinder);
      s.popMatrix();
    }
  
  
  
    s.popMatrix();
    //arbitrary size for the box, you can modify this as you like

    //translate(0,80,0);
    s.box(boardX,boardY,0);



  s.popMatrix();
  
  }


void grav(){
	gravityForce.x =- sin(rx) * gravityConstant;
	gravityForce.z = sin(rz) * gravityConstant;
	float normalForce= 1;
	float mu = 0.01;
	float frictionMagnitude= normalForce* mu;
	PVector friction= ball.velocity.copy();
	friction.mult(-1);
	friction.normalize();
	friction.mult(frictionMagnitude);
	ball.velocity.add(gravityForce.add(friction));
}

void keyPressed(){
	shiftMode =(keyCode == SHIFT);
}

void keyReleased(){
	shiftMode = !(keyCode == SHIFT);
} 

void mouseClicked(){
	if(shiftMode){
		
    if (mouseY< gameSurface.height){
    
		float mx = map(mouseX,0,gameSurface.width,- boardX,boardX);
		float my = map(mouseY,0,gameSurface.height,-boardY*( gameSurface.height/(float)gameSurface.width),
                                                    boardY*( gameSurface.height/(float)gameSurface.width));
    mx = min(boardX/2,max(-boardX/2, mx));
    my = min(boardY/2,max(-boardY/2, my));
		cylinders.add(new PVector(mx,0,my));}
	}
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  if( e !=0){
  float sign = e/ abs(e);
  rotationScale += 0.05*sign;
  rotationScale = min( 2,max(0.1, rotationScale));}
  print(rotationScale);
}

void mouseDragged(){
	if (!shiftMode){
		rx+= radians((mouseX-pmouseX)*rotationScale) ;

		//bounderies
		rx = min( radians(60),max(rx,radians(-60)));

		rz+= radians(-(mouseY-pmouseY)*rotationScale);
		rz = min( radians(60),max(rz,radians(-60)));
	}
}