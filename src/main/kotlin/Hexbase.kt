import ddf.minim.AudioInput
import ddf.minim.AudioPlayer
import ddf.minim.Minim
import ddf.minim.analysis.FFT
import hype.H
import processing.core.PApplet

abstract class Hexbase : PApplet() {
    val stageW = 1280
    val stageH = 720
    val bgColor = 0x101010.rgb()
    val PATH_DATA = "data/"
    val PATH_RENDER = "render/"

// PRIMARY SETTINGS
    val fullscreen     	 = false
    val recordOutput	 = false
    val streamAudio		 = true
    val showVisualizer   = true
    
// *************************************************************************************************************

    val renderFileName   = "pollen/pollen-"
    val outputLength	 = 332 // seconds
    val audioFile		 = "pollen.aiff"

    val recordTimeDelay  = 100
    val renderFrameRate	 = 30
    var renderFrameCount = 0

// *************************************************************************************************************

    lateinit var minim: Minim
    lateinit var audioInput: AudioInput
    lateinit var audioPlayer: AudioPlayer

    lateinit var myAudioFFT: FFT
    
    val myAudioRange     = 11
    val myAudioMax       = 100

    val myAudioAmp       = 45.0f
    val myAudioIndex     = 0.25f
    var myAudioIndexAmp  = myAudioIndex
    val myAudioIndexStep = 0.4f
    val myAudioFFTTotal  = 0.0f
    var cueProgress		 = 0

    val myAudioData      = Array(myAudioRange) { 0f }

    override fun settings() {
        size(stageW, stageH)
        if (fullscreen) {
            fullScreen()
        }
    }

    override fun setup() {
        hint(DISABLE_TEXTURE_MIPMAPS)
        frameRate(renderFrameRate.toFloat())
        H.init(this)
        H.background(bgColor)
        H.autoClears(true)
        smooth()
        setupAudio()

        hexBaseSetup()
    }

    abstract fun hexBaseSetup()

    override fun draw() {
        if (recordOutput) {
            delay(recordTimeDelay)
        }  else {
            surface.setTitle( "FPS : $frameRate")
        }

        processAudio()
        H.drawStage()

        hexBaseDraw()

        if (showVisualizer) myAudioDataWidget()
        if (recordOutput) renderOutput()
    }

    abstract fun hexBaseDraw()

    fun setupAudio() {
        minim = Minim(this)
        if (streamAudio) {
            audioInput = minim.getLineIn(Minim.MONO)
            myAudioFFT = FFT(audioInput.bufferSize(), audioInput.sampleRate())
        } else {
            audioPlayer = minim.loadFile(PATH_DATA + audioFile)
            audioPlayer.cue(cueProgress)
            if (!recordOutput) audioPlayer.play()
            myAudioFFT = FFT(audioPlayer.bufferSize(), audioPlayer.sampleRate())
        }
        myAudioFFT.linAverages(myAudioRange)
        myAudioFFT.window(FFT.GAUSS)
    }

    fun renderOutput() {
        ++renderFrameCount
        saveFrame("$PATH_RENDER$renderFileName#########.tif")
        if (renderFrameCount == outputLength * renderFrameRate) exit()
        println("Remaining frames: " + (outputLength * renderFrameRate - renderFrameCount))
    }

    fun processAudio() {
        if (!streamAudio && recordOutput) {
            audioPlayer.play()
            delay(30)
        }
        if (streamAudio) {
            myAudioFFT.forward(audioInput.mix)
        } else {
            myAudioFFT.forward(audioPlayer.mix)
        }
        myAudioDataUpdate()

        // pause playback immediately after calculating FFT values when recording to allow
        // time for stage to render
        if (!streamAudio && recordOutput) audioPlayer.pause()

        // println(myAudioData);
        if (recordOutput) {
            // 30fps is 33.33.. ms per frame. Correct every 4 frames by adding 1ms to keep in time with audio.
            cueProgress += if (frameCount % 4 == 0) {
                33
            } else {
                34
            }
            audioPlayer.cue(cueProgress)
        }
    }

    fun myAudioDataUpdate() {
        for (i in 0 until myAudioRange) {
            val tempIndexAvg = myAudioFFT.getAvg(i) * myAudioAmp * myAudioIndexAmp
            val tempIndexCon = constrain(tempIndexAvg, 0f, myAudioMax.toFloat())
            myAudioData[i] = tempIndexCon
            myAudioIndexAmp += myAudioIndexStep
        }
        myAudioIndexAmp = myAudioIndex
    }

    fun myAudioDataWidget() {
        // noLights()
        // hint(DISABLE_DEPTH_TEST);
        noStroke()
        fill(0f,200f)
        rect(0f, height-112f, width.toFloat(), 102f);

        for (i in 0 until myAudioRange) {
            if     (i==0) fill(0x237D26.rgb()); // base  / subitem 0
            else if(i==3) fill(0x80C41C.rgb()); // snare / subitem 3
            else          fill(0xCCCCCC.rgb()); // others

            rect(20f + (i*15).toFloat(), (height-myAudioData[i])-11, 14f, myAudioData[i]);
        }
        // hint(ENABLE_DEPTH_TEST);
    }

    override fun stop() {
        if (streamAudio) {
            audioInput.close()
        } else {
            audioPlayer.close()
        }
        minim.stop()
        super.stop()
    }
}