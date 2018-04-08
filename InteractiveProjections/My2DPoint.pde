class My2DPoint{
  float x;
  float y;
  My2DPoint(float x, float y){
    this.x =x;
    this.y=y;
  }
  
  My2DPoint substract( My2DPoint that){
  
  return new My2DPoint (this.x-that.x, that.y-this.y);
  }
  
  @Override
  String toString(){
  return "("+ this.x + " , "+this.y+")";
  }
   
}