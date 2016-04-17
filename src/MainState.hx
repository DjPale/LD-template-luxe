import luxe.States;
import luxe.Mesh;
import luxe.Text;
import luxe.Vector;
import luxe.Input;
import luxe.Sprite;
import luxe.Scene;

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

    var hud : Sprite;
    var background : Sprite;

    var dispatcher : MessageDispatcher;
    var factory : TiledMapObjectFactory;
    var light_batcher : Batcher;

    var spawner : EnemySpawner;
    var sound_player : SoundPlayer;

    var reset_scene : Scene;

    var msg_reset : String;

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

    override function onleave<T>(ignored:T)
    {
        trace('enter state ' + this.name);

        cleanup();
    }

    override function onmousemove(event: luxe.MouseEvent)
    {
    }

    override function onkeydown(event: KeyEvent)
    {
        if (event.keycode == Key.key_r)
        {
            reset_level();
        }
        if (event.keycode == Key.key_h)
        {
            global.canvas.visible = !global.canvas.visible;
        }
    }

    override function update(dt: Float)
    {
        spawner.update(dt);

        background.uv.y -= 40 * dt;
    }

    function start_level()
    {
        spawner.run();
    }

    function reset_level_delayed(_)
    {
        player.visible = false;
        player_inp.input_enabled = false;

        reset_scene.empty();
        spawner.running = false;

        Actuate.timer(2).onComplete(reset_level);
    }

    function reset_level()
    {
        reset_scene.empty();
        reset_player();
        spawner.reset();
        spawner.run();
    }

    function setup()
    {
        reset_scene = new Scene('reset_scene');

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
        physics2d.set_layer_collision(LAYER_ENEMY, LAYER_ENEMY, false);
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

        sound_player = new SoundPlayer();

        setup_player();

        spawner = new EnemySpawner(physics2d, player, sound_player);
        spawner.enemy_layer = LAYER_ENEMY;
        spawner.bullet_layer = LAYER_ENEMY_BULLET;
        spawner.scene = reset_scene;

        setup_hud();

        setup_debug();

        spawner.reset();
        spawner.run();

        msg_reset = Luxe.events.listen('LevelReset', reset_level_delayed);
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

        phys.set_topdown_configuration(150, 0);
        phys.body.collision_response = false;

        var animation = player.add(new SpriteAnimation({ name: 'SpriteAnimation' }));
        animation.add_from_json_object(Luxe.resources.json('assets/player_anim.json').asset.json);
        animation.animation = 'attack_default';
        animation.play();

        var weapon = new Weapon(physics2d, phys, sound_player, { name: 'Weapon' });
        weapon.bullet_layer = LAYER_PLAYER_BULLET;
        weapon.scene = reset_scene;
        player.add(weapon);

        var dmg_recv = player.add(new DamageReceiver(sound_player, { name: 'DamageReceiver' }));

        //player.add(new DamageDealer({ name: 'DamageDealer' }));

        player_cap = player.add(new ShapeCapabilities(weapon, phys, dmg_recv, { name: 'ShapeCapabilities' }));

        player_inp = player.add(new PlayerInput(phys, player_cap, weapon, animation, { name: 'PlayerInput' }));
        player_inp.input_enabled = true;
    }

    function reset_player()
    {
        phys.body.collider.position.set_xy(150, 300);
        player.get('DamageReceiver').heal();
        player.visible = true;
        player_inp.input_enabled = true;
        player_cap.apply_abilities(0);

        var anim = player.get('SpriteAnimation');
        player_inp.player_state = 'attack';
    }

    function setup_hud()
    {
        hud = new Sprite({
            name: 'hud',
            pos: new Vector(Luxe.camera.size.x / 2, Luxe.camera.size.y - 16),
            texture: Luxe.resources.texture('assets/gfx/ui.png'),
            //batcher: global.ui
        });

        hud.texture.filter_min = hud.texture.filter_mag = FilterType.nearest;

        var ratio = Luxe.screen.w / Luxe.screen.h;

    	background = new Sprite({
    		name: 'background',
    		texture: Luxe.resources.texture('assets/background.png'),
    		size: new Vector(Luxe.screen.w, Luxe.screen.w / ratio),
    		centered: false,
    		depth: -1
    		});

    	background.texture.clamp_s = background.texture.clamp_t = phoenix.Texture.ClampType.repeat;
    }

    function setup_debug()
    {
        var win = new DebugWindow(watcher, global.layout, {
            name: 'player-debug',
            title: 'player',
            parent: global.canvas,
            x: Luxe.screen.w - 256, y: 0, w: 256, h: 256,
            w_min: 256, h_min: 128,
            closable: false, collapsible: true, resizable: true,
        });

        win.register_watch(phys, 'proxy_pos', 0.1,  DebugWatcher.fmt_vec2d, DebugWatcher.set_vec2d);
        win.register_watch(phys, 'move_speed', 1.0, DebugWatcher.fmt_vec2d_f, DebugWatcher.set_vec2d);
        win.register_watch(player_inp, 'bullet_speed', 1.0, null, DebugWatcher.set_float);
        win.register_watch(player_cap, 'current_shape', 0.1);
        win.register_watch(player.get('DamageReceiver'), 'hitpoints', 0.1);

        var win2 = new DebugWindow(watcher, global.layout, {
            name: 'world-debug',
            title: 'world',
            parent: global.canvas,
            x: Luxe.screen.w - 256, y: 384, w: 256, h: 256,
            w_min: 256, h_min: 128,
            closable: false, collapsible: true, resizable: true,
        });

        win2.register_watch(Luxe.camera, 'pos', 0.1, DebugWatcher.fmt_vec2d, null, 'camera pos');
        win2.register_watch(physics2d, 'draw', 1.0, null, DebugWatcher.set_bool);
        win2.register_watch(physics2d, 'bodies', 0.2, function(v:Dynamic) { return Std.string(v == null ? '<null>' : Lambda.count(v)); } );
        win2.register_watch(spawner, 'running', 0.5, null, DebugWatcher.set_bool, 'spawner run');

    }

    function cleanup()
    {
        //Luxe.events.unlisten(msg_reset);
        player.visible = false;
        player_inp.input_enabled = false;

        reset_scene.empty();
        spawner.running = false;
    }
}
