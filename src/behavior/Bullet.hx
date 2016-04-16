package behavior;

import luxe.Component;

class Bullet extends Component
{
    function check_bounds()
    {
        if (entity == null) return;

        if (entity.pos.x < 0 || entity.pos.x > Luxe.camera.size.x || entity.pos.y < 0 || entity.pos.y > Luxe.camera.size.y)
        {
            entity.destroy();
        }
    }


    override function update(dt: Float)
    {
        check_bounds();
    }
}
