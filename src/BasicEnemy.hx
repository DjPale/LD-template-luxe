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
    public var move_type : Int = 0;

    var phys : Physics2DBody;
    var sound_player : SoundPlayer;

    var orig_pos : Vector = new Vector();

    public function new(_player: Entity, _phys: Physics2DBody, _cap: ShapeCapabilities, _sound_player: SoundPlayer, ?_options: luxe.options.ComponentOptions)
    {
        super(_options);

        player = _player;
        cap = _cap;
        phys = _phys;
        sound_player = _sound_player;
    }

    function move_func_1(vec: Vector)
    {
        vec.x = orig_pos.x + Math.cos(vec.y / Luxe.camera.size.y * 20) * 10.0;
    }

    function move_func_2(vec: Vector)
    {
        var add = Math.cos(vec.y / Luxe.camera.size.y * 3) * (orig_pos.x - Luxe.camera.size.x / 2);

        vec.x = orig_pos.x + add;
    }

    override function init()
    {
        dead_msg = entity.events.listen(DamageReceiver.message, ondead);

        weapon = entity.get('Weapon');
        player_body = player.get('Physics2DBody');

        cap.apply_abilities(cap_type);

        orig_pos.copy_from(entity.pos);

        phys.move(0, 1);
    }

    override function update(dt: Float)
    {
        if (entity == null || entity.destroyed) return;

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
        sound_player.play('enemy_explodes', 0.7);
        entity.destroy();
    }

    function ai_step(dt: Float)
    {
        if (weapon != null && cap_type == ShapeCapabilities.SHAPE_ATTACK)
        {
            var player_pos = player_body.proxy_pos;

            if (player_pos != null)
            {
                var dir = Vector.Subtract(player_pos, entity.pos);
                weapon.fire(dir);
            }
        }

        // TODO: temp!
        if (move_type == 1)
        {
            move_func_1(phys.body.collider.position);
        }
        else if (move_type == 2)
        {
            move_func_2(phys.body.collider.position);
        }

    }
}
