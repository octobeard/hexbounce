int         myStageW         = 1920;
int         myStageH         = 1080;

color       clrBG            = #333333;

String      pathDATA         = "../../../data/";

// *************************************************************************************************************

import ddf.minim.*;
import ddf.minim.analysis.*;

Minim       minim;
AudioInput  myAudio;
FFT         myAudioFFT;

boolean     showVisualizer   = true;

int         myAudioRange     = 11;
int         myAudioMax       = 100;

float       myAudioAmp       = 40.0;
float       myAudioIndex     = 0.2;
float       myAudioIndexAmp  = myAudioIndex;
float       myAudioIndexStep = 0.35;

float[]     myAudioData      = new float[myAudioRange];

// *************************************************************************************************************

void settings() {
	size(myStageW, myStageH);
	//fullscreen();
}

void setup() {
	background(clrBG);
	setupAudio();

	
}

void draw() {
	background(clrBG);

	myAudioFFT.forward(myAudio.mix);
	myAudioDataUpdate();

	// CALL TO WIDGET SHOULD ALWAYS BE LAST ITEM IN DRAW() SO IT ALWAYS APPEARS ABOVE ANY OTHER VISUAL ASSETS
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


