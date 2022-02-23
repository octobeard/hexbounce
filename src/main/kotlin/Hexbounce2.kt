import hype.H
import hype.HCanvas
import hype.HDrawablePool
import hype.HShape
import hype.extended.behavior.HTimer
import hype.extended.layout.HGridLayout


class Hexbounce2 : Hexbase() {
    var poolCount = 140
    var swapXY = false

    lateinit var canvas: HCanvas
    lateinit var canvas2: HCanvas

    val pool1 = HDrawablePool(poolCount);
    val pool2 = HDrawablePool(135)

    override fun hexBaseSetup() {
        canvas = HCanvas(stageW.toFloat(), stageH.toFloat()).autoClear(false).fade(3)
        canvas2 = HCanvas(stageW.toFloat(), stageH.toFloat()).autoClear(true)
        H.add(canvas2)
        H.add(canvas)

        pool2.autoParent(canvas2).add(HShape(PATH_DATA + "hexagon.svg"))
            .layout(
                HGridLayout()
                .startX(stageW/20f)
                .startY(0f)
                .spacing(stageW/10f,stageW/10f)
                .cols(10)
            )
            .onCreate { obj ->
                val d = obj as HShape
                d
                    .enableStyle(false)
                    .stroke(0x000000.rgb())
                    .anchorAt(H.CENTER)
                    .rotate( 90f * random(3f).toInt() )
                    .size( stageW / 10f )
                    .alpha(50)
                    .num("band", random(myAudioRange.toFloat()).toInt().toFloat())

                d.randomColors(colorPool.fillOnly())
            }
            .requestAll()

        pool1.autoParent(canvas).add(HShape(PATH_DATA + "hexagon.svg"))
            .layout(HGridLayout()
                .startX(10f)
                .startY(40f)
                .spacing(stageW/15f, stageW/15f)
                .cols(15)
            )
            .onCreate { obj ->
                val d = obj as HShape
                val initSizeOffset = random(myAudioRange * 6f).toInt() + 40
                d
                    .enableStyle(false)
                    .stroke(0x000000.rgb())
                    .anchorAt(H.CENTER)
                    .rotate(random(4f).toInt() * 90f)
                    .size(initSizeOffset.toFloat())
                    .alpha(150)
                    .num("initSize", initSizeOffset.toFloat())
                    .num("band", (random(myAudioRange.toFloat()).toInt()).toFloat())
                    .num("rand", random(-50f, 50f))

                d.randomColors(blueColorPool.fillOnly())
            }
            .requestAll()

        for (d in pool1) {
            d.num("initY", d.y())
            d.num("initX", d.x())
        }
        HTimer().interval(1000).callback {
            swapXY = !swapXY;
        }
    }

    override fun hexBaseDraw() {
        val canvasAlphaFft = map(myAudioData[0], 0f, (myAudioMax / 2).toFloat(), 10f, 255f).toInt()
        canvas.alpha(canvasAlphaFft)
        for (d in pool1) {
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