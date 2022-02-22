int         myStageW         = 1280;
int         myStageH         = 720;

color       clrBG            = #101010;

String      pathDATA         = "../../../data/";

// *************************************************************************************************************

import ddf.minim.*;
import ddf.minim.analysis.*;

Minim       minim;
AudioInput  myAudio;
FFT         myAudioFFT;

boolean     showVisualizer   = false;

int         myAudioRange     = 11;
int         myAudioMax       = 100;

float       myAudioAmp       = 45.0;
float       myAudioIndex     = 0.25;
float       myAudioIndexAmp  = myAudioIndex;
float       myAudioIndexStep = 0.4;

float[]     myAudioData      = new float[myAudioRange];

// *************************************************************************************************************

import hype.*;
import hype.extended.layout.*;
import hype.extended.colorist.*;
import hype.extended.behavior.*;

HCanvas 		canvas, canvas2;
HDrawablePool 	pool1, pool2;
int 			poolCount	 = 140;
HColorPool 		colorPool, blueColorPool;
boolean 		swapXY 		 = false;



void settings() {
	size(myStageW, myStageH);
	//fullScreen();
}

void setup() {
	H.init(this).background(clrBG).autoClear(true);
	canvas = new HCanvas(myStageW, myStageH).autoClear(false).fade(3);
	canvas2 = new HCanvas(myStageW, myStageH).autoClear(true);
	H.add(canvas2);
	H.add(canvas);

	smooth();
	setupAudio();
    colorPool = new HColorPool(#EC02EC,#A1029F,#53044C,#830270,#EA00A0,#B5014F,#F862A3,#F10063,#822A4B,#B3032B,#FB0401,#D32C02,#AF2C01,#862802,#0208BC,#0526E6,#070B49,#320479,#3301BC,#0054F1,#0384FF,#5E14E6,#580A89,#A30EE8,#5F54ED,#382674,#9E5AF5,#E757F0,#A949AD,#9E99FC).repeatColors(false);    
    blueColorPool = new HColorPool(#0208BC,#0526E6,#002CB8,#3301BC,#0054F1,#0384FF,#5F54ED).repeatColors(false);

	pool2 = new HDrawablePool(135);
	pool2.autoParent(canvas2)
		 .add(new HShape(pathDATA + "hexagon.svg"))
		 .layout(new HGridLayout()
			.startX((int) myStageW/20)
			.startY(0)
			.spacing((int) myStageW/10,(int) myStageW/10)
			.cols(10)
		 )
		 .onCreate(new HCallback() {
				public void run(Object obj) {
					HShape d = (HShape) obj;
					d
						.enableStyle(false)
						.stroke(#000000)
						.anchorAt(H.CENTER)
						.rotate( 90 * (int) random(3) )
						.size( (int) myStageW / 10) // 
						.alpha(50)
						.num("band", (float) ((int)random(myAudioRange)))

					;
					new HRotate(d, (int) random(-2, 2) + 1);
					d.randomColors(colorPool.fillOnly());

				}
			}
		)
		.requestAll()
	;
	pool1 = new HDrawablePool(poolCount);
	pool1.autoParent(canvas).add(new HShape(pathDATA + "hexagon.svg"))
		 .layout(new HGridLayout()
			.startX(10)
			.startY(40)
			.spacing(myStageW/15,myStageW/15)
			.cols(15)
		 )
		 .onCreate(new HCallback() {
				public void run(Object obj) {
					HShape d = (HShape) obj;
					int initSizeOffset = (int) random(myAudioRange*6) + 40;
					d
						.enableStyle(false)
						.stroke(#000000)
						.anchorAt(H.CENTER)
						.rotate( (int)random(4) * 90 )
						.size( initSizeOffset )
						.alpha(150)
						.num("initSize", (float) initSizeOffset)
						.num("band", (float) ((int)random(myAudioRange)))
						.num("rand", random(-50, 50))

					;
					d.randomColors(blueColorPool.fillOnly());

				}
			}
		)
		.requestAll()
	;

	for (HDrawable d : pool1) {
		d.num("initY", d.y());
		d.num("initX", d.x());
	}

	new HTimer()
		.interval(1000)
		.callback(
			new HCallback() { 
				public void run(Object obj) {
					swapXY = !swapXY;
				}
			}
		)
	;

}

void draw() {
	myAudioFFT.forward(myAudio.mix);
	myAudioDataUpdate();
	H.drawStage();
	int canvasAlphafft = (int) map(myAudioData[0], 0, myAudioMax/2, 10, 255);
	canvas.alpha(canvasAlphafft);

	for (HDrawable d : pool1) {
		int band = (int) d.num("band");
		int initSize = (int) d.num("initSize");
		int rand = (int) d.num("rand");
		int sizefft = (int) map(myAudioData[band], 0, myAudioMax, initSize, initSize+200);
		int sizefftSmall = (int) map(myAudioData[band], 0, myAudioMax, initSize, initSize+50);
		int alphafft = (int) map(myAudioData[7], 0, myAudioMax/4, 100, 255);
		int rotatefft = (int) map(myAudioData[band], 0, myAudioMax, -40, 40);
		int yfft = (int) map(myAudioData[band], 0, myAudioMax, -100 + rand, 100 + rand);
		int xfft = (int) map(myAudioData[band], 0, myAudioMax, -100 + rand, 100 + rand);
		if (band == 0) {
			//d.rotate(rotatefft);
			d.alpha(alphafft);
			if (swapXY == true) {
				d.y(d.num("initY") + yfft);
			} else {
				d.x(d.num("initX") + xfft);
				((HShape) d).randomColors(blueColorPool.fillOnly());
			}
			
		}
		else if (band == 2) {
			d.alpha(alphafft);
			if (swapXY == true) {
				d.x(d.num("initX") + xfft);	
				((HShape) d).randomColors(blueColorPool.fillOnly());
			} else {
				d.y(d.num("initY") + yfft);
			}
			
		} else if (band >= 3 && band < 5) {
			d.size(sizefft);
		} else {
			d.alpha(alphafft);
			d.size(sizefftSmall);
			if (myAudioData[0] <= 5) {
				if (swapXY == true) {
					d.x(d.num("initX") + xfft);	
					((HShape) d).randomColors(blueColorPool.fillOnly());
				} else {
					d.y(d.num("initY") + yfft);
				}				
			}
		}		
	}
	
	if (showVisualizer) myAudioDataWidget();
}






// Audio Streaming/Player functions

void setupAudio() {
	minim   = new Minim(this);
	myAudio = minim.getLineIn(Minim.MONO);
	myAudioFFT = new FFT(myAudio.bufferSize(), myAudio.sampleRate());
	myAudioFFT.linAverages(myAudioRange);
	myAudioFFT.window(FFT.GAUSS);
}

void myAudioDataUpdate() {
	for (int i = 0; i < myAudioRange; ++i) {
		float tempIndexAvg = (myAudioFFT.getAvg(i) * myAudioAmp) * myAudioIndexAmp;
		float tempIndexCon = constrain(tempIndexAvg, 0, myAudioMax);
		myAudioData[i]     = tempIndexCon;
		myAudioIndexAmp+=myAudioIndexStep;
	}
	myAudioIndexAmp = myAudioIndex;
}

void myAudioDataWidget() {
	// noLights();
	// hint(DISABLE_DEPTH_TEST);
	noStroke(); fill(0,200); rect(0, height-112, width, 102);

	for (int i = 0; i < myAudioRange; ++i) {
		if     (i==0) fill(#237D26); // base  / subitem 0
		else if(i==3) fill(#80C41C); // snare / subitem 3
		else          fill(#CCCCCC); // others

		rect(20 + (i*15), (height-myAudioData[i])-11, 14, myAudioData[i]);
	}
	// hint(ENABLE_DEPTH_TEST);
}

void stop() {
	myAudio.close();
	minim.stop();  
	super.stop();
}


