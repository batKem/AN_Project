class Mover{
  PVector location;
  PVector velocity;
  float X_MAX=200;
  float X_MIN = -200;
  float Y_MAX=200;
  float Y_MIN = -200;
  
  Mover(){
    location =new PVector(width/2, height/2,0);
    velocity= new PVector(0,0,0);
  }
  
  void update(){
    location.add(velocity);
  }
  
  void display(){
    translate(location.x, location.y, location.z);
    sphere(50);
  }
  
  void checkEdges(){
  
   if(location.x > width) {
     velocity.x *= -1; 
     }
    else if(location.x < 0) {
      velocity.x *= -1; 
 
}
if(location.y > height) {
  velocity.z *= -1; 

}
else if(location.y < 0) {
  velocity.z *= -1; 

}
    

  
  }
  
}