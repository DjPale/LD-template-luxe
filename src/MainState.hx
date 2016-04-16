import luxe.States;
import luxe.Mesh;
import luxe.Text;
import luxe.Vector;
import luxe.Input;
import luxe.Sprite;

import luxe.tween.Actuate;
import luxe.tween.easing.Sine;

import luxe.collision.shapes.Polygon;
import luxe.collision.shapes.Circle;
import luxe.components.sprite.SpriteAnimation;
import luxe.importers.tiled.TiledMap;

import physics2d.PhysicsEngine2D;
import physics2d.Physics2DRigidBody;
import physics2d.components.Physics2DBody;

import util.DebugWatcher;
import util.DebugWindow;
import util.TiledMapHelper;

import behavior.DamageDealer;
import behavior.DamageReceiver;

import phoenix.Batcher;
import phoenix.Shader;
import phoenix.Texture;

import Main;

class MainState extends State
{
    var global : GlobalData;
    var batcher : phoenix.Batcher;
    var physics2d : PhysicsEngine2D;
    var watcher: DebugWatcher;

    var phys : Physics2DBody;
    var player : Sprite;
    var player_inp : PlayerInput;
    var player_cap : ShapeCapabilities;

    var dispatcher : MessageDispatcher;
    var factory : TiledMapObjectFactory;
    var light_batcher : Batcher;

    var spawner : EnemySpawner;

    public static var LAYER_PLAYER : Int = PhysicsEngine2D.LAYER_DEFAULT;
    public static var LAYER_PLAYER_BULLET : Int = 3;
    public static var LAYER_ENEMY_BULLET : Int = 4;
    public static var LAYER_ENEMY : Int = 5;

    public function new(_global:GlobalData, _batcher:phoenix.Batcher)
    {
        super({ name: 'MainState' });

        global = _global;
        batcher = _batcher;

        physics2d = Luxe.physics.add_engine(PhysicsEngine2D);
    }

    override function onenter<T>(ignored:T)
    {
        trace('enter state ' + this.name);

        setup();
    }

    override function onmousemove(event: luxe.MouseEvent)
    {
    }

    override function update(dt: Float)
    {
        spawner.update(dt);
    }

    function setup()
    {
        watcher = new DebugWatcher();

        // light_batcher = Luxe.renderer.create_batcher({
        //     name: 'light_batcher',
        //     camera: Luxe.camera.view,
        //     layer: 2
        // });
        //
        //
        // light_batcher.on(prerender, function(b:Batcher){ Luxe.renderer.blend_mode(BlendMode.src_alpha, BlendMode.one); });
        // light_batcher.on(postrender, function(b:Batcher){ Luxe.renderer.blend_mode(); });

        physics2d.gravity.set_xy(0, 0);
        physics2d.draw = true;
        physics2d.paused = false;

        physics2d.set_layer_collision(LAYER_PLAYER, LAYER_PLAYER_BULLET, false);
        physics2d.set_layer_collision(LAYER_PLAYER_BULLET, LAYER_PLAYER_BULLET, false);

        physics2d.set_layer_collision(LAYER_ENEMY, LAYER_ENEMY_BULLET, false);
        physics2d.set_layer_collision(LAYER_ENEMY_BULLET, LAYER_ENEMY_BULLET, false);


        ShapeCapabilities.templates.push({
            attack: 2,
            defense: 1,
            speed: 1,
        });
        ShapeCapabilities.templates.push({
            attack: 1,
            defense: 2,
            speed: 1,
        });
        ShapeCapabilities.templates.push({
            attack: 1,
            defense: 1,
            speed: 1.5,
        });

        setup_player();

        spawner = new EnemySpawner(physics2d, player);
        spawner.enemy_layer = LAYER_ENEMY;
        spawner.bullet_layer = LAYER_ENEMY_BULLET;
        spawner.spawn_mark();

        setup_debug();
    }

    function setup_player()
    {
        var image = Luxe.resources.texture('assets/gfx/player.png');
            image.filter_min = image.filter_mag = FilterType.nearest;

        player = new luxe.Sprite({
            name: 'player',
            size: new Vector(32, 32),
            texture: image
        });

        phys = player.add(new Physics2DBody(physics2d, Polygon.rectangle(100, 200, 16, 16, true), { name: 'Physics2DBody' }));
        player.pos.copy_from(phys.body.collider.position);

        phys.set_topdown_configuration(100, 0);
        phys.body.collision_response = false;

<<<<<<< HEAD
        var weapon = player.add(new Weapon(physics2d, phys, { name: 'Weapon' }));
=======
        var animation = player.add(new SpriteAnimation({ name: 'anim' }));
        animation.add_from_json_object(Luxe.resources.json('assets/player_anim.json').asset.json);
        animation.animation = 'idle';
        animation.play();

        var weapon = player.add(new Weapon(physics2d, { name: 'Weapon' }));
>>>>>>> origin/ld35-shapeshift
        weapon.bullet_layer = LAYER_PLAYER_BULLET;

        var dmg_recv = player.add(new DamageReceiver({ name: 'DamageReceiver' }));

        player_cap = player.add(new ShapeCapabilities(weapon, phys, dmg_recv, { name: 'ShapeCapabilities' }));

        player_inp = player.add(new PlayerInput(phys, player_cap, weapon, animation, { name: 'PlayerInput' }));
    }

    function setup_debug()
    {
        var win = new DebugWindow(watcher, global.layout, {
            name: 'player-debug',
            title: 'player',
            parent: global.canvas,
            x: Luxe.screen.w - 256, y: 0, w: 256, h: 384,
            w_min: 256, h_min: 128,
            closable: false, collapsible: true, resizable: true,
        });

        win.register_watch(phys, 'proxy_pos', 0.1,  DebugWatcher.fmt_vec2d, DebugWatcher.set_vec2d);
        win.register_watch(phys.body, 'velocity', 0.1, DebugWatcher.fmt_vec2d);
        win.register_watch(phys, 'move_speed', 1.0, DebugWatcher.fmt_vec2d_f, DebugWatcher.set_vec2d);
        win.register_watch(phys.body, 'damp', 0.2, DebugWatcher.fmt_vec2d_f, DebugWatcher.set_vec2d);
        win.register_watch(phys.body, 'layer', 1.0, null, DebugWatcher.set_int);
        win.register_watch(player_inp, 'bullet_speed', 1.0, null, DebugWatcher.set_float);
        win.register_watch(player_cap, 'current_shape', 0.1);
        win.register_watch(player_inp, 'change_cooldown_cnt', 0.1);


        var win2 = new DebugWindow(watcher, global.layout, {
            name: 'world-debug',
            title: 'world',
            parent: global.canvas,
            x: Luxe.screen.w - 256, y: 384, w: 256, h: 256,
            w_min: 256, h_min: 128,
            closable: false, collapsible: true, resizable: true,
        });

        win2.register_watch(Luxe.camera, 'pos', 0.1, DebugWatcher.fmt_vec2d);
        win2.register_watch(physics2d, 'paused', 1.0, null, DebugWatcher.set_bool);
        win2.register_watch(physics2d, 'draw', 1.0, null, DebugWatcher.set_bool);
        win2.register_watch(physics2d, 'bodies', 0.2, function(v:Dynamic) { return Std.string(v == null ? '<null>' : Lambda.count(v)); } );

    }
}
