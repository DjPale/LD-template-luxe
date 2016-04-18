import luxe.Color;
import luxe.Input;
import luxe.Sprite;
import luxe.Vector;

import luxe.tween.Actuate;

import luxe.components.sprite.SpriteAnimation;
import physics2d.components.Physics2DBody;

import behavior.DamageReceiver;

class PlayerInput extends luxe.Component
{
    public var change_cooldown : Float = 1;
    public var weapon_dir: Vector = new Vector(0, -1);
    public var input_enabled : Bool = false;
    public var dual_weapon : Bool = true;
    public var auto_switch : Float = 3.0;

    var change_cooldown_cnt : Float = 0;

    var auto_switch_cnt : Float = 0;

    var phys : Physics2DBody;
    var cap: ShapeCapabilities;
    var weapon: Weapon;
    var animation: SpriteAnimation;
    var dmg_recv: DamageReceiver;

    public var player_state : String = 'attack';
    var previous_player_state : String = 'attack';

    var msg_dead : String;
    var msg_col : String;
    var sound_player : SoundPlayer;

    var ui_shapes : Map<Int, Sprite>;

    public function new(_phys: Physics2DBody, _cap: ShapeCapabilities, _weapon: Weapon, _animation: SpriteAnimation, _sound_player: SoundPlayer, ?_options: luxe.options.ComponentOptions)
    {
        super(_options);

        phys = _phys;
        cap = _cap;
        weapon = _weapon;
        animation = _animation;
        sound_player = _sound_player;
    }

    override function init()
    {
        Luxe.input.bind_key("left", Key.left);
        Luxe.input.bind_key("right", Key.right);
        Luxe.input.bind_key("up", Key.up);
        Luxe.input.bind_key("down", Key.down);
        Luxe.input.bind_key("fire", Key.space);

        Luxe.input.bind_key("chg_attack", Key.key_1);
        Luxe.input.bind_key("chg_defense", Key.key_2);
        Luxe.input.bind_key("chg_speed", Key.key_3);

        msg_dead = entity.events.listen(DamageReceiver.message, ondead);
        msg_col = entity.events.listen(Physics2DBody.message, oncollision);

        dmg_recv = entity.get('DamageReceiver');

        ui_shapes = [
            0 =>
            new Sprite({
                name: '1',
                pos: new Vector(31, Luxe.camera.size.y - 32),
                color: new Color(0, 0, 0, 0),
                size: new Vector(78, 32),
                centered: false,
                depth: 101
            }),
            1 =>
            new Sprite({
                name: '2',
                pos: new Vector(111, Luxe.camera.size.y - 32),
                color: new Color(0, 0, 0, 0.75),
                size: new Vector(78, 32),
                centered: false,
                depth: 101
            }),
            2 =>
            new Sprite({
                name: '3',
                pos: new Vector(191, Luxe.camera.size.y - 32),
                color: new Color(0, 0, 0, 0.75),
                size: new Vector(78, 32),
                centered: false,
                depth: 101
            })
        ];
    }

    override public function update(dt: Float)
    {
        handle_input();

        clamp_position(phys.body.collider.position);
        clamp_position(entity.pos);

        if (change_cooldown_cnt > 0) change_cooldown_cnt -= dt;

        if (auto_switch_cnt > 0)
        {
            auto_switch_cnt -= dt;

            if (auto_switch_cnt <= 0)
            {

                var next_shape = ((cap.current_shape + 1) % 3);
                //trace('try to change to ' + next_shape);
                change_shape(next_shape);

                for(shape in ui_shapes) {
                    shape.color.a = 0.75;
                }

                ui_shapes[next_shape].color.a = 0;
                Actuate.tween(ui_shapes[next_shape].color, 3, { a: 0.75 });

            }
        }
    }

    override public function ondestroy()
    {
        entity.events.unlisten(msg_dead);
        entity.events.unlisten(msg_col);
    }

    function oncollision(e: Physics2DBodyCollisionParams)
    {
        if (StringTools.startsWith(e.target.name, 'enemy') || StringTools.startsWith(e.target.name, 'part'))
        {
            e.target.get('DamageReceiver').deal(entity, 1);
            dmg_recv.deal(e.target, 1);
        }
    }

    function ondead(_)
    {
        sound_player.play('player_explodes');

        Luxe.events.fire('LevelReset');
    }

    public function auto_switch_on(t: Float)
    {
        auto_switch = t;
        auto_switch_cnt = auto_switch;
    }

    function change_shape(num: Int) : Bool
    {
        if (change_cooldown_cnt > 0 || cap.current_shape == num) return false;

        change_cooldown_cnt = change_cooldown;
        auto_switch_cnt = auto_switch;

        cap.apply_abilities(num);

        return true;
    }

    function clamp_position(p: Vector)
    {
        if (entity == null) return;

        var ofs = 12;

        p.x = luxe.utils.Maths.clamp(p.x, ofs, Luxe.camera.size.x - ofs);
        p.y = luxe.utils.Maths.clamp(p.y, ofs, Luxe.camera.size.y - ofs - 32);
    }

    function fire()
    {
        if (weapon.damage > 0)
        {
            if (dual_weapon && cap.current_shape == ShapeCapabilities.SHAPE_ATTACK)
            {
                var ready = weapon.fire(weapon_dir, false, new Vector(-10, 0));
                if (ready) weapon.fire(weapon_dir, true, new Vector(10, 0));
            }
            else
            {
                weapon.fire(weapon_dir);
            }
        }
    }

    function handle_input()
    {
        var x = 0;
        var y = 0;

        var can_swith = (auto_switch > 0);

        var player_direction = 'default';

        if (input_enabled)
        {
            if (Luxe.input.inputdown("fire"))
            {
                fire();
            }

            if (can_swith && Luxe.input.inputdown("chg_attack"))
            {
                change_shape(0);
            }
            else if (can_swith && Luxe.input.inputdown("chg_defense"))
            {
                change_shape(1);
            }
            else if (can_swith && Luxe.input.inputdown("chg_speed"))
            {
                change_shape(2);
            }

            if (Luxe.input.inputdown("left"))
            {
                x = -1;
                player_direction = 'left';
            }
            else if (Luxe.input.inputdown("right"))
            {
                x = 1;
                player_direction = 'right';
            } else {
                player_direction = 'default';
            }


            if (Luxe.input.inputdown("up"))
            {
                y = -1;
            }
            else if (Luxe.input.inputdown("down"))
            {
                y = 1;
            }
        }

        var cur_shape = cap.current_shape;
        if (cur_shape == ShapeCapabilities.SHAPE_ATTACK) player_state = "attack";
        if (cur_shape == ShapeCapabilities.SHAPE_DEFEND) player_state = "defence";
        if (cur_shape == ShapeCapabilities.SHAPE_SPEED) player_state = "speed";

        if (previous_player_state != player_state) {

            previous_player_state = player_state;
            sound_player.play('transform');
        }

        animation.animation = player_state + '_' + player_direction;
        animation.play();

        phys.move(x, y);
    }
}
