HScrollbar thresholdBar;

void settings() {
	size(800, 600);
}
void setup() {
	thresholdBar = new HScrollbar(0, 580, 800, 20);
	//...
	//noLoop(); you must comment out noLoop()!
}
void draw() {
	//...
	thresholdBar.display();
	thresholdBar.update();
	println(thresholdBar.getPos()); // getPos() returns a value between 0 and 1
}