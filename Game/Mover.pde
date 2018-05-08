class Mover{
	
	PVector location;
	PVector velocity;
	float X_MAX=200;
	float X_MIN = -200;
	float Y_MAX=200;
	float Y_MIN = -200;
  
  final float radius =50;
  float cylinderRadius = 100;
  
	Mover(){
		location =new PVector(0, 0,0);
		velocity= new PVector(0,0,0);
	}

	void update(){
		location.add(velocity);
	}

	void display(PGraphics s){
		s.translate(location.x, location.y, location.z);
		s.sphere(radius);
	}

  void display2D(PGraphics s, float dimension){
    //s.translate(location.x, location.y, location.z);
    
    float x = map(location.x, -500.0,500.0, 0.0, dimension);
    float z = map(location.z, -500.0,500.0, 0.0, dimension);
    
    s.ellipse(x, z, radius*dimension/500, radius*dimension/500);
  }

	void checkEdges(int[] score){
    
		if(location.x > 500) {
      score[0] -= (int)norm(velocity);
			velocity.x *= -0.5; 
		} else if(location.x < -500) {
      score[0] -= (int)norm(velocity);
			velocity.x *= -0.5; 
		} if(location.z > 500) {
      score[0] -= (int)norm(velocity);
			velocity.z *= -0.5; 
		} else if(location.z < -500) {
      score[0] -= (int)norm(velocity);
			velocity.z *= -0.5; 
		}
    
    score[0] = max(0, score[0]);
		/*fixing a bug where the ball keeps falling out of range because
			its speed kept being multiplied by -1 which led to negative speed values being
			positive ones since gravity adds up*/
		location.x = max(-500,min(location.x,500));
		location.z = max(-500,min(location.z,500));  
	}
  
  PVector rawNormal(PVector p){
    return new PVector(location.x-p.x,0, location.z-p.z);
  }
  
  
  float radialDistanceFromBall(PVector p1){
    float absoluteDistance = norm(rawNormal(p1));
    return absoluteDistance -radius -cylinderRadius;
  }
  
  PVector locationCorrectionVector(PVector p1){
    PVector normal = rawNormal(p1);
    float correctionNorm = cylinderRadius-norm(normal)+radius;
    PVector normalized = normalize(normal);
    return normalized.mult(correctionNorm);
  
  }

  
  float norm(PVector p){
    return sqrt(p.x*p.x +p.y*p.y+p.z*p.z);
  }
  
  PVector normalize(PVector vector){
    return (vector.mult( (float)1/norm(vector) ));
  }
  
  float dotProduct(PVector p1, PVector p2){
    return p1.x*p2.x + p1.z*p2.z;
  }
  
  void newVelocity( PVector previousVelocity, PVector cylinder){
    
    PVector normal = normalize(rawNormal(cylinder));
    (previousVelocity.sub (  normal.mult(2*dotProduct(previousVelocity,normal) ) )).mult(0.8);
  
  }

	void checkCylinderCollision(ArrayList<PVector> cylinders, float cylinderRad, int[] score){
    this.cylinderRadius = cylinderRad;
  		for(PVector p: cylinders){
         
        if ( radialDistanceFromBall(p) <=0){
          score[0] += (int)norm(velocity);
          
          location.add(locationCorrectionVector(p));
          newVelocity(velocity, p);
          
        }
        
      }
      score[0] = max(0, score[0]);
  	}

}
