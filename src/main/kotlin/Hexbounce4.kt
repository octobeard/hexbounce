import hype.H
import hype.HCanvas
import hype.HDrawablePool
import hype.HShape
import hype.extended.behavior.HOscillator
import hype.extended.behavior.HRotate
import hype.extended.behavior.HTimer
import hype.extended.colorist.HColorPool
import hype.extended.layout.HGridLayout


class Hexbounce4 : Hexbase() {
    var swapXY = false

    lateinit var canvas: HCanvas
    lateinit var canvas2: HCanvas

    var pool1Cols = 10
    var pool1Rows = (pool1Cols * stageH.toFloat() / stageW.toFloat()).toInt() + 1
    var pool2Cols = 15
    var pool2Rows = (pool2Cols * stageH.toFloat() / stageW.toFloat()).toInt() + 1
    val pool1 = HDrawablePool(pool1Cols * pool1Rows);
    val pool2 = HDrawablePool(pool2Cols * pool2Rows)

    val colorPool = HColorPool(
        0xEC02EC.rgb(),
        0xA1029F.rgb(),
        0x53044C.rgb(),
        0x830270.rgb(),
        0xEA00A0.rgb(),
        0xB5014F.rgb(),
        0xF862A3.rgb(),
        0xF10063.rgb(),
        0x822A4B.rgb(),
        0xB3032B.rgb(),
        0xFB0401.rgb(),
        0xD32C02.rgb(),
        0xAF2C01.rgb(),
        0x862802.rgb(),
        0x0208BC.rgb(),
        0x0526E6.rgb(),
        0x070B49.rgb(),
        0x320479.rgb(),
        0x3301BC.rgb(),
        0x0054F1.rgb(),
        0x0384FF.rgb(),
        0x5E14E6.rgb(),
        0x580A89.rgb(),
        0xA30EE8.rgb(),
        0x5F54ED.rgb(),
        0x382674.rgb(),
        0x9E5AF5.rgb(),
        0xE757F0.rgb(),
        0xA949AD.rgb(),
        0x9E99FC.rgb()
    )
    val blueColorPool = HColorPool(
        0x0208BC.rgb(),
        0x0526E6.rgb(),
        0x002CB8.rgb(),
        0x3301BC.rgb(),
        0x0054F1.rgb(),
        0x0384FF.rgb(),
        0x5F54ED.rgb()
    )
    override fun hexBaseSetup() {
        canvas = HCanvas(stageW.toFloat(), stageH.toFloat()).autoClear(false).fade(2)
        canvas2 = HCanvas(stageW.toFloat(), stageH.toFloat()).autoClear(false).fade(3)
        H.add(canvas2)
        H.add(canvas)

        pool1.autoParent(canvas)
            .add(HShape(PATH_DATA + "cyrcle1.svg"))
            .add(HShape(PATH_DATA + "cyrcle2.svg"))
            .add(HShape(PATH_DATA + "cyrcle3.svg"))
            .add(HShape(PATH_DATA + "cyrcle4.svg"))
            .add(HShape(PATH_DATA + "cyrcle5.svg"))
            .add(HShape(PATH_DATA + "cyrcle6.svg"))
            .add(HShape(PATH_DATA + "cyrcle7.svg"))
            .layout(
                HGridLayout()
                    .startX((stageW / (pool1Cols * 2)).toFloat())
                    .startY((stageW / (pool1Cols * 4)).toFloat())
                    .spacing((stageW / pool1Cols).toFloat(), (stageW / pool1Cols).toFloat())
                    .cols(pool1Cols)
            )
            .onCreate { obj ->
                val initSize = stageW / pool1Cols + random(10f, 200f).toInt()
                val d = obj as HShape
                d
                    .enableStyle(false)
                    //.stroke(0x000000.rgb())
                    .noStroke()
                    .anchorAt(H.CENTER)
                    .rotate( 90f * random(3f).toInt() )
                    .size( initSize.toFloat() )
                    .alpha(150)
                    .num("band", random(myAudioRange.toFloat()).toInt().toFloat())
                var rotateValue = random(-3f, 2f).toInt()
                if (rotateValue == 0) rotateValue = 1
                HRotate(d, rotateValue.toFloat())
                d.randomColors(colorPool.fillOnly())

                HOscillator()
                    .target(d)
                    .property(H.SIZE)
                    .relativeVal(initSize.toFloat())
                    .range(-100f, 250f)
                    .speed(random(2f))
                    .freq(2f)
                    .currentStep(pool1.currentIndex().toFloat())
            }
            .requestAll()

        pool2.autoParent(canvas2)
            .add(HShape(PATH_DATA + "cyrcle1.svg"))
            .add(HShape(PATH_DATA + "cyrcle2.svg"))
            .add(HShape(PATH_DATA + "cyrcle3.svg"))
            .add(HShape(PATH_DATA + "cyrcle4.svg"))
            .add(HShape(PATH_DATA + "cyrcle5.svg"))
            .add(HShape(PATH_DATA + "cyrcle6.svg"))
            .add(HShape(PATH_DATA + "cyrcle7.svg"))
            .layout(HGridLayout()
                .startX((stageW / pool2Cols / 2).toFloat())
                .startY((stageW / pool2Cols / 2).toFloat())
                .spacing((stageW / pool2Cols).toFloat(), (stageW / pool2Cols).toFloat())
                .cols(pool2Cols)
            )
            .onCreate { obj ->
                val d = obj as HShape
                val initSizeOffset = random((myAudioRange * 6).toFloat()).toInt() + 200

                d
                    .enableStyle(false)
                    .noStroke()
                    .anchorAt(H.CENTER)
                    .rotate( 90f * random(4f).toInt() )
                    .size( initSizeOffset.toFloat() )
                    .alpha(150)
                    .num("initSize", initSizeOffset.toFloat())
                    .num("band", random(myAudioRange.toFloat()).toInt().toFloat())
                    .num("rand", random(-50f, 50f))

                if (d.num("band") > 4) {
                    HOscillator()
                        .target(d)
                        .property(H.X)
                        .relativeVal(d.x())
                        .range(-100f, 100f)
                        .speed(random(3f))
                        .freq(2f)
                        .currentStep(pool2.currentIndex().toFloat())
                } else {
                    HOscillator()
                        .target(d)
                        .property(H.Y)
                        .relativeVal(d.y())
                        .range(-100f, 100f)
                        .speed(random(2f))
                        .freq(2f)
                        .currentStep(pool2.currentIndex().toFloat())
                }
                d.randomColors(colorPool.fillOnly())
            }
            .requestAll()

        for (d in pool2) {
            d.num("initY", d.y())
            d.num("initX", d.x())
        }
        HTimer().interval(1000).callback {
            swapXY = !swapXY;
        }
    }

    override fun hexBaseDraw() {
        val canvasAlphaFft = map(myAudioData[0], 0f, (myAudioMax / 2).toFloat(), 10f, 255f).toInt()
        canvas2.alpha(canvasAlphaFft)
        for (d in pool2) {
            val band = d.num("band").toInt()
            val initSize = d.num("initSize").toInt()
            val rand = d.num("rand").toInt()
            val sizeFft =
                map(myAudioData[band], 0f, myAudioMax.toFloat(), initSize.toFloat(), (initSize + 200).toFloat()).toInt()
            val sizeFftSmall =
                map(myAudioData[band], 0f, myAudioMax.toFloat(), initSize.toFloat(), (initSize + 50).toFloat()).toInt()
            val alphaFft = map(myAudioData[7], 0f, (myAudioMax / 4).toFloat(), 100f, 255f).toInt()
            val rotateFft = map(myAudioData[band], 0f, myAudioMax.toFloat(), -40f, 40f).toInt()
            val yFft = map(
                myAudioData[band],
                0f,
                myAudioMax.toFloat(),
                (-100 + rand).toFloat(),
                (100 + rand).toFloat()
            ).toInt()
            val xFft = map(
                myAudioData[band],
                0f,
                myAudioMax.toFloat(),
                (-100 + rand).toFloat(),
                (100 + rand).toFloat()
            ).toInt()
            if (band == 0) {
                //d.rotate(rotateFft);
                d.alpha(alphaFft)
                if (swapXY) {
                    d.y(d.num("initY") + yFft)
                } else {
                    d.x(d.num("initX") + xFft)
                    (d as HShape).randomColors(blueColorPool.fillOnly())
                }
            } else if (band == 2) {
                d.alpha(alphaFft)
                if (swapXY) {
                    d.x(d.num("initX") + xFft)
                    (d as HShape).randomColors(blueColorPool.fillOnly())
                } else {
                    d.y(d.num("initY") + yFft)
                }
            } else if (band in 3..4) {
                d.size(sizeFft.toFloat())
            } else {
                d.alpha(alphaFft)
                d.size(sizeFftSmall.toFloat())
                if (myAudioData[0] <= 5) {
                    if (swapXY) {
                        d.x(d.num("initX") + xFft)
                        (d as HShape).randomColors(blueColorPool.fillOnly())
                    } else {
                        d.y(d.num("initY") + yFft)
                    }
                }
            }
        }
    }
}