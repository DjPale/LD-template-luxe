import luxe.Component;
import luxe.Vector;
import luxe.Entity;

import physics2d.components.Physics2DBody;

import behavior.DamageReceiver;

class BasicEnemy extends Component
{
    var dead_msg : String;

    var weapon : Weapon;
    var player : Entity;
    var player_body : Physics2DBody;
    var cap : ShapeCapabilities;
    public var cap_type : Int = 0;
    var phys : Physics2DBody;

    public function new(_player: Entity, _phys: Physics2DBody, _cap: ShapeCapabilities, ?_options: luxe.options.ComponentOptions)
    {
        super(_options);

        player = _player;
        cap = _cap;
        phys = _phys;
    }

    override function init()
    {
        dead_msg = entity.events.listen(DamageReceiver.message, ondead);

        weapon = entity.get('Weapon');
        player_body = player.get('Physics2DBody');

        cap.apply_abilities(cap_type);

        phys.move(0, 1);
    }

    override function update(dt: Float)
    {
        ai_step(dt);

        if (entity.pos.y > Luxe.camera.size.y)
        {
            entity.destroy();
        }
    }

    override function ondestroy()
    {
        entity.events.unlisten(dead_msg);
    }

    function ondead(_)
    {
        entity.destroy();
    }

    function ai_step(dt: Float)
    {
        if (weapon != null && cap_type == ShapeCapabilities.SHAPE_ATTACK)
        {
            var dir = Vector.Subtract(player_body.proxy_pos, entity.pos);
            weapon.fire(dir);
        }

    }
}
