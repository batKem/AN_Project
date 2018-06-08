import java.util.*;

PImage img;
ArrayList<Integer> bestCandidates;

void settings() {
  size(1600, 1200);
}

void setup() {
	img = loadImage("hough_test.bmp");
}

void draw(){
	List<PVector> lines = hough(img, 7);
	drawLines(img, lines);

}

List<PVector> hough(PImage edgeImg, int nLines) {

	float discretizationStepsPhi = 0.06f; 
	float discretizationStepsR = 2.5f; 
	int minVotes = 50;

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
/*
	 ArrayList<Integer> nonBestCandidates = new  ArrayList<Integer>();

	for (Integer idx : bestCandidates) {
		for (int i = - size; i <= size; i++) {
			for (int j = -size; j <= size; j++) {
				int idx2 = idx + i + j*rDim;
				if (bestCandidates.contains(idx2)){
					if (accumulator[idx]<accumulator[idx2])
						nonBestCandidates.add(idx);
				}
			}
		}
	}

	bestCandidates.remove(nonBestCandidates);
*/
	Collections.sort(bestCandidates, new HoughComparator(accumulator));

	for (int i = 0; i < nLines; i++) {
		int idx = bestCandidates.get(i);
		System.out.println(idx);
		// first, compute back the (r, phi) polar coordinates:
		int accPhi = (int) (idx / (rDim));
		int accR = idx - (accPhi) * (rDim);
		float r = (accR - (rDim) * 0.5f) * discretizationStepsR;
		float phi = accPhi * discretizationStepsPhi;
		lines.add(new PVector(r,phi));
	}

		//**** Testing
		PImage houghImg = createImage(rDim, phiDim, ALPHA);

		for (int i = 0; i < accumulator.length; i++) { 
			houghImg.pixels[i] = color(min(255, accumulator[i])); 
		}

		// You may want to resize the accumulator to make it easier to see: 
		houghImg.resize(400, 400);
		
		houghImg.updatePixels();
		image(houghImg, 0, 0);//show image

	return lines;
}

void drawLines(PImage edgeImg, List<PVector> lines){
		image(edgeImg, 0, 0);//show image
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
	// edgeImg.updatePixels();

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
