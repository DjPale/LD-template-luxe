import luxe.Vector;
import luxe.Sprite;
import luxe.Entity;
import luxe.Scene;
import luxe.Particles;
import luxe.Color;

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
    public var xplosions : Array<ParticleSystem>;
    var xplosion_idx : Int = 0;

    var spawn_blocks : Array<Array<String>> = [
        [
        " 2           2 ",
        "               ",
        "       2       ",
        ],
        [
        " 1           1 ",
        "               ",
        "       1       ",
        ],
        [
        " 0           0 ",
        "               ",
        "       0       ",
        ],
        [
        "   11     11   ",
        "    11   11    ",
        "     11 11     ",
        ],
        [
        "2  0       0  2",
        " 0   1   1   0 ",
        "0      2      0"
        ],
        [
        "  0  1   1 0   ",
        " 2     0     2 ",
        "    2     2    ",
        ],
        [
        "0 0 0 0 0 0 0 0",
        " 0 0 0 0 0 0 0 ",
        "0 0 0 0 0 0 0 0",
        ],
        [
        "       3       ",
        "               ",
        "               ",
        ],
        [
        "       4       ",
        "               ",
        "               ",
        ],
        [
        "       5       ",
        "               ",
        "               ",
        "               ",
        ],
    ];

    var composites : Array<Array<String>> = [
        [
        "22",
        "1",
        "00"
        ],
        [
         "0",
        "010",
         "0"
        ],
        [
          "0",
        "021120",
        "021120",
        "021120",
          "0"
        ]
    ];

    var spawn_marks : Array<String> = [
        "x0123xx7xxx4x5x8xx6x7xx9xx4x5x"
    ];

    public var level_idx(default,null) : Int = 0;
    public var spawn_mark_idx(default,null) : Int = 0;

    public var spawn_interval_cnt(default,null) : Float = 0;

    var physics2d : PhysicsEngine2D;
    var player : Entity;
    var sound_player : SoundPlayer;

    public function new(_physics2d: PhysicsEngine2D, _player: Entity, _sound_player: SoundPlayer)
    {
        physics2d = _physics2d;
        player = _player;
        sound_player = _sound_player;

        scene = Luxe.scene;

        create_xplosions();
    }

    function create_xplosions()
    {
        xplosions = [];

        for (i in 0...10)
        {
            var particles = new ParticleSystem({name:'particles-$i'});
            particles.add_emitter({
                name : 'xplosion',
                start_color: new Color(1, 1, 1, 1).rgb(0xaaccee),
                end_color: new Color(1, 1, 1, 0).rgb(0xaa2200),
                pos: new Vector(0,0),
                pos_random: new Vector(0, 0),
                start_size: new Vector(6, 6),
                speed_random: 10,
                direction_random: 360.0,
                end_size: new Vector(0, 0),
                gravity : new Vector(0, 8),
                life: 0.5,
                depth: 20,
                emit_time: 0.25,
                emit_count: 12
            });

            particles.stop();

            xplosions.push(particles);
        }
    }

    public function xplosion(pos: Vector)
    {
        var p = xplosions[xplosion_idx];
        p.pos.copy_from(pos);
        p.start(0.25);

        xplosion_idx++;

        if (xplosion_idx >= xplosions.length) xplosion_idx = 0;
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
        level_idx = 0;
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

        if (spawn_mark_idx >= spawn_marks[level_idx].length) spawn_mark_idx = 0;

        var m : String = spawn_marks[level_idx].charAt(spawn_mark_idx);

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
                    if (e_type > 2)
                    {
                        spawn_composite(
                            new Vector(
                                ch_idx * (base_size + spawn_row_ofs.x) + base_size / 2 + 10,
                                y_ofs * (base_size + spawn_row_ofs.y) - base_size / 2),
                            e_type - 3
                        );
                    }
                    else
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
        weapon.fire_rate = 1;
        weapon.bullet_speed = 150;
        weapon.scene = scene;

        var cap = new ShapeCapabilities(weapon, phys, dmg_recv, { name: 'ShapeCapabilities' });
        sprite.add(cap);

        var be = new BasicEnemy(player, phys, cap, sound_player, this, { name: 'BasicEnemy' });

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

    public function spawn_composite(spos: Vector, num: Int)
    {
        if (num < 0 || num >= composites.length) return;

        var template = composites[num];
        var en_sz = 16;

        var parent_enemy = new Entity({
            name: 'enemy.composite',
            name_unique: true,
            pos: spos,
            scene: scene,
            origin: new Vector(10, 10)
        });

        var weapon = new Weapon(physics2d,  null, sound_player);
        weapon.bullet_layer = bullet_layer;
        weapon.fire_rate = 1;
        weapon.bullet_speed = 150;
        weapon.scene = scene;
        parent_enemy.add(weapon);

        var comp_en = new CompositeEnemy(player,  weapon, sound_player, this, { name: 'CompositeEnemy' });
        parent_enemy.add(comp_en);

        // max height
        var max_h = template.length;
        // max width
        var max_w = 0;
        for (row in template)
        {
            if (row.length > max_w) max_w = row.length;
        }

        parent_enemy.origin.set_xy((max_w * en_sz) / 2, (max_h * en_sz) / 2);

        for (row_idx in 0...max_h)
        {
            var row = template[max_h - row_idx - 1];
            var row_l = row.length;

            for (idx in 0...row_l)
            {
                var m = row.charAt(idx);

                var part = new Sprite({
                    name: 'part.$m.$row_idx-$idx',
                    name_unique: true,
                    parent: parent_enemy,
                    size: new Vector(en_sz, en_sz),
                    texture: Luxe.resources.texture('assets/gfx/enemies.png'),
                    centered: true,
                    scene: scene,
                    pos: new Vector(
                        (((max_w - row_l) * en_sz) / 2) + (idx * en_sz),
                        ((max_h * en_sz) / 2) - (row_idx * en_sz)
                    ),
                });

                part.transform.world.auto_decompose = true;

                var dmg_recv = new DamageReceiver(sound_player, { name: 'DamageReceiver' });
                dmg_recv.hitpoints = 1;
                part.add(dmg_recv);

                var phys = part.add(new Physics2DBody(
                    physics2d,
                    new Circle(spos.x, spos.y, en_sz - 10)
                ));

                phys.set_topdown_configuration(0, 0);
                phys.collision_only = true;
                phys.body.layer = enemy_layer;
                phys.body.collision_response = false;

                parent_enemy.pos.copy_from(spos);

                trace('spawn part ${part.name} of composite ${parent_enemy.name}');

                var animation = part.add(new SpriteAnimation({ name: 'SpriteAnimation' }));
                animation.add_from_json_object(Luxe.resources.json('assets/enemies_anim.json').asset.json);
                if (m == "0") {
                    animation.animation = 'enemy_attack';
                } else if (m == "1") {
                    animation.animation = 'enemy_defense';
                } else if (m == "2") {
                    animation.animation = 'enemy_speed';
                }

            }
        }
    }
}
