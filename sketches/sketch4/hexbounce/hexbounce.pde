// int         myStageW         = 1280;
// int         myStageH         = 720;
int         myStageW         = 1920;
int         myStageH         = 1080;
color       clrBG            = #101010;

String      pathDATA         = "../../../data/";
String      pathRENDER       = "../../../render/";


// *************************************************************************************************************

import ddf.minim.*;
import ddf.minim.analysis.*;

boolean 	recordOutput	 = false;
int 		renderFrameRate	 = 30;
String 		renderFileName   = "bg4lucy";
int 		outputLength	 = 10; // seconds

boolean 	streamAudio		 = true;
String 		audioFile		 = "mech-breakdown.aif";

Minim       minim;
AudioInput  audioInput;
AudioPlayer audioPlayer;

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

int 			pool1Cols 	 = 10;
int 			pool1Rows 	 = (int) (pool1Cols * (float) myStageH/ (float) myStageW) + 1;
int 			pool2Cols 	 = 15;
int 			pool2Rows 	 = (int) (pool2Cols * (float) myStageH/ (float) myStageW) + 1;

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
	frameRate(renderFrameRate);
	H.init(this).background(clrBG).autoClear(true);
	
	colorPool = new HColorPool(#EC02EC,#A1029F,#53044C,#830270,#EA00A0,#B5014F,#F862A3,#F10063,#822A4B,#B3032B,#FB0401,#D32C02,#AF2C01,#862802,#0208BC,#0526E6,#070B49,#320479,#3301BC,#0054F1,#0384FF,#5E14E6,#580A89,#A30EE8,#5F54ED,#382674,#9E5AF5,#E757F0,#A949AD,#9E99FC).repeatColors(false);    
	blueColorPool = new HColorPool(#0208BC,#0526E6,#002CB8,#3301BC,#0054F1,#0384FF,#5F54ED).repeatColors(false);

	canvas = new HCanvas(myStageW, myStageH).autoClear(false).fade(2);
	canvas2 = new HCanvas(myStageW, myStageH).autoClear(false).fade(3);

	H.add(canvas);
	H.add(canvas2);

	smooth();
	setupAudio();

	pool1 = new HDrawablePool(pool1Cols * pool1Rows);
	pool1.autoParent(canvas)
		 .add(new HShape(pathDATA + "cyrcle1.svg"))
		 .add(new HShape(pathDATA + "cyrcle2.svg"))
		 .add(new HShape(pathDATA + "cyrcle3.svg"))
		 .add(new HShape(pathDATA + "cyrcle4.svg"))
		 .add(new HShape(pathDATA + "cyrcle5.svg"))
		 .add(new HShape(pathDATA + "cyrcle6.svg"))
		 .add(new HShape(pathDATA + "cyrcle7.svg"))
		 .layout(new HGridLayout()
			.startX((int) myStageW/(pool1Cols*2))
			.startY((int) myStageW/(pool1Cols*4))
			.spacing((int) myStageW/pool1Cols,(int) myStageW/pool1Cols)
			.cols(pool1Cols)
		 )
		 .onCreate(new HCallback() {
				public void run(Object obj) {
					int initSize = (int) myStageW / pool1Cols + (int) random(10, 200);
					HShape d = (HShape) obj;
					d
						.enableStyle(false)
						//.stroke(#000000)
						.noStroke()
						.anchorAt(H.CENTER)
						.rotate( 90 * (int) random(3) )
						.size( initSize ) // 
						.alpha(150)
						.num("band", (float) ((int)random(myAudioRange)))

					;
					int rotateValue = (int) random(-3, 2);
					if (rotateValue == 0 ) rotateValue = 1;
					new HRotate(d, rotateValue);
					d.randomColors(colorPool.fillOnly());

					new HOscillator()
						.target(d)
						.property(H.SIZE)
						.relativeVal( initSize )
						.range(-100, 250)
						.speed(random(2))
						.freq(2)
						.currentStep( pool1.currentIndex() )
					;

				}
			}
		)
		.requestAll()
	;
	pool2 = new HDrawablePool(pool2Cols * pool2Rows);
	pool2.autoParent(canvas2)
		 .add(new HShape(pathDATA + "cyrcle1.svg"))
		 .add(new HShape(pathDATA + "cyrcle2.svg"))
		 .add(new HShape(pathDATA + "cyrcle3.svg"))
		 .add(new HShape(pathDATA + "cyrcle4.svg"))
		 .add(new HShape(pathDATA + "cyrcle5.svg"))
		 .add(new HShape(pathDATA + "cyrcle6.svg"))
		 .add(new HShape(pathDATA + "cyrcle7.svg"))

		 .layout(new HGridLayout()
			.startX(myStageW/pool2Cols/2)
			.startY(myStageW/pool2Cols/2)
			.spacing(myStageW/pool2Cols,myStageW/pool2Cols)
			.cols(pool2Cols)
		 )
		 .onCreate(new HCallback() {
				public void run(Object obj) {
					HShape d = (HShape) obj;
					int initSizeOffset = (int) random(myAudioRange*6) + 200;
					d
						.enableStyle(false)
						//.stroke(#000000)
						.noStroke()
						.anchorAt(H.CENTER)
						.rotate( (int)random(4) * 90 )
						.size( initSizeOffset )
						.alpha(150)
						.num("initSize", (float) initSizeOffset)
						.num("band", (float) ((int)random(myAudioRange)))
						.num("rand", random(-50, 50))

					;
					if (d.num("band") > 4) {
						new HOscillator()
							.target(d)
							.property(H.X)
							.relativeVal( d.x() )
							.range(-100, 100)
							.speed(random(3))
							.freq(2)
							.currentStep( pool2.currentIndex() )
						;
					} else {
						new HOscillator()
							.target(d)
							.property(H.Y)
							.relativeVal( d.y() )
							.range(-100, 100)
							.speed(random(2))
							.freq(2)
							.currentStep( pool2.currentIndex() )
						;
					}
					d.randomColors(blueColorPool.fillOnly());
				}
			}
		)
		.requestAll()
	;

	for (HDrawable d : pool2) {
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
	if (streamAudio == true) {
		myAudioFFT.forward(audioInput.mix);	
	} else {
		myAudioFFT.forward(audioPlayer.mix);
	}
	
	myAudioDataUpdate();
	H.drawStage();
	int canvasAlphafft = (int) map(myAudioData[0], 0, myAudioMax/2, 10, 255);
	canvas2.alpha(canvasAlphafft);

	for (HDrawable d : pool2) {
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
	

	if (recordOutput) renderOutput();
	if (showVisualizer) myAudioDataWidget();
}






// Audio Streaming/Player functions

void setupAudio() {
	minim = new Minim(this);
	if (streamAudio == true) {
		audioInput = minim.getLineIn(Minim.MONO);
		myAudioFFT = new FFT(audioInput.bufferSize(), audioInput.sampleRate());

	} else {
		audioPlayer = minim.loadFile(pathDATA + audioFile);
		audioPlayer.play();
		myAudioFFT = new FFT(audioPlayer.bufferSize(), audioPlayer.sampleRate());
	}
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

void renderOutput() {
	saveFrame(pathRENDER + renderFileName + "#########.tif"); if (frameCount == (outputLength * renderFrameRate)) exit();
}
void stop() {
	if (streamAudio == true) {
		audioInput.close();
	} else {
		audioPlayer.close();
	}
	minim.stop();  
	super.stop();
}


