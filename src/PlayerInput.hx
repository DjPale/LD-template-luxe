import luxe.Input;
import luxe.Sprite;
import luxe.Vector;

import luxe.collision.shapes.Polygon;

import physics2d.Physics2DRigidBody;
import physics2d.components.Physics2DBody;

import luxe.collision.data.ShapeCollision;

import behavior.Bullet;
import behavior.DamageDealer;

class PlayerInput extends luxe.Component
{
    public var bullet_speed : Float = 200.0;
    public var fire_rate : Float = 0.2;

    public var change_cooldown : Float = 1;

    var change_cooldown_cnt : Float = 0;

    var fire_rate_cnt : Float = 0;

    var phys : Physics2DBody;
    var cap: ShapeCapabilities;
    var dmg: DamageDealer;

    public function new(_phys: Physics2DBody, _cap: ShapeCapabilities, _dmg: DamageDealer, ?_options: luxe.options.ComponentOptions)
    {
        super(_options);

        phys = _phys;
        cap = _cap;
        dmg = _dmg;
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

        if (fire_rate_cnt > 0) fire_rate_cnt -= dt;
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

        if (Luxe.input.inputdown("fire"))
        {
            fire();
        }

        if (Luxe.input.inputdown("chg_attack"))
        {
            change_shape(0);
        }
        else if (Luxe.input.inputdown("chg_defense"))
        {
            change_shape(1);
        }
        else if (Luxe.input.inputdown("chg_speed"))
        {
            change_shape(2);
        }

        if (Luxe.input.inputdown("left"))
        {
            x = -1;
        }
        else if (Luxe.input.inputdown("right"))
        {
            x = 1;
        }

        if (Luxe.input.inputdown("up"))
        {
            y = -1;
        }
        else if (Luxe.input.inputdown("down"))
        {
            y = 1;
        }

        phys.move(x, y);
    }

    function fire()
    {
        if (fire_rate_cnt > 0) return;

        fire_rate_cnt = fire_rate;

        var bullet = new Sprite({
            name: 'bullet',
            name_unique: true,
            size: new Vector(2, 2),
        });

        bullet.pos.copy_from(entity.pos);

        var bullet_phys = bullet.add(
            new Physics2DBody(
                phys.body.engine,
                Polygon.rectangle(bullet.pos.x, bullet.pos.y, 2, 2),
                { name: 'Bullet' })
            );

        bullet_phys.set_topdown_configuration(bullet_speed, 1);
        bullet_phys.body.collision_response = false;
        bullet_phys.body.layer = 3;
        bullet_phys.move(0, -1);

        var bul_dmg = bullet.add(new DamageDealer({ name: 'DamageDealer' }));
        bul_dmg.damage = dmg.damage;

        bullet.add(new Bullet());

    }
}
