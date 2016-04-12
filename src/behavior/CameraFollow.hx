package behavior;

import luxe.Component;
import luxe.Vector;
import luxe.Camera;
import luxe.Rectangle;

class CameraFollow extends Component
{
    public var target : Vector;
    public var bounds : Rectangle;

    var cam : Camera;

    public function new(?_options: luxe.options.ComponentOptions = null)
    {
        super(_options);

        bounds = new Rectangle(0, 0, Luxe.screen.w, Luxe.screen.h);
    }

    override function init()
    {
        cam = cast entity;
    }

    override function update(dt: Float)
    {
        if (cam == null || target == null) return;

        cam.center.copy_from(target);

        if (cam.pos.x < bounds.x) cam.pos.x = bounds.x;
        if (cam.pos.y < bounds.y) cam.pos.y = bounds.y;
        if (cam.pos.x > bounds.x + bounds.w) cam.pos.x = bounds.x + bounds.w;
        if (cam.pos.y > bounds.y + bounds.h) cam.pos.y = bounds.y + bounds.h;
    }
}
