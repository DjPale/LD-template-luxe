import luxe.Color;
import luxe.Sprite;
import luxe.Vector;

class StarComponent extends luxe.Component {

    var star : Sprite;
    var modifier: Float;

    public function new(?_options: luxe.options.ComponentOptions) {
        super(_options);
    }

    override public function init() {
        star = cast entity;
        modifier = Luxe.utils.random.float(0, 0.75);
        star.color.a = modifier;
    }

    override public function update(dt:Float) {
        star.pos.y += 100 * dt * modifier;

        if (star.pos.y > Luxe.camera.size.y) {
            star.pos.x = Std.random(Std.int(Luxe.screen.w));
            star.pos.y = -1;
        }
    }
}
