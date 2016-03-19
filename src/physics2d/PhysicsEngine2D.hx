package physics2d;

import luxe.Vector;
import luxe.collision.Collision;
import luxe.collision.shapes.Shape;
import luxe.collision.shapes.Polygon;

import luxe.tilemaps.Tilemap;
import luxe.importers.tiled.TiledObjectGroup;

import luxe.utils.Maths;

typedef Physics2DTileLayer = {
    layer: TileLayer,
    collider: Shape
};

class PhysicsEngine2D extends luxe.Physics.PhysicsEngine
{
    var bodies : Array<Physics2DRigidBody>;
    var obstacles : Array<Shape>;
    var layers : Array<Physics2DTileLayer>;

    var drawer : luxe.collision.ShapeDrawerLuxe;

    public function new()
    {
        super();

        bodies = [];
        obstacles = [];
        layers = [];

        drawer = new luxe.collision.ShapeDrawerLuxe();
    }

    override public function init()
    {
        gravity.set_xyz(0, 10, 0);
    }

    override public function update()
    {
        if (paused) return;

        handle_physics();
        handle_collisions();
    }

    override public function render()
    {
        if (!draw) return;

        for (s in obstacles)
        {
            drawer.drawShape(s);
        }

        for (b in bodies)
        {
            drawer.drawShape(b.collider);
        }
    }

    public function clear()
    {
        while (obstacles.length > 0) obstacles.pop();
        while (layers.length > 0) layers.pop();
        while (bodies.length > 0) bodies.pop();
    }

    public function add_body(body: Physics2DRigidBody)
    {
        bodies.push(body);
    }

    public function remove_body(body: Physics2DRigidBody)
    {
        bodies.remove(body);
    }

    public function add_tile_collision_layer(layer: TileLayer)
    {
        var scale = layer.map.visual.options.scale;
        var collider = Polygon.rectangle(0, 0, layer.map.tile_width * scale, layer.map.tile_height * scale, false);
        layers.push({layer: layer, collider: collider});
    }

    public function add_object_collision_layer(object_group: TiledObjectGroup, ?_scale: Float = 1.0)
    {
        for (obj in object_group.objects)
        {
            if (obj.object_type == TiledObjectType.rectangle)
            {
                var r = Polygon.rectangle(
                    obj.pos.x * _scale, obj.pos.y * _scale,
                    obj.width , obj.height ,
                    false);

                r.scaleX = _scale;
                r.scaleY = _scale;

                add_obstacle_collision(r);
            }
            else if (obj.object_type == TiledObjectType.polygon)
            {
                var p = obj.polyobject;
                var r = new Polygon(p.origin.x * _scale, p.origin.y * _scale, p.points);

                r.scaleX = _scale;
                r.scaleY = _scale;

                add_obstacle_collision(r);
            }
            else
            {
                trace('warning, unkown collision object id ' + obj.id);
            }
        }
    }

    public function add_obstacle_collision(shape: Shape)
    {
        obstacles.push(shape);
    }

    inline function check_obstacle_collision(b: Physics2DRigidBody, ofs_x: Float, ofs_y: Float) : Bool
    {
        var ret = false;

        b.collider.position.add_xyz(ofs_x, ofs_y, 0);

        for (s in obstacles)
        {
            if (Collision.shapeWithShape(b.collider, s) != null)
            {
                ret = true;
                break;
            }
        }

        b.collider.position.subtract_xyz(ofs_x, ofs_y, 0);

        return ret;
    }

    inline public function check_static_collision(b: Physics2DRigidBody, ofs_x: Float, ofs_y: Float) : Bool
    {
        return check_tile_collision(b, ofs_x, ofs_y) || check_obstacle_collision(b, ofs_x, ofs_y);
    }

    function check_tile_collision(b: Physics2DRigidBody, ofs_x: Float, ofs_y: Float) : Bool
    {
        if (layers.length == 0) return false;

        b.collider.position.add_xyz(ofs_x, ofs_y, 0);

        for (l in layers)
        {
            var scale = l.layer.map.visual.options.scale;
            var top_left = l.layer.map.worldpos_to_map(b.collider.position, scale);
            //TODO: calculate shape bounding box
            var bottom_right = l.layer.map.worldpos_to_map(Vector.Add(b.collider.position,new Vector(200,200)), scale);

            for (x in Std.int(top_left.x-1)...Std.int(bottom_right.x))
            {
                for (y in Std.int(top_left.y-1)...Std.int(bottom_right.y))
                {
                    var t = l.layer.map.tile_at(l.layer.name, x, y);
                    if (t != null && t.id != 0)
                    {
                        l.collider.position = l.layer.map.tile_pos(l.layer.name, x, y, scale);

                        if (Collision.shapeWithShape(b.collider, l.collider) != null)
                        {
                            if (draw) drawer.drawShape(l.collider);
                            b.collider.position.subtract_xyz(ofs_x, ofs_y, 0);
                            return true;
                        }
                    }
                }
            }
        }

        b.collider.position.subtract_xyz(ofs_x, ofs_y, 0);

        return false;
    }

    inline function move_body(b : Physics2DRigidBody)
    {
        var d_x = b.velocity.x * Luxe.physics.step_delta;
        var d_y = b.velocity.y * Luxe.physics.step_delta;

        if (!b.collides_static)
        {
            b.collider.position.x += d_x;
            b.collider.position.y += d_y;
            return;
        }

        var r_x = d_x;
        var r_y = d_y;

        var i_x = Std.int(Math.abs(r_x));
        var i_y = Std.int(Math.abs(r_y));

        var s_x = Maths.sign(r_x);
        var s_y = Maths.sign(r_y);

        // step y one int unit at a time and check collision each time
        while (i_y > 0)
        {
            if (check_static_collision(b, 0, s_y))
            {
                b.velocity.y = 0;
                break;
            }
            else
            {
                b.collider.position.y += s_y;
            }

            i_y -= 1;
        }

        // get the y remainder
        r_y -= Std.int(d_y);
        // only check if we didn't already collide
        if (i_y == 0)
        {
            if (!check_static_collision(b, 0, r_y))
            {
                b.collider.position.y += r_y;
            }
            else
            {
                b.velocity.y = 0;
            }
        }

        // same approach with x...
        while (i_x > 0)
        {
            if (check_static_collision(b, s_x, 0))
            {
                b.velocity.x = 0;
                break;
            }
            else
            {
                b.collider.position.x += s_x;
            }

            i_x -= 1;
        }

        r_x -= Std.int(d_x);
        if (i_x == 0)
        {
            if (!check_static_collision(b, r_x, 0))
            {
                b.collider.position.x += r_x;
            }
            else
            {
                b.velocity.x = 0;
            }
        }
    }

    function handle_physics()
    {
        for (b in bodies)
        {
            if (b.add.x != 0)
            {
                b.velocity.x += b.add.x;
                b.add.x = 0;
            }

            if (b.add.y != 0)
            {
                b.velocity.y += b.add.y;
                b.add.y = 0;
            }

            b.velocity.x += gravity.x * Luxe.physics.step_delta;
            b.velocity.y += gravity.y * Luxe.physics.step_delta;

            move_body(b);

            //b.collider.x = Math.round(b.collider.x);
            //b.collider.y = Math.round(b.collider.y);

            b.velocity.x *= b.damp.x;
            b.velocity.y *= b.damp.y;
        }
    }

    function handle_collisions()
    {
        for (b in bodies)
        {
            if (b.collider == null || !b.collides_body || b.oncollision == null) continue;

            for (tgt in bodies)
            {
                if (b == tgt) continue;

                var col = Collision.shapeWithShape(b.collider, tgt.collider);
                if (col != null)
                {
                    b.oncollision(b, col);
                }
            }
        }
    }
}
