class My2DBox{

  My2DPoint[] s;
  My2DBox (My2DPoint[] s){
    this.s =s;
  }
  void render(){
    
    
    for ( int i=0; i<2; ++i){
      for(int j=0; j<4; ++j){
        My2DPoint p1= s[i*4+j];
        My2DPoint p2 = s[i*4+(j+1)%4];
        line( p1.x, p1.y, p2.x, p2.y);
        if(i ==0){
          My2DPoint p3 = s[i*4+j+4];
          line(p1.x, p1.y, p3.x, p3.y);
        }
    
      }
    }
    
    
    
  }
}