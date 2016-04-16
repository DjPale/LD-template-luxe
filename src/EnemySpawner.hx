import luxe.Vector;
import luxe.Sprite;
import luxe.Entity;

import luxe.collision.shapes.Polygon;
import luxe.collision.shapes.Circle;

import physics2d.PhysicsEngine2D;
import physics2d.components.Physics2DBody;

import behavior.DamageReceiver;

class EnemySpawner
{
    public var base_movespeed : Float = 50.0;
    public var base_size : Float = 32;
    public var enemy_layer : Int = PhysicsEngine2D.LAYER_DEFAULT;
    public var bullet_layer : Int = PhysicsEngine2D.LAYER_DEFAULT;

    var physics2d : PhysicsEngine2D;
    var player : Entity;


    public function new(_physics2d: PhysicsEngine2D, _player: Entity)
    {
        physics2d = _physics2d;
        player = _player;
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

        phys.set_topdown_configuration(base_movespeed, 1);
        phys.body.layer = enemy_layer;
        phys.body.collision_response = false;

        var dmg_recv = new DamageReceiver({ name: 'DamageReceiver' });
        dmg_recv.hitpoints = 2;
        sprite.add(dmg_recv);

        var weapon = sprite.add(new Weapon(physics2d, { name: 'Weapon' }));
        weapon.bullet_layer = bullet_layer;
        weapon.fire_rate = 2;
        weapon.bullet_speed = 100;

        var cap = new ShapeCapabilities(weapon, phys, dmg_recv, { name: 'ShapeCapabilities' });
        sprite.add(cap);

        var be = new BasicEnemy(player, phys, cap, { name: 'BasicEnemy' });
        be.cap_type = Luxe.utils.random.int(0, 3);

        sprite.add(be);

        return sprite;
    }
}
