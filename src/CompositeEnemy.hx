import luxe.Component;
import luxe.Vector;
import luxe.Entity;

import physics2d.components.Physics2DBody;

import behavior.DamageReceiver;

class CompositeEnemy extends Component
{
    var dead_msg : Array<String>;

    var weapon : Weapon;
    var player : Entity;
    var velocity : Vector = new Vector();

    public var cap_type : Int = 0;
    public var move_type : Int = 0;

    var sound_player : SoundPlayer;

    var orig_pos : Vector = new Vector();

    public function new(_player: Entity, _sound_player: SoundPlayer, ?_options: luxe.options.ComponentOptions)
    {
        super(_options);

        player = _player;
        sound_player = _sound_player;

        dead_msg = [];
    }

    override function init()
    {
        orig_pos.copy_from(entity.pos);


    }

    function calc_stats()
    {
        var def = 0;
        var spd = 0;

        for (child in entity.children)
        {
            // particularly dirty...
            var type = child.name.charAt(5);

            if (type == "1")
            {
                def += 10;
            }
            else
            {
                def += 1;
            }
        }

        for (child in entity.children)
        {

        }
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
        //entity.events.unlisten(dead_msg);
    }

    function ondead(_)
    {
        sound_player.play('enemy_explodes', 0.7);
        entity.destroy();
    }

    var a : Float = 0;
    function ai_step(dt: Float)
    {
        entity.rotation.setFromEuler(new Vector(0, 0, a));

        a += 1*dt;
    }
}
