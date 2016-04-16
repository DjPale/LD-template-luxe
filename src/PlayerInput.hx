import luxe.Input;
import luxe.Sprite;
import luxe.Vector;

import luxe.components.sprite.SpriteAnimation;
import physics2d.components.Physics2DBody;

class PlayerInput extends luxe.Component
{
    public var change_cooldown : Float = 1;
    public var weapon_dir: Vector = new Vector(0, -1);

    var change_cooldown_cnt : Float = 0;

    var phys : Physics2DBody;
    var cap: ShapeCapabilities;
    var weapon: Weapon;
    var animation: SpriteAnimation;

    var player_state = 'attack';

    public function new(_phys: Physics2DBody, _cap: ShapeCapabilities, _weapon: Weapon, _animation: SpriteAnimation, ?_options: luxe.options.ComponentOptions)
    {
        super(_options);

        phys = _phys;
        cap = _cap;
        weapon = _weapon;
        animation = _animation;
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
    }

    override public function update(dt: Float)
    {
        handle_input();

        if (change_cooldown_cnt > 0) change_cooldown_cnt -= dt;
    }

    function change_shape(num: Int)
    {
        if (change_cooldown_cnt > 0 || cap.current_shape == num) return;

        change_cooldown_cnt = change_cooldown;

        cap.apply_abilities(num);
    }

    function handle_input()
    {
        var x = 0;
        var y = 0;
        var player_direction = 'default';


        if (Luxe.input.inputdown("fire"))
        {
            weapon.fire(weapon_dir);
        }

        if (Luxe.input.inputdown("chg_attack"))
        {
            change_shape(0);
            player_state = 'attack';
        }
        else if (Luxe.input.inputdown("chg_defense"))
        {
            change_shape(1);
            player_state = 'defence';
        }
        else if (Luxe.input.inputdown("chg_speed"))
        {
            change_shape(2);
            player_state = 'speed';
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

        animation.animation = player_state + '_' + player_direction;
        animation.play();

        phys.move(x, y);
    }
}
