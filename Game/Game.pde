float depth = 2000;

//global rotation values
	PVector gravityForce;
	float gravityConstant;
	PShape cylinder;
	ArrayList<PVector> cylinders;

float rx=0 ;
float rz=0 ;

boolean shiftMode;

Mover ball;

void settings() {
	size(500, 500, P3D);
}

void setup() {
	noStroke();
	ball =new Mover();
	gravityForce= new PVector();
	gravityConstant = -0.8;

	cylinders= new ArrayList<PVector>();
	cylinder = loadShape("cylinder.obj");

	shiftMode=false;
}

void draw() {
	camera(width/2, height/2, depth, 250, 250, 0, 0, 1, 0);
	directionalLight(50, 100, 125, 0, 1, 0);
	ambientLight(102, 102, 102);
	background(200);
	translate(width/2, height/2, 0);



  if (!shiftMode){
  
  run();
  }
  else{
  shiftMode();}
  
  


}

void run(){
	grav();
  translate(0,400,0);
	pushMatrix();
	//rotating on the X axis first so that this axis 
	//remains a global axis, and the Z axis will be a local axis
	rotateX(rz);
	rotateZ(rx);

	//ball's matrix
	pushMatrix();
	ball.update();
	ball.checkEdges();
	//Working on this
	ball.checkCylinderCollision(cylinders);
	//End of Working on this
	ball.display();

	popMatrix();

  pushMatrix();
  
  
  for (PVector v : cylinders){
    pushMatrix();
    
    translate(v.x,-100,v.z);
    scale(100,100,100);
    shape(cylinder);
    popMatrix();
  }
 

	popMatrix();

	//arbitrary size for the box, you can modify this as you like
	translate(0,80,0);
	box(1000,60,1000);

	popMatrix();
}


  void shiftMode(){
      pushMatrix();
    //rotating on the X axis first so that this axis 
    //remains a global axis, and the Z axis will be a local axis

    //ball's matrix
    pushMatrix();
    rotateX(-PI/2);
    ball.display();

    popMatrix();

    pushMatrix();
  
  
    for (PVector v : cylinders){
      
      pushMatrix();
      rotateX(PI/2);
      translate(v.x,0,-v.z);
      scale(100,100,100);
      shape(cylinder);
      popMatrix();
    }
  
  
  
    popMatrix();
    //arbitrary size for the box, you can modify this as you like

    //translate(0,80,0);
    box(1000,1000,0);



  popMatrix();
  
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
		print(mouseX+","+mouseY+"\n");
		float mx = map(mouseX,140,360,-500,500);
		float my = map(mouseY,140,360,-500,500);
    if (!( mouseX<140 || mouseX>360 || mouseY<140 || mouseY>360))
		cylinders.add(new PVector(mx,0,my));
	}
}

void mouseDragged(){
	if (!shiftMode){
		rx+= radians((mouseX-pmouseX));

		//bounderies
		rx = min( radians(60),max(rx,radians(-60)));

		rz+= radians(-(mouseY-pmouseY));
		rz = min( radians(60),max(rz,radians(-60)));
	}
}