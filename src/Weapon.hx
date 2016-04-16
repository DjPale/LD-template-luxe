import luxe.Component;
import luxe.Sprite;
import luxe.Vector;

import luxe.collision.shapes.Polygon;
import luxe.collision.data.ShapeCollision;

import physics2d.components.Physics2DBody;
import physics2d.Physics2DRigidBody;
import physics2d.PhysicsEngine2D;

import behavior.Bullet;
import behavior.DamageDealer;

class Weapon extends Component
{
    public var damage : Int = 1;
    public var fire_rate : Float = 0.2;
    public var bullet_speed : Float = 100;
    public var bullet_layer : Int = PhysicsEngine2D.LAYER_DEFAULT;

    var fire_rate_cnt : Float = 0;

    var physics2d : PhysicsEngine2D;

    public function new(_physics2d: PhysicsEngine2D, ?_options: luxe.options.ComponentOptions)
    {
        super(_options);

        physics2d = _physics2d;
    }

    override function update(dt: Float)
    {
        if (fire_rate_cnt > 0) fire_rate_cnt -= dt;
    }

    public function fire(direction: Vector)
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
                physics2d,
                Polygon.rectangle(bullet.pos.x, bullet.pos.y, 2, 2),
                { name: 'Bullet' })
            );

        bullet_phys.set_topdown_configuration(bullet_speed, 1);
        bullet_phys.body.collision_response = false;
        bullet_phys.body.layer = bullet_layer;
        direction.normalize();
        bullet_phys.move_speed.set_xy(direction.x * bullet_speed, direction.y * bullet_speed);
        bullet_phys.body.apply_velocity(bullet_phys.move_speed.x, bullet_phys.move_speed.y);

        var bul_dmg = bullet.add(new DamageDealer({ name: 'DamageDealer' }));
        bul_dmg.damage = damage;

        bullet.add(new Bullet());

    }
}