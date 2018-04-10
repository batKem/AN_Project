class gameRender{
	
	float depth = 2000;

	//global rotation values
	PVector gravityForce;
	float gravityConstant;
	PShape cylinder;
	ArrayList<PVector> cylinders;
	float rotationScale=1.0;

	float rx=0 ;
	float rz=0 ;

	boolean shiftMode;

	Mover ball;

	PGraphics p;

	public gameRender (PGraphics p){
		this.p = p;
		ball =new Mover();
		gravityForce= new PVector();
		gravityConstant = -0.8;

		cylinders= new ArrayList<PVector>();
		cylinder = loadShape("cylinder.obj");
	  
		shiftMode=false;	
	}

	void draw() {
		p.beginDraw();
		p.camera(width/2, height/2, depth, 250, 250, 0, 0, 1, 0);
		p.directionalLight(50, 100, 125, 0, 1, 0);
		p.ambientLight(102, 102, 102);
		p.background(200);
		p.translate(width/2, height/2, 0);

		if (!shiftMode){
			run();
		} else{
			shiftMode();
		}
		p.endDraw();
	}

void run(){
	grav();
  	p.translate(0,400,0);
	p.pushMatrix();
	//rotating on the X axis first so that this axis 
	//remains a global axis, and the Z axis will be a local axis
	p.rotateX(rz);
	p.rotateZ(rx);

	//ball's matrix
	p.pushMatrix();
	ball.update();
	ball.checkEdges();
	//Working on this
	ball.checkCylinderCollision(cylinders);
	//End of Working on this
	ball.display(p);

	p.popMatrix();

  	p.pushMatrix();
  
	for (PVector v : cylinders){
		p.pushMatrix();

		p.translate(v.x,-100,v.z);
		p.scale(100,100,100);
		p.shape(cylinder);
		p.popMatrix();
	}

	p.popMatrix();

	//arbitrary size for the box, you can modify this as you like
	p.translate(0,80,0);
	p.box(1000,60,1000);

	p.popMatrix();
}


void shiftMode(){
	p.pushMatrix();
	//rotating on the X axis first so that this axis 
	//remains a global axis, and the Z axis will be a local axis

	//ball's matrix
	p.pushMatrix();
	p.rotateX(-PI/2);
	ball.display(p);

	p.popMatrix();

	p.pushMatrix();

	for (PVector v : cylinders){
		p.pushMatrix();
		p.rotateX(PI/2);
		p.translate(v.x,0,-v.z);
		p.scale(100,100,100);
		p.shape(cylinder);
		p.popMatrix();
	}

	p.popMatrix();
	//arbitrary size for the box, you can modify this as you like

	//translate(0,80,0);
	p.box(1000,1000,0);

	p.popMatrix();
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
	// print("clicked ");
	if(shiftMode){
		print(mouseX+","+mouseY+"\n");
		float mx = map(mouseX,140,360,-500,500);
		float my = map(mouseY,140,360,-500,500);
    if (!( mouseX<140 || mouseX>360 || mouseY<140 || mouseY>360))
		cylinders.add(new PVector(mx,0,my));
	}
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  if( e !=0){
  float sign = e/ abs(e);
  rotationScale += 0.05*sign;
  rotationScale = min( 2,max(0.1, rotationScale));}
  //print(rotationScale);
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
}