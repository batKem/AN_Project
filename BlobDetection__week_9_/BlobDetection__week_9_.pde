import java.util.ArrayList;
import java.util.List; 
import java.util.TreeSet;
import java.util.Collections;



PImage img;
void settings() {
        size(200, 200 ,P3D);
}
void setup() {
   img = loadImage("BlobDetection_Test.png");
    noLoop();
    //noStroke();
 
}
void draw() {
  BlobDetection test = new BlobDetection();
  PImage img2 = test.findConnectedComponents(img, false);
        image(img2, 0, 0);
    }


 class BlobDetection {
  PImage findConnectedComponents(PImage input, boolean onlyBiggest){
    
    // First pass: label the pixels and store labels' equivalences
    
    int [] labels = new int [input.width*input.height];
    List<TreeSet<Integer>> labelsEquivalences= new ArrayList<TreeSet<Integer>>();
        
    int currentLabel = 1;
    labelsEquivalences.add(new TreeSet<Integer>());
    
    input.loadPixels();
    int n1 = 0;
    int n2 = 0;
    int n3 = 0;
    int n4 = 0;
     int pix = 0;
    
    for(int j = 0 ; j < input.height ; j++) {
      for(int i = 0 ; i < input.width ; i++) {
       //for(int j = 0 ; j < 1 ; j++) {
      //for(int i = 0 ; i < 200 ; i++) {

        n1 = 0;
        n2 = 0;
        n3 = 0;
        n4 = 0;
        
       
        
        
        if(input.get(i, j) >= -1) {
         
          
          //check neighbour 1
          if(i > 0 && j > 0){
            n1 = labels[i-1+ (j-1)*input.width];
          }
          //check neighbour 2, 3
          if(j > 0){
            n2 = labels[i+ (j-1)*input.width];
            if(i < input.width -1){
              n3 = labels[i+1+ (j-1)*input.width];
            }
          }
          
          //check neighbour 4
          if(i > 0){
            n4 = labels[i-1+ (j)*input.width];
          }
          
          if(n1 == 0 && n2 == 0 && n3 == 0 && n4 == 0){
            labels[i + j*input.width] = currentLabel;
            
            
            
            currentLabel++;
           labelsEquivalences.add(new TreeSet<Integer>());

          } else {
            //keeping the ones that aren't 0
              int n12 = 0;
              int n34 = 0;
              int n1234 = 0;
              if (n1 != 0){
                if (n2 != 0){
                   n12 = Math.min(n1,n2);
                } else { n12 = n1;
                }
              } else if(n2!= 0){ n12 = n2;}
              if (n3 != 0){
                if (n4 != 0){
                   n34 = Math.min(n3,n4);
                } else { n34 = n3;
                }
              } else if(n4!= 0){ n34 = n4;}
            if ((n12 !=0) && (n34 != 0)) { n1234 = Math.min(n12,n34);
              } else if(n12 != 0){n1234 = n12;}
                else {n1234 = n34;}
            
            
            labels[i + j*input.width] = n1234;
            
            if(n1 != 0) labelsEquivalences.get(n1 -1).add(n1234);
            if(n2 != 0) labelsEquivalences.get(n2 -1).add(n1234);
            if(n3 != 0) labelsEquivalences.get(n3 -1).add(n1234);
            if(n4 != 0) labelsEquivalences.get(n4 -1).add(n1234);
         }
      }
    }
    }
      
        
    // Second pass: re-label the pixels by their equivalent class
    // if onlyBiggest==true, count the number of pixels for each label
    

    int [] countArray = new int [currentLabel];
  
  for(int i = 16000; i < 16200 ; i++) {
    
  }
    //redo
    for(int i = 0; i < labels.length ; i++) {
      if(input.pixels[i] >= -1) {
        
        labels[i] = labelsEquivalences.get(labels[i]-1).first();
        if(onlyBiggest) {countArray[labels[i]-1]++;}
      }
    }
    
   
    
    // Finally,
    // if onlyBiggest==false, output an image with each blob colored in one uniform color
    // if onlyBiggest==true, output an image with the biggest blob colored in white and the others in black
    PImage output = input.copy();
    output.loadPixels();
    
    if(!onlyBiggest) {
      for(int j = 0 ; j < output.height ; j++) {
        for(int i = 0 ; i < output.width ; i++) {
          int l = labels[i + j*output.width];
          output.pixels[i + j*output.width] = color((l*1234)%256, (l*2345)%256, (l*3456)%256); //"random" colors
        }
      }
    } else {
      int maxIndex = 0;
      int count = 0;
      for (int n = 0; n < countArray.length; n++) {
        if (countArray[n] > count) {
          maxIndex = n;
          count = countArray[n];
          
        }
      }
      
      int biggestBlobLabel = labelsEquivalences.get(maxIndex).first();
      for(int j = 0 ; j < output.height ; j++) {
        for(int i = 0 ; i < output.width ; i++) {
          int l = labels[i + j*output.width];
          if (l == biggestBlobLabel) {
            output.pixels[i + j*output.width] = color(255, 255, 255);
          } else {   output.pixels[i + j*output.width] = color(0, 0, 0); }
          
        }
      }
    }
    
    return output;
      
     
  }
}