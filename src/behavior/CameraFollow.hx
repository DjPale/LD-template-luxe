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
    var pos_offset : Vector = new Vector();

    public function new(?_options: luxe.options.ComponentOptions = null)
    {
        super(_options);

        bounds = new Rectangle(0, 0, Luxe.screen.w, Luxe.screen.h);
        recalc_offset();
    }

    override function init()
    {
        cam = cast entity;
    }

    function recalc_offset()
    {
        var ratio = Luxe.screen.device_pixel_ratio;
        if (ratio == 1) return;

        pos_offset = Luxe.screen.size.divideScalar(ratio);
        pos_offset.divideScalar(2.0);
        pos_offset.multiplyScalar(-1);
        trace(pos_offset);
    }

    override function onwindowsized(e: luxe.Screen.WindowEvent)
    {
        recalc_offset();
    }

    override function update(dt: Float)
    {
        if (cam == null || target == null) return;

        var cpos = target.clone();
        cpos.subtract_xyz(cam.size.x / 2, cam.size.y / 2);
        cpos.add(pos_offset);

        cam.pos.copy_from(cpos);

        if (cpos.x < bounds.x + pos_offset.x) cam.pos.x = bounds.x + pos_offset.x;
        if (cpos.y < bounds.y + pos_offset.y) cam.pos.y = bounds.y + pos_offset.y;
        if (cpos.x > bounds.x + pos_offset.x + bounds.w) cam.pos.x = bounds.x + pos_offset.x + bounds.w;
        if (pos_offset.y > bounds.y + pos_offset.y + bounds.h) cam.pos.y = bounds.y + pos_offset.y + bounds.h;
    }
}
