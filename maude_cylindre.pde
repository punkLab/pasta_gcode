import processing.pdf.*;

PrintWriter file;
PImage img;

float xOut = 114; //inch
float yOut = 118; //mm
float mecheSize = 0.5;
float mecheDepth = 0.5;

float radius;
float speed = 1000;

boolean lineActive = true;


void setup() {
	size(1920,1080, PDF, "pdf_test.pdf");
	//background(255);
	file = createWriter("cDec.nc");
	img = loadImage("chato.png");

}

void draw() {
	//toGcode(img);
	toPDF(img);
	//la for loop pour x axis
	// for (float i = 0; i < totalWidth; i += mecheSize) {
	// 	g("G01A360.0");
	// 	file.println("G01X"+mecheSize);
	// }
	file.flush();
	file.close();
	exit();
}

void g(String _s) {
	file.println(_s);
}

void toGcode(PImage _img) {
	g("%");
	g("90"); //absolu
	//g("G91"); //incrementiel
	g("G21"); //millimetre
	//g("G20"); //inch
	g("M03"); //spindle
	file.println("F"+speed);
	float stepSize = 0.33;
	println("Img width = "+img.width+" / StepSize ="+stepSize);
	//decoder chaque pixel par row
	float lastLuma = -2;
	for (int j = 0; j < img.height; j += 3) {
		for (int i = 0; i < img.width; i++) {
			float luma = map(brightness(img.get(i, j)), 0, 255, 0, mecheDepth);
			if (lastLuma != luma) {

				//g("( Brightness = "+brightness(img.get(i, j))+")");
				g("G01X"+map(i,0,img.width,0,xOut)+"Z"+-lastLuma);
				g("G01X"+map(i,0,img.width,0,xOut)+"Z"+-luma);
				lastLuma = luma;
			}
			if (i == img.width-1 || i == 0) {
				g("G01X"+map(i,0,img.width,0,xOut)+"Z"+-luma);
			}
		}
		g("G00Z"+0.5);
		g("G00X"+0.0+"A"+map(j+1, 0,img.height, 0, 360));
		g("G01Z"+0.0);
		g("(NEW LINE!)");	
	}

	//mapper 

}

void toPDF(PImage _img) {
	PVector sLine = new PVector();
	PVector eLine = new PVector();

	float lLimit = 127;

	println("Img width = "+img.width);
	//decoder chaque pixel par row
	float lastLuma = 0;
	for (int j = 0; j < img.height; j += 2) {
		for (int i = 0; i < img.width; i++) {
			//get color/////////////////////////////////////
			color cValue = color(img.get(i, j));
			float _blue = green(cValue);
			//get luma/////////////////////////////////////
			float luma = brightness(img.get(i, j));
			//logic////////////////////////////////////////
			float _pixel = _blue;
			if (_pixel > lLimit && !lineActive) {
				lineActive = true;
				sLine.set(i, j);
				sLine.add(random(-2,2), random(-2,2));
			} 

			if (_pixel < lLimit && lineActive) {
				eLine.set(i, j);
				eLine.add(random(-2,2), random(-2,2));
				line(sLine.x, sLine.y, eLine.x, eLine.y);
				lineActive = false;
			}

			if (sLine.x - i < -random(30,50) && lineActive) {
				eLine.set(i, j);
				eLine.add(random(-2,2), random(-2,2));
				line(sLine.x, sLine.y, eLine.x, eLine.y);
				lineActive = false;
				
			}
			if (i == img.width-1 || i == 0) {
				lineActive = false;
			}
		}	
	}

	//mapper 

}