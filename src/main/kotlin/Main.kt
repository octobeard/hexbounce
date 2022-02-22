import processing.core.PApplet
import java.awt.Color

fun main() = PApplet.main(Hexbounce1::class.java.name)

fun Int.rgb() : Int {
    return Color(this).rgb
}
