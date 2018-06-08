import gab.opencv.*;


import processing.video.*;

float depth = 2000.0;
float fovy = PI/3.0;
ImageProcessing imgproc;


//global rotation values
	PVector gravityForce;
	float gravityConstant;
	PShape cylinder;
	ArrayList<PVector> cylinders;
  float rotationScale=1.0;
  PVector cylinderScale;
  Chart scoreChart;
  HScrollbar scrollBar;

float rx=0 ;
float rz=0 ;

float boardX, boardY;

int[] score;

boolean shiftMode;
PGraphics gameSurface;
PGraphics topView;
PGraphics scoreText;
PGraphics scorePanel;
PGraphics scrollBarPanel;


Movie m;

Mover ball;

void settings() {
	size(1000, 1000, P3D);
}

void setup() {
  OpenCV opencv = new OpenCV(this, 100, 100);
  
  m= new Movie(this, "testvideo.avi");
  m.loop();
  
  boardX = 600;
  boardY = 600;
  
  //To call webcam
  imgproc = new ImageProcessing(m);
  String []args = {"Image processing window"};
  PApplet.runSketch(args, imgproc);
  delay(3500);
  //To call webcam

	noStroke();
  score = new int[1];
  
  scoreChart = new Chart(5,1,10);
  scrollBar = new HScrollbar(310,((int)height*0.96),(height*0.68),(height*0.03));
  
  
  this.cylinderScale =new PVector(50,100,50);
  
  gameSurface = createGraphics(width, (int)(height*0.8), P3D);
  topView = createGraphics((int)(height*0.18),(int)(height*0.18),P2D);
  scoreText = createGraphics((int)(height*0.1),(int)(height*0.18),P2D);
  scorePanel = createGraphics((int)(height*0.68),(int)(height*0.15),P2D);

	ball =new Mover(boardX, boardY);
	gravityForce= new PVector();
	gravityConstant = -0.8;

	cylinders= new ArrayList<PVector>();
	cylinder = loadShape("cylinder.obj");
  
  
  
	shiftMode=false;
}

void draw() {
  //To call webcam
  // PVector rot = imgproc.getRotation();
  //To call webcam

  background(700);
  drawGame(gameSurface);
  image(gameSurface,0,0);
  topView(topView);
  image(topView,10,(int)height*0.81);
  textScore(scoreText);
  image(scoreText,200,(int)height*0.81);
  scorePanel(scorePanel);
  image(scorePanel,310,(int)height*0.81);
   scrollBar.display();
   scrollBar.update();






       PVector rots= imgproc.getRotation(m.get());

    if (rots != null){
      System.out.println(rots);

      //I think it shouldnt be += but =
      rx= rots.x;
      // rx+= radians((mouseX-pmouseX)*rotationScale) ;
      rz= rots.z; //In Week12 - 2 its said that we have to use x & y, no mention for z
      // rz+= radians(-(mouseY-pmouseY)*rotationScale);
      

      //bounderies
      rx = min(radians(60),max(rx,radians(-60))); 
      rz = min(radians(60),max(rz,radians(-60)));
    }
    else
      System.out.println("nulllll");
  
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
  
  
	ball.checkEdges(score);
	ball.checkCylinderCollision(cylinders, this.cylinderScale.x,score);
	ball.display(s);

	s.popMatrix();

  s.pushMatrix();
  
  
  for (PVector v : cylinders){
    s.pushMatrix();
    
    s.translate(v.x,-100,v.z);
    s.scale(cylinderScale.x,cylinderScale.y,cylinderScale.z);
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
      s.scale(cylinderScale.x,cylinderScale.y,cylinderScale.z);
      s.shape(cylinder);
      s.popMatrix();
    }
  
  
  
    s.popMatrix();
    //arbitrary size for the box, you can modify this as you like

    //translate(0,80,0);
    s.box(boardX,boardY,0);



  s.popMatrix();
  
  }
  
    void topView(PGraphics s){
      s.beginDraw();
      s.background(150);
      s.pushMatrix();
      s.stroke(0);
    //rotating on the X axis first so that this axis 
    //remains a global axis, and the Z axis will be a local axis

    //ball's matrix
    s.pushMatrix();
    
    //ball.display2D(s);
    //s.fill(0);
    //
    s.fill(0);
    ball.display2D(s,height*0.18);
    s.popMatrix();

    s.pushMatrix();
  
  
    for (PVector v : cylinders){
      
      s.pushMatrix();
      s.fill(255,255,255);
      float x = map(v.x, -boardX/2.0,boardX/2.0, 0.0, height*0.18);
      float z = map(v.z, -boardY/2.0,boardY/2.0, 0.0, height*0.18);
      s.ellipse(x,z, s.width*cylinderScale.x/(boardX/2),s.height*cylinderScale.z/(boardY/2));
      s.popMatrix();
    }
  
  
  
    s.popMatrix();
    



  s.popMatrix();
  s.endDraw();
  
  }
   void textScore(PGraphics s){
      s.beginDraw();
      s.background(150);
      
      s.stroke(0);
      s.text("v="+ball.norm(ball.velocity),10,10);
      s.text("s="+score[0],10,20);
      s.endDraw();
  
  }
     void scorePanel(PGraphics s){
      s.beginDraw();
      s.background(150);
      
      s.stroke(0);
     //s.text("scorePanel",10,10);
      scoreChart.update(score[0]);
      scoreChart.render(s, (scrollBar.getPos()));
      s.endDraw();
  
  }
   void scrollBar(PGraphics s){
      s.beginDraw();
      s.background(150);
      
      s.stroke(0);
      scrollBar.display();
      //scrollBar.update();
      s.endDraw();
  
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
	if(shiftMode  && mouseY < width*0.8){
		//print(
    
    
		float mx = map(mouseX,0,gameSurface.width,- boardX,boardX);
		float my = map(mouseY,0,gameSurface.height,-boardY*( gameSurface.height/(float)gameSurface.width),
                                                    boardY*( gameSurface.height/(float)gameSurface.width));
    mx = min(boardX/2,max(-boardX/2, mx));
    my = min(boardY/2,max(-boardY/2, my));
		cylinders.add(new PVector(mx,0,my));}
	
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  if( e !=0  && mouseY < width*0.8){
  float sign = e/ abs(e);
  rotationScale += 0.05*sign;
  rotationScale = min( 2,max(0.1, rotationScale));}
 
}

void mouseDragged(){
/*
	if (!shiftMode && mouseY < width*0.8){
    

   

     
      
      rx+= radians((mouseX-pmouseX)*rotationScale) ;

      //bounderies
      rx = min( radians(60),max(rx,radians(-60)));

      rz+= radians(-(mouseY-pmouseY)*rotationScale);
      rz = min( radians(60),max(rz,radians(-60)));
    }*/
   

	
}
