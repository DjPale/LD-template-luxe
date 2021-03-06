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
import luxe.importers.tiled.TiledMap;

import physics2d.PhysicsEngine2D;
import physics2d.Physics2DRigidBody;
import physics2d.components.Physics2DBody;

import util.DebugWatcher;
import util.DebugWindow;
import util.TiledMapHelper;

import phoenix.Batcher;
import phoenix.Shader;

import Main;

class MainState extends State
{
    var global : GlobalData;
    var batcher : phoenix.Batcher;
    var physics2d : PhysicsEngine2D;
    var watcher: DebugWatcher;

    var phys : Physics2DBody;
    var trigger : Physics2DRigidBody;

    var dispatcher : MessageDispatcher;
    var factory : TiledMapObjectFactory;
    var light_batcher : Batcher;
    var light: Sprite;
    var nmapshader : Shader;


    var map : TiledMap;

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
        light.pos.copy_from(Luxe.camera.screen_point_to_world(event.pos));

        if (nmapshader != null)
        {
            nmapshader.set_vector3('lightPos', new Vector(event.pos.x / Luxe.screen.width, event.pos.y / Luxe.screen.h, 0.75));
        }
    }


    function setup()
    {
        watcher = new DebugWatcher();

        var map_data = Luxe.resources.text('assets/testmap.tmx');

        var map_scale = 2.0;

        map = new TiledMap({
            tiled_file_data: map_data.asset.text,
            format: 'tmx'
        });

        light_batcher = Luxe.renderer.create_batcher({
            name: 'light_batcher',
            camera: Luxe.camera.view,
            layer: 2
        });

        light = new Sprite({
            name: 'light',
            batcher: light_batcher,
            texture: Luxe.resources.texture('assets/gradient.png'),
            color: new luxe.Color().rgb(0xFFD700)
            //scale: new Vector(2, 2)
        });

        Actuate.tween(light.scale, 1.0, { x: 2, y: 2 }).reflect().repeat().ease(Sine.easeInOut);

        light_batcher.on(prerender, function(b:Batcher){ Luxe.renderer.blend_mode(BlendMode.src_alpha, BlendMode.one); });
        light_batcher.on(postrender, function(b:Batcher){ Luxe.renderer.blend_mode(); });

        factory = new TiledMapObjectFactory('assets/prefabs.json', map, physics2d);

        map.display({
            scale: map_scale
        });

        var nmap_tex = Luxe.resources.texture('assets/tiles_n.png');
        nmap_tex.slot = 1;
        nmapshader = Luxe.resources.shader('nmaplit');
        nmapshader.set_texture('tex1', nmap_tex);
        nmapshader.set_vector2('resolution', Luxe.screen.size);
        TiledMapHelper.apply_tile_shader(map, nmapshader);

        //Actuate.timer(1).onComplete(function() { TiledMapHelper.apply_tile_shader(map, nmapshader); });

        physics2d.gravity.set_xy(0, 10);
        physics2d.draw = true;
        physics2d.paused = false;

        factory.register_tile_collision_layer('Solids');
        factory.register_object_collision_layer('Solid Objects', map_scale);
        factory.register_trigger_layer('Trigger Objects', map_scale);
        factory.register_entity_layer('Entity Objects', map_scale);

        var p = new luxe.Entity({
            name: 'player',
        });

        phys = p.add(new Physics2DBody(physics2d, Polygon.rectangle(64, 64, 64, 64, true), { name: 'Physics2DBody' }));
        p.pos.copy_from(phys.body.collider.position);

        phys.set_platformer_configuration(200, 132, 0.5, 0.2, 2, true);

        p.add(new PlayerInput(phys));

        var cam = new behavior.CameraFollow();
        Luxe.camera.add(cam);
        cam.target = p.pos;
        cam.bounds.set(0, 0, 100, 0);

        physics2d.add_obstacle_collision(Polygon.rectangle(0, Luxe.screen.height - 20, Luxe.screen.width, 20, false));

        var db = new Physics2DRigidBody();
        db.layer = 3;
        db.collider = Polygon.rectangle(32, 128, 128, 20, true);
        physics2d.set_layer_collision(2, 3, false);

        physics2d.add_body(db);

        trigger = physics2d.add_trigger(new Circle(64, 64, 32));
        trigger.ontrigger = function(_) { trace('trigger enter');  };

        physics2d.add_obstacle_collision(Polygon.rectangle(0, Luxe.screen.height - 80, 20, 60, false));
        physics2d.add_obstacle_collision(Polygon.rectangle(Luxe.screen.width - 20, Luxe.screen.height - 80, 20, 60, false));

        dispatcher = new MessageDispatcher(map);
        dispatcher.register_triggers();

        setup_debug();
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
        win.register_watch(phys.body, 'is_trigger', 0.2, null, DebugWatcher.set_bool);
        win.register_watch(phys.body, 'collision_response', 0.2, null, DebugWatcher.set_bool);
        win.register_watch(phys, 'jump_times', 1.0, null, DebugWatcher.set_int);
        win.register_watch(phys, 'jump_counter', 0.1);
        win.register_watch(phys.body, 'layer', 1.0, null, DebugWatcher.set_int);
        win.register_watch(phys, 'was_airborne', 0.1);
        win.register_watch(trigger, 'trigger_list', 0.2, function(v:Dynamic) { return Std.string(v == null ? '<null>' : Lambda.count(v)); } );

        var win2 = new DebugWindow(watcher, global.layout, {
            name: 'world-debug',
            title: 'world',
            parent: global.canvas,
            x: Luxe.screen.w - 256, y: 384, w: 256, h: 128,
            w_min: 256, h_min: 128,
            closable: false, collapsible: true, resizable: true,
        });

        win2.register_watch(Luxe.camera, 'pos', 0.1, DebugWatcher.fmt_vec2d);
        win2.register_watch(physics2d, 'gravity', 1.0, DebugWatcher.fmt_vec2d_f, DebugWatcher.set_vec2d);
        win2.register_watch(physics2d, 'paused', 1.0, null, DebugWatcher.set_bool);
        win2.register_watch(physics2d, 'draw', 1.0, null, DebugWatcher.set_bool);
    }
}
