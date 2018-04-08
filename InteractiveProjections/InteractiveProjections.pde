
float currentScale=1;
float currentXAngle=0;
float currentYAngle=0;
ArrayList<My3DBox> objects=new ArrayList<My3DBox>() ;
My3DPoint eye, origin;

int MAX_SCALE=10;

void settings(){
  size (1000,1000, P2D);
}

void setup(){}

void draw(){
  /*
  My3DPoint eye = new My3DPoint(-100, -100, -5000);
  My2DPoint p1 = projectPoint(eye, new My3DPoint(0, 0, 0));
  My2DPoint p2 = projectPoint(eye, new My3DPoint(100, 0, 0));
  My2DPoint p3 = projectPoint(eye, new My3DPoint(100, 150, 0));
  My2DPoint p4 = projectPoint(eye, new My3DPoint(100, 150, 300));
  line (p1.x, p1.y, p2.x, p2.y);
  line (p2.x, p2.y, p3.x, p3.y);
  line (p3.x, p3.y, p4.x, p4.y);*/
  
  /*
  My3DPoint eye = new My3DPoint(-100, -100, -5000);
My3DPoint origin = new My3DPoint(0, 0, 0); //The first vertex of your cuboid
My3DBox input3DBox = new My3DBox(origin, 100,150,300);
projectBox(eye, input3DBox).render();*/
  background(255, 255, 255);
eye = new My3DPoint(0, 0, -5000);
origin = new My3DPoint(0, 0, 0);

My3DBox input3DBox = new My3DBox(origin, 100, 150, 300);
//objects.add(input3DBox);
//rotated around x
//float[][] transform1 = rotateXMatrix(PI/8);
//input3DBox = transformBox(input3DBox, transform1);
input3DBox = transformBox(input3DBox, scaleMatrix(currentScale));
input3DBox = transformBox(input3DBox, rotateXMatrix(currentXAngle));
input3DBox = transformBox(input3DBox, rotateYMatrix(currentYAngle));
projectBox(eye, input3DBox).render();
//rotated and translated
/*float[][] transform2 = translationMatrix(200, 200, 0);
input3DBox = transformBox(input3DBox, transform2);
projectBox(eye, input3DBox).render();
//rotated, translated, and scaled
float[][] transform3 = scaleMatrix(2, 2, 2);
input3DBox = transformBox(input3DBox, transform3);
projectBox(eye, input3DBox).render();*/



}


My2DPoint projectPoint(My3DPoint eye, My3DPoint p){
   float xp = (p.x -eye.x) * (-eye.z/(p.z-eye.z));
   float yp = (p.y -eye.y) * (-eye.z/(p.z-eye.z));
  
  return new My2DPoint(xp, yp);
  }

My2DBox projectBox(My3DPoint eye, My3DBox box){
  My2DPoint[] s= new My2DPoint[box.p.length]; 
  
  for (int i=0; i<box.p.length;++i){
    s[i] = projectPoint(eye,box.p[i]);
  }
  
  
  return new My2DBox(s);
}


float[] homogeneous3DPoint (My3DPoint p){

  float [] result ={p.x, p.y, p.z, 1};
  return result;
  
}

float[][] rotateXMatrix(float angle) {
      return(new float[][] {{1, 0 , 0 , 0},
                            {0, cos(angle), sin(angle) , 0},
                            {0, -sin(angle) , cos(angle) , 0},
                            {0, 0 , 0 , 1}});
}
float[][] rotateYMatrix(float angle) {
      return(new float[][] {{cos(angle), 0 , sin(angle) , 0},
                            {0,          1 ,    0   ,     0},
                            {-sin(angle),0 , cos(angle) , 0},
                            {0,          0 ,    0 ,       1}});
}
float[][] rotateZMatrix(float angle) {
      return(new float[][] {{cos(angle), sin(angle) ,0  , 0},
                            {-sin(angle),cos(angle) ,0  , 0},
                            {   0       ,     0 ,    1 ,  0},
                            {   0,            0 ,    0 ,  1}});
}
float[][] scaleMatrix(float x, float y, float z) {
      return(new float[][] {{x, 0 ,0  , 0},
                            {0, y ,0  , 0},
                            {0, 0 ,z  , 0},
                            {0, 0 ,0 ,  1}});
}
float[][] scaleMatrix(float x) {
      return(new float[][] {{x, 0 ,0  , 0},
                            {0, x ,0  , 0},
                            {0, 0 ,x  , 0},
                            {0, 0 ,0 ,  1}});
}
float[][] translationMatrix(float x, float y, float z) {
      return(new float[][] {{1, 0 ,0  , x},
                            {0, 1 ,0  , y},
                            {0, 0 ,1  , z},
                            {0, 0 ,0 ,  1}});
}

float[] matrixProduct(float[][]a, float[]b){
  float[] result = new float[a.length];
  for( int i=0; i<a.length; ++i){
    float r =0;
    
    for ( int j =0; j< a[i].length; j++ ){
      r+= a[i][j] *b[j];
    
    }
    result[i] = r;
  }
  return result;
}

My3DBox transformBox(My3DBox box, float[][] transformMatrix){
  
  My3DPoint[] p = new My3DPoint[box.p.length];
  for (int i=0; i< box.p.length; ++i){
  
    p[i] =euclidian3DPoint( matrixProduct(transformMatrix, homogeneous3DPoint(box.p[i])) );
  }
  
  
  return new My3DBox(p);
  
}

My3DPoint euclidian3DPoint (float[] a) {
  My3DPoint result = new My3DPoint(a[0]/a[3], a[1]/a[3], a[2]/a[3]);
  return result;
}

void renderObjects(){
  for (My3DBox box :objects){
    projectBox(eye, box).render();
  }
}


void mouseDragged(){

  
  currentScale += 2*(mouseY-pmouseY)/(float)height;
  currentScale = min(max(currentScale,0),MAX_SCALE);
  
  
  
}

void keyPressed(){
  
  if (key ==CODED){
    
    if(keyCode == UP){
      
      currentXAngle+=PI/10;
    }
    else if (keyCode== DOWN){
      currentXAngle -= PI/10;
      
    }
     if(keyCode == LEFT){
      
      currentYAngle+=PI/10;
    }
    else if (keyCode== RIGHT){
      currentYAngle -= PI/10;
      
    }
  }
  

}