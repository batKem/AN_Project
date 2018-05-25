class Chart{
  
  ArrayList<Integer> data;
  float boxSize;
  float gap;
 
  
  float contTimeCounter, stepCounter, timeGap;
  
  public Chart(float boxSize, float gap, float timeGap){
    data = new ArrayList<Integer>();
    this.boxSize = boxSize;
    this.gap=gap;
    
    contTimeCounter =0.0;
    this.timeGap = timeGap;
  }
  
  void update(int score){
    contTimeCounter ++;
    stepCounter += (int)contTimeCounter/timeGap;
    
    if( (int)contTimeCounter/timeGap >=1){
      data.add(score);
    }
    
    
    contTimeCounter %= timeGap;
    
    
    
  }
  
  int maxValue(ArrayList<Integer> list){
    int max = Integer.MIN_VALUE;
    for (int i : list){
      max = i>max? i:max;
    }
    return max;
  }
  
  void renderBar( int horizontalIndex, int score,int maxValue, PGraphics s, float hnb){
    int nb_of_boxes = (int)(score/(boxSize+gap));
    s.noStroke();
    float relativeBoxSize = score!=0? min(boxSize, boxSize*(s.height/(float)maxValue)): boxSize;
    float relativegap = score!=0? min(gap, gap*(s.height/(float)maxValue)): gap;
    relativegap = 0;
    
    for (int y =0; y<nb_of_boxes; y++){
      s.rect(horizontalIndex, s.height-(y* (relativeBoxSize+relativegap)), boxSize*hnb, relativeBoxSize);
    }
  }
  
  void renderBars(ArrayList<Integer> dataSet, PGraphics s, float hnb ){
    int horizontalIndex =0;
    
   
    
    for (int index = 0; index< dataSet.size(); index++){
      horizontalIndex+= boxSize*hnb;
      renderBar(horizontalIndex, dataSet.get(index), maxValue(dataSet), s, hnb);
    }
  }
  void render(PGraphics s, float hnb){
    renderBars(data, s, hnb);
  }
  

  


}