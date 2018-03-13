float depth = 2000;

//global rotation values
float rx ;
float rz ;

void settings() {
size(500, 500, P3D);
}
void setup() {
noStroke();

}

void draw() {
camera(width/2, height/2, depth, 250, 250, 0, 0, 1, 0);
directionalLight(50, 100, 125, 0, -1, 0);
ambientLight(102, 102, 102);
background(200);


pushMatrix();
translate(width/2, height/2, 0);

//rotating on the X axis first so that this axis 
//remains a global axis, and the Z axis will be a local axis
rotateX(rz);
rotateZ(rx);

//arbitrary size for the box, you can modify this as you like
box(1000,60,1000);
popMatrix();

}


void mouseDragged(){
 
  
  rx+= radians((mouseX-pmouseX));
  
  //bounderies
  rx = min( radians(60),max(rx,radians(-60)));
  
  rz+= radians(-(mouseY-pmouseY));
  rz = min( radians(60),max(rz,radians(-60)));

}