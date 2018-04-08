class My3DPoint{

  float x,y,z;
  My3DPoint(float x, float y, float z){
    this.x=x;
    this.y=y;
    this.z=z;
  }
  
  My3DPoint substract(My3DPoint p){
  return new My3DPoint( this.x-p.x, this.y-p.y, this.z-p.z);
  
  }
}