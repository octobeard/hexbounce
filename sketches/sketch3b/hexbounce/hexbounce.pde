int         stageW         = 1000;
int         stageH         = 1000;
// int         stageW         = 1920;
// int         stageH         = 1080;
color       bgColor        = #000000;
String      pathDATA         = "../../../data/";
String      PATH_RENDER    = "../../../render/";

// PRIMARY SETTINGS
boolean     fullscreen       = false;
boolean     recordOutput     = true;
boolean     streamAudio      = false;
boolean     showVisualizer   = false;

// AUDIO DATA
String          audioFile    = "katzenmusik.aiff";
String          audioPath    = PATH_DATA + audioFile;
AudioProcessor  audio;

// RENDERING
String      renderFileName   = "katzen-01/katzenmusik-";
int         outputLength     = 60; // seconds
int         recordTimeDelay  = 100;
int         renderFrameRate  = 30;
int         renderFrameCount = 0;

// *************************************************************************************************************

import hype.*;
import hype.extended.layout.*;
import hype.extended.colorist.*;
import hype.extended.behavior.*;

int 			pool1Cols 	 = 10;
int 			pool1Rows 	 = (int) (pool1Cols * (float) stageH/ (float) stageW) + 1;
int 			pool2Cols 	 = 15;
int 			pool2Rows 	 = (int) (pool2Cols * (float) stageH/ (float) stageW) + 1;

HCanvas 		canvas, canvas2;
HDrawablePool 	pool1, pool2;
int 			poolCount	 = 140;
HColorPool 		colorPool, blueColorPool;
boolean 		swapXY 		 = false;

void settings() {
	size(stageW, stageH);
	if (fullscreen) fullScreen();
}

void setup() {
	frameRate(renderFrameRate);
    audio = new AudioProcessor(this, streamAudio, recordOutput);
    audio.updateTransformSettings(11, 35, 0.45, 0.2, FFT.NONE);
    audio.setup(audioPath);

	H.init(this).background(bgColor).autoClear(true);

    colorPool = new HColorPool(#EC02EC,#A1029F,#53044C,#830270,#EA00A0,#B5014F,#F862A3,#F10063,#822A4B,#B3032B,#FB0401,#D32C02,#AF2C01,#862802,#0208BC,#0526E6,#070B49,#320479,#3301BC,#0054F1,#0384FF,#5E14E6,#580A89,#A30EE8,#5F54ED,#382674,#9E5AF5,#E757F0,#A949AD,#9E99FC).repeatColors(false);    
    blueColorPool = new HColorPool(#D42265,#9D30DA,#7B37C7,#C234E4,#862EAB,#9453EE,#AF53F1,#8E53D4,#5451AD,#775DCD,#AD51D5,#9D47BB,#996BE5,#8E66CF,#C96FF4,#9989EE,#AB74D6).repeatColors(false);

	canvas = new HCanvas(stageW, stageH).autoClear(false).fade(2);
	canvas2 = new HCanvas(stageW, stageH).autoClear(false).fade(2);

	H.add(canvas);
	H.add(canvas2);

	smooth();

	pool1 = new HDrawablePool(pool1Cols * pool1Rows);
	pool1.autoParent(canvas)
		 .add(new HShape(PATH_DATA + "cyrcle1.svg"))
		 .add(new HShape(PATH_DATA + "cyrcle2.svg"))
		 .add(new HShape(PATH_DATA + "cyrcle3.svg"))
		 .add(new HShape(PATH_DATA + "cyrcle4.svg"))
		 .add(new HShape(PATH_DATA + "cyrcle5.svg"))
		 .add(new HShape(PATH_DATA + "cyrcle6.svg"))
		 .add(new HShape(PATH_DATA + "cyrcle7.svg"))
		 .layout(new HGridLayout()
			.startX((int) stageW/(pool1Cols*2))
			.startY((int) stageW/(pool1Cols*4))
			.spacing((int) stageW/pool1Cols,(int) stageW/pool1Cols)
			.cols(pool1Cols)
		 )
		 .onCreate(new HCallback() {
				public void run(Object obj) {
					int initSize = (int) (stageW / pool1Cols) + (int) random(10, 200);
					HShape d = (HShape) obj;
					d
						.enableStyle(false)
						.stroke(#000000)
						.anchorAt(H.CENTER)
						.rotate( 90 * (int) random(3) )
						.size( initSize ) // 
						.alpha(150)
						.num("band", (float) ((int)random(audio.fftData().length)))

					;
					int rotateValue = (int) random(-3, 2);
					if (rotateValue == 0 ) rotateValue = 1;
					new HRotate(d, rotateValue);
					d.randomColors(colorPool.fillOnly());

					new HOscillator()
						.target(d)
						.property(H.SIZE)
						.relativeVal( initSize )
						.range(-100, 100)
						.speed(1)
						.freq(3)
						.currentStep( pool1.currentIndex()*3 )
					;

				}
			}
		)
		.requestAll()
	;
	pool2 = new HDrawablePool(pool2Cols * pool2Rows);
	pool2.autoParent(canvas2)
		 .add(new HShape(PATH_DATA + "hexagon.svg"))
		 .layout(new HGridLayout()
			.startX(stageW/pool2Cols/2)
			.startY(stageW/pool2Cols/2)
			.spacing(stageW/pool2Cols,stageW/pool2Cols)
			.cols(pool2Cols)
		 )
		 .onCreate(new HCallback() {
				public void run(Object obj) {
					HShape d = (HShape) obj;
					int initSizeOffset = (int) random(audio.fftData().length*6) + 40;
					d
						.enableStyle(false)
						.stroke(#000000)
						.anchorAt(H.CENTER)
						.rotate( (int)random(4) * 90 )
						.size( initSizeOffset )
						.alpha(150)
						.num("initSize", (float) 10)
						.num("band", (float) ((int)random(audio.fftData().length)))
						.num("rand", random(-50, 50))

					;
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
    if (recordOutput) {
        delay(recordTimeDelay);
    }  else {
        surface.setTitle( "FPS : " + int(frameRate) );
    }

    audio.process();

	H.drawStage();
	int canvasAlphafft = (int) map(audio.fftData()[0], 0, 100/2, 10, 255);
	canvas2.alpha(canvasAlphafft);

	for (HDrawable d : pool2) {
		int band = (int) d.num("band");
		int initSize = (int) d.num("initSize");
		int rand = (int) d.num("rand");
		int sizefft = (int) map(audio.fftData()[band], 0, 100, 10, initSize+200);
		int sizefftSmall = (int) map(audio.fftData()[band], 0, 100, 10, initSize+50);
		int alphafft = (int) map(audio.fftData()[7], 0, 100/4, 100, 255);
		int rotatefft = (int) map(audio.fftData()[band], 0, 100, -40, 40);
		int yfft = (int) map(audio.fftData()[band], 0, 100, -100 + rand, 100 + rand);
		int xfft = (int) map(audio.fftData()[band], 0, 100, -100 + rand, 100 + rand);
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
			if (audio.fftData()[0] <= 5) {
				if (swapXY == true) {
					d.x(d.num("initX") + xfft);	
					((HShape) d).randomColors(blueColorPool.fillOnly());
				} else {
					d.y(d.num("initY") + yfft);
				}				
			}
		}		
	}
	
	if (showVisualizer) audio.drawWidget();
	if (recordOutput) renderOutput();
}

void renderOutput() {
	++renderFrameCount;
	saveFrame(PATH_RENDER + renderFileName + "#########.tif"); if (renderFrameCount == (outputLength * renderFrameRate)) exit();
	println("Remaining frames: " + ((outputLength * renderFrameRate) - renderFrameCount));
}

void stop() {
    audio.stop();
    super.stop();
}
