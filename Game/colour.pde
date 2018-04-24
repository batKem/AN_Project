PImage img;
HScrollbar thresholdBarBrighness, thresholdBarHue;

void settings() {
  size(1600, 600);
}

void setup() {
  img = loadImage("board1.jpg");
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

	//For the SCROLLBAR
	thresholdBarBrighness.display();
	thresholdBarBrighness.update();	
	thresholdBarHue.display();
	thresholdBarHue.update();

	PImage result = threshold(img, 255, thresholdBarBrighness.getPos(), 255, thresholdBarHue.getPos());
	image(result, img.width, 0);
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
  	if (brightness(img.pixels[i]) <= newThresholdHue && hue(img.pixels[i]) <= newThresholdHue)
  	//if (brightness(img.pixels[i]) >= threshold) //Above threshold
  		result.pixels[i] = img.pixels[i];
  }

  return result;
}