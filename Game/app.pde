	import java.util.*;

	import processing.video.*;

class ImageProcessing extends PApplet {


  Movie cam;
	PImage img;
	  	ArrayList<Integer> bestCandidates;
  public ImageProcessing(Movie m){
  
  this.cam = m;
  }

void settings() {
	size(640, 480);
}

	void setup() {
    
    cam.loop();
  

	}

	void draw(){
		//Camera

		if (cam.available() == true) 
			cam.read(); 
		img = cam.get(); 
		image(img, 0, 0);
		//Camera
	}

	public PVector getRotation(PImage img){
		List<PVector> lines, corners;
		QuadGraph qGraph = new QuadGraph();
		TwoDThreeD twoDThreeD = new TwoDThreeD(img.width, img.height, 30);

	    img = thresholdHSB(img, 90, 138, 80, 255, 17, 190); //H/B/S thresholding
	    img = findConnectedComponents(img, false);
	    img = convolute(img); //Blurring
	    img = scharr(img); //Edge Detection
	    img = threshold(img, 80); //Supression low bright pixels
	    lines = hough(img, 4); //Hough transform

	    corners = qGraph.findBestQuad(lines, img.width, img.height, 280000, 30000, false);
     
	    if (corners.size() != 0){
        corners = qGraph.sortCorners((ArrayList<PVector>)corners);
		   	for (int j = 0; j < corners.size(); j++)
		      corners.get(j).z = 1.;

		    PVector rotations = twoDThreeD.get3DRotations(corners);
        
	    	rotations.x = normalDegrees(rotations.x);
			  rotations.y = normalDegrees(rotations.y);
	    	rotations.z = normalDegrees(rotations.z);

		    return rotations;
		}

		return null;
	}



	float normalDegrees(double n){
	  if (n > Math.PI/2)
	    return (float) (n - Math.PI);
	  else if (n < -Math.PI/2) 
	    return (float) (n + Math.PI);
	  else 
	    return (float) n;
	}
  /*
  ArrayList<PVector> clockWhiseSort(ArrayList<PVector> corners){
    
    
    PVector corner1 = corners.get(0);
    PVector corner2 = corners.get(2);
    PVector midCorner = new PVector( (corner1.x+corner2.x)/2.0, (corner1.y+corner2.y)/2.0 );
    Collections.sort(corners, new CWComparator(midCorner));
    
    PVector origin =new PVector(0, 0);
    float distance = 1000;
    for (PVector corner :corners){
      distance = (corner.dist(origin)< distance)? corner.dist(origin):distance;
    }
    while(corners.get(0).dist(origin) != distance){
      Collections.rotate(corners,1);
    }
    return corners;
    
  }*/

	List<PVector> hough(PImage edgeImg, int nLines) {

	  float discretizationStepsPhi = 0.06f; 
	  float discretizationStepsR = 2.5f; 
	  int minVotes = 20;

	  // dimensions of the accumulator
	  int phiDim = (int) (Math.PI / discretizationStepsPhi +1);
	  //The max radius is the image diagonal, but it can be also negative
	  int rDim = (int) ((sqrt(edgeImg.width*edgeImg.width +
	    edgeImg.height*edgeImg.height) * 2) / discretizationStepsR +1);
	  
	  // our accumulator
	  int[] accumulator = new int[phiDim * rDim];
	  
	  // Fill the accumulator: on edge points (ie, white pixels of the edge
	  // image), store all possible (r, phi) pairs describing lines going
	  // through the point.
	  for (int y = 0; y < edgeImg.height; y++) {
	    for (int x = 0; x < edgeImg.width; x++) {
	      // Are we on an edge?
	      if (brightness(edgeImg.pixels[y * edgeImg.width + x]) != 0) {
	        // ...determine here all the lines (r, phi) passing through
	        // pixel (x,y), convert (r,phi) to coordinates in the
	        // accumulator, and increment accordingly the accumulator.
	        // Be careful: r may be negative, so you may want to center onto
	        // the accumulator: r += rDim / 2
	        for(int i = 0; i < phiDim; i++){
	          double r = (x * Math.cos(i*discretizationStepsPhi) + y * Math.sin(i*discretizationStepsPhi))/discretizationStepsR; 
	          r = r + rDim/2;
	          accumulator[(int) (r + rDim * i)] ++;
	        }

	      }
	    }
	  }

	   bestCandidates = new ArrayList<Integer>();

	  ArrayList<PVector> lines = new ArrayList<PVector>();
	  int size = 10;

	  for (int idx = 0; idx < accumulator.length; idx++) {
	    if (accumulator[idx] > minVotes){
	      boolean candidate = true;

	      neighbour: {
	        for (int i = - size; i <= size; i++) {
	          for (int j = -size; j <= size; j++) {
	            int idx2 = idx + i + j*rDim;
	            if(idx2 < 0 || idx2 > accumulator.length)
	              continue;

	            if (accumulator[idx]<accumulator[idx2]){
	              candidate = false;
	              break neighbour;
	            }
	          }
	        }
	      }
	      if(candidate)
	        bestCandidates.add(idx);
	    }
	  }

	  Collections.sort(bestCandidates, new HoughComparator(accumulator));

	  if (nLines > bestCandidates.size())
	    nLines = bestCandidates.size();

	  for (int i = 0; i < nLines; i++) {
	    int idx = bestCandidates.get(i);
	    // first, compute back the (r, phi) polar coordinates:
	    int accPhi = (int) (idx / (rDim));
	    int accR = idx - (accPhi) * (rDim);
	    float r = (accR - (rDim) * 0.5f) * discretizationStepsR;
	    float phi = accPhi * discretizationStepsPhi;
	    lines.add(new PVector(r,phi));
	  }

	  return lines;
	}

	void drawLines(PImage edgeImg, List<PVector> lines){
	    // image(edgeImg, 0, 0);//show image
	  for (PVector line: lines) {
	    float r = line.x;
	    float phi = line.y;
	    // Cartesian equation of a line: y = ax + b
	    // in polar, y = (-cos(phi)/sin(phi))x + (r/sin(phi))
	    // => y = 0 : x = r / cos(phi)
	    // => x = 0 : y = r / sin(phi)
	    // compute the intersection of this line with the 4 borders of
	    // the image
	    int x0 = 0;
	    int y0 = (int) (r / sin(phi));
	    int x1 = (int) (r / cos(phi));
	    int y1 = 0;
	    int x2 = edgeImg.width;
	    int y2 = (int) (-cos(phi) / sin(phi) * x2 + r / sin(phi));
	    int y3 = edgeImg.width;
	    int x3 = (int) (-(y3 - r / sin(phi)) * (sin(phi) / cos(phi)));
	    // Finally, plot the lines
	    stroke(204,102,0);
	    if (y0 > 0) {
	      if (x1 > 0)
	        line(x0, y0, x1, y1);
	      else if (y2 > 0)
	        line(x0, y0, x2, y2);
	      else
	        line(x0, y0, x3, y3);
	    }
	    else {
	      if (x1 > 0) {
	        if (y2 > 0)
	          line(x1, y1, x2, y2);
	        else
	          line(x1, y1, x3, y3);
	      }
	      else
	        line(x2, y2, x3, y3);
	    }
	  }
	}

	PImage threshold(PImage img, int thresholdBarBrighness){ 
	//Only take the pixels that are above/below a certain level of brightness
	  // create a new, initially transparent, 'result' image
	  PImage result = createImage(img.width, img.height, RGB);

	  for(int i = 0; i < img.width * img.height; i++) {
	    //Go through the pixels[], pixel by pixel, those that are above/below 
	      //the threshold will remain, the others will now be null
	    if (brightness(img.pixels[i]) >= thresholdBarBrighness)
	    //if (brightness(img.pixels[i]) >= threshold) //Above threshold
	      result.pixels[i] = img.pixels[i];
	    else
	      result.pixels[i] = color(0);
	  }

	  return result;
	}

	PImage thresholdHSB(PImage img, int minH, int maxH, int minS, int maxS, int minB, int maxB){
	  // create a new, initially transparent, 'result' image
	  PImage result = createImage(img.width, img.height, RGB); 

	  for(int i = 0; i < img.width * img.height; i++) {
	    float h = hue(img.pixels[i]);
	    float s = saturation(img.pixels[i]);
	    float b = brightness(img.pixels[i]);

	    result.pixels[i] = ((h >= minH && h <= maxH && s >= minS && s <= maxS && b >= minB && b <= maxB) ? color(255) : color(0));
	  }

	  return result;
	}

	PImage convolute(PImage img) {
	  //Gaussian blur
	  float[][] kernel = { { 9, 12, 9 },
	                        { 12, 15, 12 },
	                        { 9, 12, 9 }};
	  float normFactor = 99.f;

	  // create a greyscale image (type: ALPHA) for output
	  PImage result = createImage(img.width, img.height, ALPHA);

	  int kernelSize = kernel.length;// kernel size N = 3

	  for(int i = 1; i < img.height - 1; i++) { // for each (x,y) pixel in the image:
	    for(int j = 1; j < img.width - 1; j++) { // we start in 1 & finish in -1 to avoid borders
	      int r = 0; 
	      //HardCoded the size of the kernel
	      for (int u = -1; u <= 1; u++) { //To go through the kernelArray
	        for (int w = -1; w <= 1; w++) {
	          int x = j + u;
	          int y = i + w;
	          r += kernel[u+1][w+1] * brightness(img.pixels[x + y*img.width]); 
	        }
	      }
	      // - sum all these intensities and divide it by normFactor
	      result.pixels[j + i * img.width] = color(r / normFactor); // - set result.pixels[y * img.width + x] to this value
	    }
	  }

	  return result;
	}


	PImage scharr(PImage img) {
	  float[][] vKernel = {
	  { 3, 0, -3 },
	  { 10, 0, -10 },
	  { 3, 0, -3 } };

	  float[][] hKernel = {
	  { 3, 10, 3 },
	  { 0, 0, 0 },
	  { -3, -10, -3 } };

	  PImage result = createImage(img.width, img.height, ALPHA);
	  // clear the image
	  for (int i = 0; i < img.width * img.height; i++) {
	    result.pixels[i] = color(0);
	  }

	  float max=0;
	  float normFactor = 1.0;
	  float[] buffer = new float[img.width * img.height];

	  for(int i = 1; i < img.height - 1; i++) { // for each (x,y) pixel in the image:
	    for(int j = 1; j < img.width - 1; j++) { // we start in 1 & finish in -1 to avoid borders
	      int sum_h = 0; 
	      int sum_v = 0; 

	      //HardCoded the size of the kernel
	      for (int u = -1; u <= 1; u++) { //To go through the kernelArray
	        for (int w = -1; w <= 1; w++) {
	          int x = j + u;
	          int y = i + w;
	          sum_h += hKernel[u+1][w+1] * brightness(img.pixels[x + y*img.width]);
	          sum_v += vKernel[u+1][w+1] * brightness(img.pixels[x + y*img.width]); 
	        }
	      }

	      // - sum all these intensities and divide it by normFactor
	      float sum = sqrt(pow(sum_h, 2) + pow(sum_v, 2));
	      buffer[j + i * img.width] = sum;
	      max = max(max, sum);
	    }
	  }

	  for (int y = 2; y < img.height - 2; y++) { // Skip top and bottom edges
	    for (int x = 2; x < img.width - 2; x++) { // Skip left and right
	      int val=(int) ((buffer[y * img.width + x] / max)*255);
	      result.pixels[y * img.width + x]=color(val);
	    }
	  }
	  return result;
	}

	PImage findConnectedComponents(PImage input, boolean onlyBiggest){
	    // First pass: label the pixels and store labels' equivalences
	    
	    int [] labels = new int [input.width*input.height];
	    List<TreeSet<Integer>> labelsEquivalences= new ArrayList<TreeSet<Integer>>();
	        
	    int currentLabel = 1;
	    labelsEquivalences.add(new TreeSet<Integer>());
	    labelsEquivalences.get(0).add(1);
	    
	    input.loadPixels();
	    int n1 = 0;
	    int n2 = 0;
	    int n3 = 0;
	    int n4 = 0;
	    
	    for(int j = 0 ; j < input.height ; j++) {
	      for(int i = 0 ; i < input.width ; i++) {

	        n1 = 0;
	        n2 = 0;
	        n3 = 0;
	        n4 = 0;

	        // white is value -1
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
	           labelsEquivalences.get(currentLabel-1).add(currentLabel);
	          } else {
	            //keeping the ones that aren't 0
	              int n12 = 0;
	              int n34 = 0;
	              int n1234 = 0;
	             ;
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
	    
	    //System.out.println();
	    //for (int j = 0; j < 3; j++){
	    for(int i = 0; i < labels.length ; i++) {
	      if(input.pixels[i] >= -1) {
	        int prev = labels[i];
	        int next = 0;
	        boolean check = false;
	        
	        while(!check){
	          next = labelsEquivalences.get(prev-1).first();
	          if (next != prev) {
	            prev = next;
	          } else {check = true;}
	        } // iterating through equivalences
	        
	        labels[i] = next;
	        
	        
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
	      for (int n = 0; n < countArray.length; n++) { //finding the largest blob
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
	            output.pixels[i + j*output.width] = color(255, 255, 255); //if pixel is from biggest blob, colour in white, otherwise black
	          } else { output.pixels[i + j*output.width] = color(0, 0, 0); }
	          
	        }
	      }
	    }
	    
	    return output;
	  }

	class HoughComparator implements java.util.Comparator<Integer> { 
	  int[] accumulator; 
	  public HoughComparator(int[] accumulator) { 
	    this.accumulator = accumulator; 
	  } 

	  @Override public int compare(Integer l1, Integer l2) { 
	    if (accumulator[l1] > accumulator[l2] || (accumulator[l1] == accumulator[l2] && l1 < l2)) 
	      return -1; 
	    return 1; 
	  } 
	}

}
