PImage img, img2, img3;
HScrollbar thresholdBarBrighness, thresholdBarHue;

void settings() {
  size(1600, 1200);
}

void setup() {
  img = loadImage("board1.jpg");
  img2 = loadImage("board1Scharr.bmp");
  img3 = loadImage("board1Blurred.bmp");
    img4 = loadImage("board1Thresholded.bmp");

  thresholdBarBrighness = new HScrollbar(0, 580, 800, 20); //Upper one
  thresholdBarHue = new HScrollbar(0, 560, 800, 20);

  //noLoop(); // no interactive behaviour: draw() will be called only once.
}


void draw() {
    image(img, 0, 0);//show image

    /*PImage img2 = img.copy();//make a deep copy
      img2.loadPixels();// load pixels
      for (int x = 0; x < img2.width; x++)
        for (int y = 0; y < img2.height; y++)
          if (y%2==0)
            img2.pixels[y*img2.width+x] = color(0, 255, 0);
      img2.updatePixels();//update pixels
      image(img2, img.width, 0);*/

/*  //For the SCROLLBAR
  thresholdBarBrighness.display();
  thresholdBarBrighness.update();  
  thresholdBarHue.display();
  thresholdBarHue.update();*/

  //PImage result = threshold(img, 255, thresholdBarBrighness.getPos(), 255, thresholdBarHue.getPos());
  
  //PImage result = thresholdHSB(img, 100, 200, 100, 255, 45, 100);

  PImage result = thresholdHSB(img, 100, 200, 100, 255, 45, 100);
  image(result, img.width, 0);

  result = convolute(result);
  result = scharr(result);
  image(result, 0, img.height);
  
  result = threshold(result, 50);
  image(result, img.width, img.height);

  //image(scharr(img), img.width, img.height);
  //print(imagesEqual(img3, convolute(img)));
  print(imagesEqual(img4, thresholdHSB(img, 100, 200, 100, 255, 45, 100)));

}


PImage threshold(PImage img, int thresholdBarBrighness){ 
//Only take the pixels that are above/below a certain level of brightness
  // create a new, initially transparent, 'result' image
  PImage result = createImage(img.width, img.height, RGB);

  for(int i = 0; i < img.width * img.height; i++) {
    //Go through the pixels[], pixel by pixel, those that are above/below 
      //the threshold will remain, the others will now be null
    if (brightness(img.pixels[i]) <= thresholdBarBrighness)
    //if (brightness(img.pixels[i]) >= threshold) //Above threshold
      result.pixels[i] = img.pixels[i];
  }

  return result;
}

PImage threshold(PImage img, double thresholdBarBrighness, double scrollFactorBrightness,
         double thresholdBarHue, double scrollFactorHue){ 
//Only take the pixels that are above/below a certain level of brightness
  // create a new, initially transparent, 'result' image
  PImage result = createImage(img.width, img.height, RGB);

  int newThresholdBrightness = (int) (thresholdBarBrighness*scrollFactorBrightness);
  int newThresholdHue = (int) (thresholdBarHue*scrollFactorHue);

  for(int i = 0; i < img.width * img.height; i++) {
    //Go through the pixels[], pixel by pixel, those that are above/below 
      //the threshold will remain, the others will now be null
    if (brightness(img.pixels[i]) <= newThresholdBrightness && hue(img.pixels[i]) <= newThresholdHue)
    //if (brightness(img.pixels[i]) >= threshold) //Above threshold
      result.pixels[i] = img.pixels[i];
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
/*  float[][] kernel = { { 0, 0, 0 },
                        { 0, 2, 0 },
                        { 0, 0, 0 }};
  float[][] kernel = { { 0, 1, 0 },
                        { 1, 0, 1 },
                        { 0, 1, 0 }};*/
  //Gaussian blur
  float[][] kernel = { { 9, 12, 9 },
                        { 12, 15, 12 },
                        { 9, 12, 9 }};
  float normFactor = 99.f;

//  float normFactor = 1.f;

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
          //if( x >= 0 && y >= 0 && x < img.width && y < img.height)
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
          //if( x >= 0 && y >= 0 && x < img.width && y < img.height)
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


// Auxiliar functions //
boolean imagesEqual(PImage img1, PImage img2){
  if(img1.width != img2.width || img1.height != img2.height)
    return false;
  for(int i = 0; i < img1.width*img1.height ; i++)
  //assuming that all the three channels have the same value
  if(red(img1.pixels[i]) != red(img2.pixels[i]))
    return false;
  return true;
}