import luxe.Vector;
import luxe.Sprite;

import luxe.collision.shapes.Polygon;
import luxe.collision.shapes.Circle;

import physics2d.PhysicsEngine2D;
import physics2d.components.Physics2DBody;

import behavior.DamageReceiver;

class EnemySpawner
{
    public var base_movespeed : Float = 200.0;
    public var base_size : Float = 32;

    var physics2d : PhysicsEngine2D;


    public function new(_physics2d: PhysicsEngine2D)
    {
        physics2d = _physics2d;
    }

    public function spawn_enemy(spos: Vector) : Sprite
    {
        var sprite = new Sprite({
            name: 'enemy',
            name_unique: true,
            size: new Vector(base_size, base_size)
        });

        var phys = sprite.add(new Physics2DBody(
            physics2d,
            Polygon.square(spos.x, spos.y, base_size)
        ));

        phys.set_topdown_configuration(base_movespeed, 0);
        phys.body.layer = 4;
        phys.body.collision_response = false;

        var dmg_recv = new DamageReceiver({ name: 'DamageReceiver' });
        dmg_recv.hitpoints = 2;
        sprite.add(dmg_recv);

        sprite.add(new BasicEnemy({ name: 'BasicEnemy' }));

        return sprite;
    }
}
