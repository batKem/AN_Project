import processing.video.*;
Capture cam;
PImage img;

void settings() {
	size(640, 480);
}

void setup() {
	String[] cameras = Capture.list();
	if (cameras.length == 0) {
		println("There are no cameras available for capture.");
		exit();
	} else {
		println("Available cameras:");
		for (int i = 0; i < cameras.length; i++) {
			println(cameras[i]);
		}
		//If you're using gstreamer0.1 (Ubuntu 16.04 and earlier),
		//select your predefined resolution from the list:
		cam = new Capture(this, cameras[0]);
		//If you're using gstreamer1.0 (Ubuntu 16.10 and later),
		//select your resolution manually instead:
		//cam = new Capture(this, 640, 480, cameras[0]);
		cam.start();
	}
}

void draw() {
	if (cam.available() == true) {
		cam.read();
	}
	img = cam.get();
	image(img, 0, 0);
}