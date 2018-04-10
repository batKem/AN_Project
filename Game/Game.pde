
		/*//global rotation values
			float depth = 2000;

			PVector gravityForce;
			float gravityConstant;
			PShape cylinder;
			ArrayList<PVector> cylinders;
		 	float rotationScale=1.0;

			float rx=0 ;
			float rz=0 ;

		boolean shiftMode;

		Mover ball;
		*/
gameRender render;
PGraphics gameSurface;

void settings() {
	size(500, 500, P3D);
}

void setup() {
	noStroke();	
	gameSurface = createGraphics(width, height-300, P3D);
	render = new gameRender(gameSurface);
	image(gameSurface, 100, 100);
}

void draw() {
	render.draw();
}

void run(){
}

void keyPressed(){
	render.keyPressed();
}

void keyReleased(){
	render.keyReleased();
} 

void mouseClicked(){
	render.mouseClicked();
}

void mouseWheel(MouseEvent event) {
	render.mouseWheel(event);
}

void mouseDragged(){
	render.mouseDragged();
}