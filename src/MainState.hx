import luxe.States;
import luxe.Mesh;
import luxe.Text;
import luxe.Vector;

import luxe.collision.shapes.Polygon;
import luxe.collision.shapes.Circle;
import luxe.importers.tiled.TiledMap;

import physics2d.PhysicsEngine2D;
import physics2d.Physics2DRigidBody;
import physics2d.components.Physics2DBody;

import util.DebugWatcher;
import util.DebugWindow;

import Main;

class MainState extends State
{
    var global : GlobalData;
    var batcher : phoenix.Batcher;
    var physics2d : PhysicsEngine2D;
    var watcher: DebugWatcher;

    var phys : Physics2DBody;
    var trigger : Physics2DRigidBody;

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

    override function update(dt:Float)
    {
    }

    function setup()
    {
        watcher = new DebugWatcher();

        var map_data = Luxe.resources.text('assets/testmap.tmx');

        map = new TiledMap({
            tiled_file_data: map_data.asset.text,
            format: 'tmx'
        });

        map.display({
            scale: 2
        });

        physics2d.gravity.set_xy(0, 10);
        physics2d.draw = true;
        physics2d.paused = false;

        physics2d.add_tile_collision_layer(map.layer('Solids'));

        physics2d.add_object_collision_layer(map.tiledmap_data.object_groups[0], 2);

        var p = new luxe.Entity({
            name: 'player',
        });

        phys = p.add(new Physics2DBody(physics2d, { name: 'Physics2DBody' }));

        phys.body.collider = Polygon.rectangle(64, 64, 64, 64, true);
        p.pos.copy_from(phys.body.collider.position);

        phys.set_platformer_configuration(200, 132, 0.5, 0.2, 2, true);

        p.add(new PlayerInput(phys));

        physics2d.add_obstacle_collision(Polygon.rectangle(0, Luxe.screen.height - 20, Luxe.screen.width, 20, false));

        var db = new Physics2DRigidBody();
        db.layer = 2;
        db.collider = Polygon.rectangle(32, 128, 128, 20, true);

        physics2d.add_body(db);

        trigger = physics2d.add_trigger(new Circle(64, 64, 32));
        trigger.ontrigger = function(_) { trace('trigger enter');  };

        physics2d.add_obstacle_collision(Polygon.rectangle(0, Luxe.screen.height - 80, 20, 60, false));
        physics2d.add_obstacle_collision(Polygon.rectangle(Luxe.screen.width - 20, Luxe.screen.height - 80, 20, 60, false));

        setup_debug();
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
        win.register_watch(phys.body, 'velocity', 0.1, DebugWatcher.fmt_vec2d);
        win.register_watch(phys, 'move_speed', 1.0, DebugWatcher.fmt_vec2d_f, DebugWatcher.set_vec2d);
        win.register_watch(phys.body, 'damp', 0.2, DebugWatcher.fmt_vec2d_f, DebugWatcher.set_vec2d);
        win.register_watch(phys, 'jump_times', 1.0, null, DebugWatcher.set_int);
        win.register_watch(phys, 'jump_counter', 0.1);
        win.register_watch(phys, 'was_airborne', 0.1);
        win.register_watch(trigger, 'trigger_list', 0.2, function(v:Dynamic) { return Std.string(v == null ? '<null>' : Lambda.count(v)); } );

        var win2 = new DebugWindow(watcher, global.layout, {
            name: 'world-debug',
            title: 'world',
            parent: global.canvas,
            x: Luxe.screen.w - 256, y: 256, w: 256, h: 128,
            w_min: 256, h_min: 128,
            closable: false, collapsible: true, resizable: true,
        });

        win2.register_watch(physics2d, 'gravity', 1.0, DebugWatcher.fmt_vec2d_f, DebugWatcher.set_vec2d);
        win2.register_watch(physics2d, 'paused', 1.0, null, DebugWatcher.set_bool);
        win2.register_watch(physics2d, 'draw', 1.0, null, DebugWatcher.set_bool);
    }
}
