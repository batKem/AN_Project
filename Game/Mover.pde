class Mover{
  PVector location;
  PVector velocity;
  float X_MAX=200;
  float X_MIN = -200;
  float Y_MAX=200;
  float Y_MIN = -200;
  
  Mover(){
    location =new PVector(0, 0,0);
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
   
   if(location.x > 500) {
     velocity.x *= -0.5; 
     }
    else if(location.x < -500) {
      velocity.x *= -0.5; 
 
  }
  if(location.z > 500) {
    velocity.z *= -0.5; 

  }
  else if(location.z < -500) {
    velocity.z *= -0.5; 

  }
  
  //fixing a bug where the ball keeps falling out of range because
  // its speed kept being multiplied by -1 which led to negative speed values being
  // positive ones since gravity adds up
  location.x = max(-500,min(location.x,500));
  location.z = max(-500,min(location.z,500));  
  
  }
  
}