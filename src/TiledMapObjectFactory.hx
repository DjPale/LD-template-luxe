import luxe.importers.tiled.TiledMap;
import luxe.importers.tiled.TiledObjectGroup;

import physics2d.PhysicsEngine2D;
import physics2d.components.Physics2DTrigger;

class TiledMapObjectFactory
{
    var map: TiledMap;
    var physics2d: PhysicsEngine2D;

    public function new(_map: TiledMap, _physics: PhysicsEngine2D)
    {
        map = _map;
        physics2d = _physics;
    }

    public function register_tile_collision_layer(name: String)
    {
        physics2d.add_tile_collision_layer(map.layer(name));
    }

    public function register_object_collision_layer(name: String, ?scale: Float = 1.0)
    {
        var group = find_group(name);

        if (group == null)
        {
            trace('Could not find collision group layer with name $name');
            return;
        }

        physics2d.add_object_collision_layer(group, 2);
    }

    public function register_trigger_layer(name: String, ?_scale: Float = 1.0)
    {
        var group = find_group(name);

        if (group == null)
        {
            trace('Could not find trigger group layer with name $name');
            return;
        }

        for (obj in group.objects)
        {
            var shape = PhysicsEngine2D.object_to_shape(obj, _scale);

            if (shape == null)
            {
                trace('warning, unkown shape collision object id ' + obj.id);
                continue;
            }

            var entity = new luxe.Entity({
                name: obj.name,
            });

            var trigger = entity.add(new Physics2DTrigger(physics2d, shape));
            apply_properties(trigger, obj.properties);
        }
    }

    // 1. Check for prefabs
    // 2. Check for class which inherits entity
    // 3. Check for component (create entity and attach component)
    public function register_entity_layer(name: String, ?_scale: Float = 1.0)
    {
        var group = find_group(name);

        if (group == null)
        {
            trace('Could not find entity group layer with name $name');
            return;
        }


    }

    public static function apply_properties(obj: Dynamic, props: Map<String,String>)
    {
        if (props == null) return;

        for (p in props.keys())
        {
            Reflect.setProperty(obj, p.toLowerCase(), props[p]);
        }
    }

    public inline function find_group(name: String) : TiledObjectGroup
    {
        return Lambda.find(map.tiledmap_data.object_groups, function(g) { return g.name == name;  } );
    }
}
