import luxe.Component;
import luxe.Vector;
import luxe.Entity;

import luxe.tween.Actuate;

import physics2d.components.Physics2DBody;

import behavior.DamageReceiver;

import scripting.ScriptSequencer;

class CompositeEnemy extends Component
{
    var dead_msg : Array<String>;

    var weapon : Weapon;
    var player : Entity;
    var player_body : Physics2DBody;
    var velocity : Vector = new Vector();
    var move_speed : Float = 0;

    public var cap_type : Int = 0;
    public var move_type : Int = 0;

    var sound_player : SoundPlayer;
    var spawner: EnemySpawner;

    var orig_pos : Vector = new Vector();

    // var sequence : ScriptSequencer;

    public function new(_player: Entity, _weapon: Weapon, _sound_player: SoundPlayer, _spawner: EnemySpawner, ?_options: luxe.options.ComponentOptions)
    {
        super(_options);

        player = _player;
        sound_player = _sound_player;
        weapon = _weapon;
        spawner = _spawner;

        dead_msg = [];

        // sequence = new ScriptSequencer();
        // sequence.loop =
        //
        // sequence.add({
        //     name: '1',
        //     func: move_y_mid,
        //     num: 1
        // });
    }

    inline function calc_time_from_speed(target: Vector) : Float
    {
        var delta = Vector.Subtract(entity.pos, target).length;

        return (delta / move_speed);
    }

    function move_y_mid()
    {
        if (entity == null || entity.destroyed) return;

        var tgt = new Vector(entity.pos.x, Luxe.camera.size.y / 2);
        var d = calc_time_from_speed(tgt);

        Actuate.tween(entity.pos, d, { x: tgt.x, y: tgt.y }).onComplete(move_left);
    }

    function move_left()
    {
        if (entity == null || entity.destroyed) return;

        var tgt = new Vector(40, entity.pos.y);
        var d = calc_time_from_speed(tgt);

        Actuate.tween(entity.pos, d, { x: tgt.x, y: tgt.y }).onComplete(move_right);
    }

    function move_right()
    {
        if (entity == null || entity.destroyed) return;

        var tgt = new Vector(Luxe.camera.size.x - 40, entity.pos.y);
        var d = calc_time_from_speed(tgt);

        Actuate.tween(entity.pos, d, { x: tgt.x, y: tgt.y }).onComplete(move_mid);
    }

    function move_mid()
    {
        if (entity == null || entity.destroyed) return;

        var tgt = new Vector(Luxe.camera.size.x / 2, 100);
        var d = calc_time_from_speed(tgt);

        Actuate.tween(entity.pos, d, { x: tgt.x, y: tgt.y }).onComplete(move_y_mid);
    }

    override function init()
    {
        orig_pos.copy_from(entity.pos);

        player_body = player.get("Physics2DBody");

        add_death_checks();

        calc_stats();

        move_y_mid();
    }

    function add_death_checks()
    {
        for (child in entity.children)
        {
            dead_msg.push(child.events.listen(DamageReceiver.message, ondead));
        }
    }

    function calc_stats()
    {
        var def = 0.0;
        var spd = 100.0;

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

            if (type == "2")
            {
                spd += 20;
            }
        }

        def /= entity.children.length;

        for (child in entity.children)
        {
            var hp : DamageReceiver = child.get('DamageReceiver');
            hp.hitpoints = Math.ceil(def);
        }

        move_speed = spd;

        trace('calc_stats for ${entity.name} - spd: $spd def: $def');
    }

    function ondead(e: Entity)
    {
        sound_player.play('enemy_explodes', 0.7);
        spawner.xplosion(e.transform.world.pos);
        e.parent = null;
        e.destroy();
        calc_stats();

        if (entity.children.length == 0)
        {
            Actuate.stop(entity.pos, null, false, false);
            entity.destroy();
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
        while (dead_msg.length > 0) dead_msg.pop();
    }

    function check_fire()
    {
        if (weapon == null || !weapon.can_fire()) return;

        var player_pos = player_body.proxy_pos;

        if (player_pos == null) return;

        var first = false;
        for (child in entity.children)
        {
            if (child.name.charAt(5) == "0")
            {
                var dir = Vector.Subtract(player_pos, child.transform.world.pos);

                weapon.fire(dir, first, Vector.Subtract(child.pos, entity.origin));
                first = true;
                trace('fire from ${child.name}');
            }
        }
    }

    var a : Float = 0;
    function ai_step(dt: Float)
    {
        check_fire();
    }
}
