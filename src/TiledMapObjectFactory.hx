import luxe.importers.tiled.TiledMap;
import luxe.importers.tiled.TiledObjectGroup;

import physics2d.PhysicsEngine2D;
import physics2d.components.Physics2DTrigger;

import util.ReflectionHelper;
import util.PrefabManager;
import util.TiledMapHelper;

class TiledMapObjectFactory
{
    var map: TiledMap;
    var physics2d: PhysicsEngine2D;
    var prefabs : PrefabManager;

    public function new(_prefab_id: String, _map: TiledMap, _physics: PhysicsEngine2D)
    {
        map = _map;
        physics2d = _physics;

        prefabs = new PrefabManager();
        var prefab_res = Luxe.resources.json(_prefab_id);
        prefabs.load_from_resouce(prefab_res);

        prefabs.register_var("physics2d", physics2d);
        prefabs.register_var("map", map);
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
            var shape = TiledMapHelper.object_to_shape(obj, _scale);

            if (shape == null)
            {
                trace('warning, unkown shape collision object id ' + obj.id);
                continue;
            }

            var entity = new luxe.Entity({
                name: obj.name,
            });

            var trigger = entity.add(new Physics2DTrigger(physics2d, shape));
            ReflectionHelper.apply_properties(trigger, obj.properties);
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

        for (obj in group.objects)
        {
            var shape = TiledMapHelper.object_to_shape(obj, _scale);

            if (shape == null)
            {
                trace('warning, unkown shape collision object id ' + obj.id);
                continue;
            }

            var entity = null;

            if (prefabs.has_prefab(obj.type))
            {
                prefabs.register_var("$shape", shape);
                entity = prefabs.instantiate(obj.type);
                entity.pos.copy_from(obj.pos);
                entity.name = obj.name;

                prefabs.register_var("$shape", shape);
            }
        }
    }

    public inline function find_group(name: String) : TiledObjectGroup
    {
        return Lambda.find(map.tiledmap_data.object_groups, function(g) { return g.name == name;  } );
    }
}
