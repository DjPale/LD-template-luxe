import luxe.Color;
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
    var player_dmg : DamageReceiver;

    var hud : Sprite;
    var score_txt : Text;
    var hull_txt : Text;
    var lvl_txt : Text;

    var dispatcher : MessageDispatcher;
    var factory : TiledMapObjectFactory;
    var light_batcher : Batcher;

    var spawner : EnemySpawner;
    var sound_player : SoundPlayer;

    var reset_scene : Scene;

    var msg_reset : String;
    var mouse: Vector;

    public var has_done_init : Bool = false;

    public static var LAYER_PLAYER : Int = PhysicsEngine2D.LAYER_DEFAULT;
    public static var LAYER_PLAYER_BULLET : Int = 3;
    public static var LAYER_ENEMY_BULLET : Int = 4;
    public static var LAYER_ENEMY : Int = 5;

    public function new(_global:GlobalData, _batcher:phoenix.Batcher)
    {
        super({ name: 'MainState' });

        global = _global;
        batcher = _batcher;

        mouse = new Vector();

        physics2d = Luxe.physics.add_engine(PhysicsEngine2D);
    }

    override function onenter<T>(ignored:T)
    {
        trace('enter state ' + this.name);

        setup();
    }

    override function onleave<T>(ignored:T)
    {
        trace('leave state ' + this.name);

        cleanup();
    }

    override function onmousemove(event: luxe.MouseEvent)
    {
        mouse.set_xy(event.x,event.y);
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
        if (event.keycode == Key.key_x)
        {
            if (global.states.current_state == this)
            {
                global.states.set('MenuState');
            }
        }
    }

    override function update(dt: Float)
    {
        update_hud();

        spawner.update(dt);
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

        Actuate.timer(1).onComplete(reset_level);
    }

    function reset_level()
    {
        if (global.states.current_state != this) return;

        reset_scene.empty();
        reset_player();
        spawner.reset();
        spawner.run();
    }

    function setup()
    {
        if (has_done_init)
        {
            reset_level();
            show_shit(true);
            return;
        }

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
            attack: 1,
            defense: 1,
            speed: 1,
            rof: 1,
        });
        ShapeCapabilities.templates.push({
            attack: 0,
            defense: 10,
            speed: 0.5,
            rof: 0,
        });
        ShapeCapabilities.templates.push({
            attack: 1,
            defense: 1,
            speed: 1.5,
            rof: 1,
        });

        sound_player = new SoundPlayer();

        setup_background();

        setup_player();

        spawner = new EnemySpawner(physics2d, player, sound_player);
        spawner.enemy_layer = LAYER_ENEMY;
        spawner.bullet_layer = LAYER_ENEMY_BULLET;
        spawner.scene = reset_scene;

        setup_hud();

        setup_debug();

        spawner.reset();
        //spawner.run();

        msg_reset = Luxe.events.listen('LevelReset', reset_level_delayed);

        spawner.spawn_composite(new Vector(100, 200));

        has_done_init = true;
    }

    function setup_background() {

        new Sprite({
            name : 'background',
            size : new Vector(Luxe.screen.w, Luxe.screen.h),
            color : new Color(0, 0, 0, 1),
            pos : new Vector(0, 0),
            depth: -10
        });

        var star : Sprite;
        for( i in 0...150 ) {

            star = new Sprite({
                name : 'star'+i,
                size : new Vector(1, 1),
                color : new Color(1, 1, 1, 1),
                pos : new Vector(Luxe.utils.random.int(0, Luxe.screen.w), Luxe.utils.random.int(0, Luxe.screen.h))
            });

            star.add(new StarComponent());
        }
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

        phys = player.add(new Physics2DBody(physics2d, Polygon.rectangle(150, 300, 16, 16, true), { name: 'Physics2DBody' }));
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

        player_dmg = player.add(new DamageReceiver(sound_player, { name: 'DamageReceiver' }));

        //player.add(new DamageDealer({ name: 'DamageDealer' }));

        player_cap = player.add(new ShapeCapabilities(weapon, phys, player_dmg, { name: 'ShapeCapabilities' }));

        player_inp = player.add(new PlayerInput(phys, player_cap, weapon, animation, sound_player, { name: 'PlayerInput' }));
        player_inp.auto_switch_on(3.0);
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

        player_inp.auto_switch_on(3.0);
    }

    function setup_hud()
    {
        hud = new Sprite({
            name: 'hud',
            pos: new Vector(Luxe.camera.size.x / 2, Luxe.camera.size.y - 16),
            texture: Luxe.resources.texture('assets/gfx/ui.png'),
            depth: 100
            //batcher: global.ui
        });

        score_txt = new Text({
            name: 'score_txt',
            font: global.font,
            sdf: false,
            pos: new Vector(10),
            point_size: 8,
            text: 'SCORE 0',
            visible: false
        });

        hull_txt = new Text({
            name: 'hull_txt',
            font: global.font,
            sdf: false,
            pos: new Vector(Luxe.camera.size.x - 100),
            point_size: 8,
            text: 'HULL 1'
        });

        lvl_txt = new Text({
            name: 'lvl_txt',
            font: global.font,
            sdf: false,
            pos: new Vector(Luxe.camera.size.x - 40, 40),
            point_size: 8,
            text: 'L1'
        });

        hud.texture.filter_min = hud.texture.filter_mag = FilterType.nearest;

        var ratio = Luxe.screen.w / Luxe.screen.h;
    }

    function update_hud()
    {
        lvl_txt.text = 'L' + (spawner.level_idx + 1);
        hull_txt.text = 'HULL ' + player_dmg.hitpoints;
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

    function show_shit(visible: Bool)
    {
        hud.visible = visible;
        global.canvas.visible = visible;
        score_txt.visible = visible;
        lvl_txt.visible = visible;
        hull_txt.visible = visible;
    }

    function cleanup()
    {
        //Luxe.events.unlisten(msg_reset);
        player.visible = false;
        player_inp.input_enabled = false;

        reset_scene.empty();
        spawner.running = false;

        show_shit(false);
    }
}
