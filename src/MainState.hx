import luxe.States;
import luxe.Mesh;
import luxe.Text;
import luxe.Vector;

import luxe.collision.shapes.Polygon;
import luxe.collision.shapes.Circle;

import physics2d.PhysicsEngine2D;
import physics2d.Physics2DBody;

import luxe.importers.tiled.TiledMap;


import Main;

class MainState extends State
{
    var global : GlobalData;
    var batcher : phoenix.Batcher;
    var physics2d : PhysicsEngine2D;

    var _debug : Text;
    var phys : Physics2DBody;

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
        if (phys != null) _debug.text = phys.entity.pos.x + "," + phys.entity.pos.y;
    }

    function setup()
    {
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

        _debug = new Text({
            pos: new Vector(10,10)
        });

        var p = new luxe.Entity({
            name: 'player',
        });

        phys = p.add(new Physics2DBody(physics2d, { name: 'Physics2DBody' }));

        phys.body.collider = Polygon.rectangle(64, 64, 64, 64, true);
        p.pos.copy_from(phys.body.collider.position);
        //phys.body.collides_static = false;

        //phys.body.damp_y = 0.0;

        phys.set_platformer_configuration(200, 132, 0.5, 0.2, 2, true);

        p.add(new PlayerInput(phys));

        physics2d.add_obstacle_collision(Polygon.rectangle(0, Luxe.screen.height - 20, Luxe.screen.width, 20, false));
        physics2d.add_obstacle_collision(Polygon.rectangle(Luxe.screen.mid.x, Luxe.screen.mid.y, 128, 20, true));

        physics2d.add_obstacle_collision(new Circle(Luxe.screen.mid.x - 64, Luxe.screen.mid.y + 64, 32));

        physics2d.add_obstacle_collision(Polygon.rectangle(0, Luxe.screen.height - 80, 20, 60, false));
        physics2d.add_obstacle_collision(Polygon.rectangle(Luxe.screen.width - 20, Luxe.screen.height - 80, 20, 60, false));
    }
}
