import hype.H
import hype.HDrawablePool
import hype.HShape
import hype.extended.behavior.HTimer
import hype.extended.colorist.HColorPool
import hype.extended.layout.HGridLayout


class Hexbounce1 : Hexbase() {
    var poolCount = 220
    var swapXY = false

    val pool1 = HDrawablePool(poolCount);
    val pool2 = HDrawablePool(135)

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
        pool2.autoAddToStage().add(HShape(PATH_DATA + "hexagon.svg"))
            .layout(HGridLayout()
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
                .alpha(40)
                .num("band", random(myAudioRange.toFloat()).toInt().toFloat())

                d.randomColors(colorPool.fillOnly())
            }
            .requestAll()
        
        pool1.autoAddToStage().add(HShape(PATH_DATA + "hexagon.svg"))
            .layout(HGridLayout()
                .startX(10f)
                .startY(40f)
                .spacing(stageW/20f, stageW/20f)
                .cols(20)
            )
            .onCreate { obj ->
                val d = obj as HShape
                val initSizeOffset = random(myAudioRange * 6f).toInt() + 50
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
                }
            } else if (band == 2) {
                d.alpha(alphaFft)
                if (swapXY) {
                    d.x(d.num("initX") + xFft)
                } else {
                    d.y(d.num("initY") + yFft)
                }
            } else if (band in 3..4) {
                d.size(sizeFft.toFloat())
            } else {
                d.alpha(alphaFft)
                d.size(sizeFftSmall.toFloat())
            }
        }
    }
}