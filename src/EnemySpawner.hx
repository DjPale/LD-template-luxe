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
    public var base_size : Float = 16;
    public var enemy_layer : Int = PhysicsEngine2D.LAYER_DEFAULT;
    public var bullet_layer : Int = PhysicsEngine2D.LAYER_DEFAULT;
    public var spawn_interval : Float = 5;

    public var spawn_blocks : Array<Array<String>> = [
        [
        "   0       0   ",
        "               ",
        "  1    1    1  "
        ],
        [
        "  0        0   ",
        "       0       ",
        " 2  2     2  2 ",
        ]
    ];

    public var spawn_marks : String = "xx0x1xx0xx1x1";

    var spawn_mark_idx = 0;

    var spawn_interval_cnt : Float = 0;

    var physics2d : PhysicsEngine2D;
    var player : Entity;


    public function new(_physics2d: PhysicsEngine2D, _player: Entity)
    {
        physics2d = _physics2d;
        player = _player;
    }

    public function update(dt: Float)
    {
        if (spawn_interval_cnt > 0)
        {
            spawn_interval_cnt -= dt;

            if (spawn_interval_cnt <= 0)
            {
                spawn_mark();
            }
        }
    }

    public function spawn_mark()
    {
        spawn_interval_cnt = spawn_interval;

        spawn_mark_idx++;

        if (spawn_mark_idx >= spawn_marks.length) spawn_mark_idx = 0;

        var m : String = spawn_marks.charAt(spawn_mark_idx);

        var idx = Std.parseInt(m);
        if (idx == null) return;

        trace('spawn mark $spawn_mark_idx block idx $idx');

        var block = spawn_blocks[idx];
        var y_ofs = -1;

        for (row in block)
        {
            y_ofs--;

            for (ch_idx in 0...row.length)
            {
                var e_type = Std.parseInt(row.charAt(ch_idx));

                if (e_type != null)
                {
                    spawn_enemy(new Vector(ch_idx * (base_size + 2) + base_size / 2, y_ofs * (base_size + 2) - base_size / 2), e_type);
                }
            }
        }
    }

    public function spawn_enemy(spos: Vector, ?_type : Int = -1) : Sprite
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

        var weapon = sprite.add(new Weapon(physics2d, phys, { name: 'Weapon' }));
        weapon.bullet_layer = bullet_layer;
        weapon.fire_rate = 2;
        weapon.bullet_speed = 100;

        var cap = new ShapeCapabilities(weapon, phys, dmg_recv, { name: 'ShapeCapabilities' });
        sprite.add(cap);

        var be = new BasicEnemy(player, phys, cap, { name: 'BasicEnemy' });

        if (_type == -1)
        {
            be.cap_type = Luxe.utils.random.int(0, 3);
        }
        else
        {
            be.cap_type = _type;
        }

        sprite.add(be);

        return sprite;
    }
}
