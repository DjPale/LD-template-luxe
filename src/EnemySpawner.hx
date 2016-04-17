import luxe.Vector;
import luxe.Sprite;
import luxe.Entity;
import luxe.Scene;

import luxe.collision.shapes.Polygon;
import luxe.collision.shapes.Circle;
import luxe.components.sprite.SpriteAnimation;

import physics2d.PhysicsEngine2D;
import physics2d.components.Physics2DBody;

import behavior.DamageDealer;
import behavior.DamageReceiver;

import phoenix.Texture;

class EnemySpawner
{
    public var base_movespeed : Float = 50.0;
    public var base_size : Float = 16;
    public var enemy_layer : Int = PhysicsEngine2D.LAYER_DEFAULT;
    public var bullet_layer : Int = PhysicsEngine2D.LAYER_DEFAULT;
    public var spawn_interval : Float = 5;
    public var spawn_row_ofs : Vector = new Vector(2, 4);
    public var running : Bool = false;
    public var scene : Scene;

    public var spawn_blocks : Array<Array<String>> = [
        [
        "2  0       0  2",
        " 0   1   1   0 ",
        "0      2      0"
        ],
        [
        "  0  1   1 0   ",
        " 2     0     2 ",
        "    2     2    ",
        ]
    ];

    public var spawn_marks : String = "0x1x0x1x1";

    var spawn_mark_idx = 0;

    var spawn_interval_cnt : Float = 0;

    var physics2d : PhysicsEngine2D;
    var player : Entity;
    var sound_player : SoundPlayer;

    public function new(_physics2d: PhysicsEngine2D, _player: Entity, _sound_player: SoundPlayer)
    {
        physics2d = _physics2d;
        player = _player;
        sound_player = _sound_player;

        scene = Luxe.scene;
    }

    public function update(dt: Float)
    {
        if (!running) return;

        if (spawn_interval_cnt > 0)
        {
            spawn_interval_cnt -= dt;

            if (spawn_interval_cnt <= 0)
            {
                spawn_mark();
            }
        }
    }

    public function reset()
    {
        spawn_mark_idx = 0;
        running = false;
    }

    public function run()
    {
        running = true;
        spawn_mark();
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

        for (row_idx in 0...block.length)
        {
            y_ofs--;

            var row = block[block.length - row_idx - 1];

            for (ch_idx in 0...row.length)
            {
                var e_type = Std.parseInt(row.charAt(ch_idx));

                if (e_type != null)
                {
                    spawn_enemy(
                        new Vector(
                            ch_idx * (base_size + spawn_row_ofs.x) + base_size / 2 + 10,
                            y_ofs * (base_size + spawn_row_ofs.y) - base_size / 2),
                        e_type,
                        idx % 3);
                }
            }
        }
    }

    public function spawn_enemy(spos: Vector, ?_type : Int = -1, ?_move : Int = 0) : Sprite
    {
        var image = Luxe.resources.texture('assets/gfx/enemies.png');
            image.filter_min = image.filter_mag = FilterType.nearest;

        var sprite = new Sprite({
            name: 'enemy',
            name_unique: true,
            size: new Vector(base_size, base_size),
            texture: image,
            scene: scene
        });

        var phys = sprite.add(new Physics2DBody(
            physics2d,
            new Circle(spos.x, spos.y, base_size - 10)
        ));

        sprite.pos.copy_from(phys.body.collider.position);

        phys.set_topdown_configuration(base_movespeed, 1);
        phys.body.layer = enemy_layer;
        phys.body.collision_response = false;

        var dmg_recv = new DamageReceiver(sound_player, { name: 'DamageReceiver' });
        dmg_recv.hitpoints = 2;
        sprite.add(dmg_recv);

        // var dmg_deal = new DamageDealer({ name: 'DamageDealer' });
        // sprite.add(dmg_deal);

        var weapon = sprite.add(new Weapon(physics2d, phys, sound_player, { name: 'Weapon' }));
        weapon.bullet_layer = bullet_layer;
        weapon.fire_rate = 0.5;
        weapon.bullet_speed = 150;
        weapon.scene = scene;

        var cap = new ShapeCapabilities(weapon, phys, dmg_recv, { name: 'ShapeCapabilities' });
        sprite.add(cap);

        var be = new BasicEnemy(player, phys, cap, sound_player, { name: 'BasicEnemy' });

        if (_type == -1)
        {
            be.cap_type = Luxe.utils.random.int(0, 3);
        }
        else
        {
            be.cap_type = _type;
        }

        be.move_type = _move;

        var animation = sprite.add(new SpriteAnimation({ name: 'anim' }));
        animation.add_from_json_object(Luxe.resources.json('assets/enemies_anim.json').asset.json);
        if (be.cap_type == 0) {
            animation.animation = 'enemy_attack';
        } else if (be.cap_type == 1) {
            animation.animation = 'enemy_defense';
        } else {
            animation.animation = 'enemy_speed';
        }

        animation.play();

        sprite.add(be);

        return sprite;
    }
}
