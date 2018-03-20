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

	if (!shiftMode)
		run();
}

void run(){
	grav();
	pushMatrix();
	//rotating on the X axis first so that this axis 
	//remains a global axis, and the Z axis will be a local axis
	rotateX(rz);
	rotateZ(rx);

	//ball's matrix
	pushMatrix();
	ball.update();
	ball.checkEdges();
	ball.display();

	popMatrix();

	pushMatrix();

	for (PVector v : cylinders){
		pushMatrix();

		translate(v.x,0,v.y);
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
		print(mouseX+","+mouseY);
		float mx = map(mouseX,0,width,-500,500);
		float my = map(mouseY,0,height,-500,500);
		cylinders.add(new PVector(mx,my));
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