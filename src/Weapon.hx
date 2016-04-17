import luxe.Component;
import luxe.Sprite;
import luxe.Vector;
import luxe.Scene;

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
    public var bullet_speed : Float = 300;
    public var bullet_layer : Int = PhysicsEngine2D.LAYER_DEFAULT;
    public var bullet_size : Vector = new Vector(4, 4);
    public var scene : Scene;

    var fire_rate_cnt : Float = 0;

    var physics2d : PhysicsEngine2D;
    var phys : Physics2DBody;
    var sound_player : SoundPlayer;

    public function new(_physics2d: PhysicsEngine2D, _phys: Physics2DBody, _sound_player: SoundPlayer, ?_options: luxe.options.ComponentOptions)
    {
        super(_options);

        physics2d = _physics2d;
        phys = _phys;
        sound_player = _sound_player;

        scene = Luxe.scene;
    }

    override function update(dt: Float)
    {
        if (fire_rate_cnt > 0) fire_rate_cnt -= dt;
    }

    public function fire(direction: Vector)
    {
        if (fire_rate_cnt > 0) return;

        var volume = 1.0;
        if (entity.name != 'player') {
            volume = 0.1;
        }
        sound_player.play('blaster', volume);

        fire_rate_cnt = fire_rate;

        var bullet = new Sprite({
            name: 'bullet',
            name_unique: true,
            size: bullet_size,
            color: new luxe.Color().rgb(0xffff00),
            scene: scene
        });

        bullet.pos.copy_from(entity.pos);

        var bullet_phys = bullet.add(
            new Physics2DBody(
                physics2d,
                Polygon.rectangle(bullet.pos.x, bullet.pos.y, bullet_size.x, bullet_size.y),
                { name: 'Bullet' })
            );

        bullet_phys.set_topdown_configuration(bullet_speed, 1);
        bullet_phys.body.collision_response = false;
        bullet_phys.body.layer = bullet_layer;
        direction.normalize();

        bullet_phys.move_speed.set_xy(direction.x * bullet_speed, direction.y * bullet_speed);
        bullet_phys.move_speed.add(phys.body.velocity);

        bullet_phys.body.apply_velocity(bullet_phys.move_speed.x, bullet_phys.move_speed.y);

        var bul_dmg = bullet.add(new DamageDealer({ name: 'DamageDealer' }));
        bul_dmg.damage = damage;
        bul_dmg.destroy_on_impact = true;

        bullet.add(new Bullet());

    }
}
