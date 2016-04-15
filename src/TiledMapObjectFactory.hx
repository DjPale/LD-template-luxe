import luxe.Entity;
import luxe.importers.tiled.TiledMap;
import luxe.importers.tiled.TiledObjectGroup;

import physics2d.PhysicsEngine2D;
import physics2d.components.Physics2DTrigger;

import util.ReflectionHelper;
import util.PrefabManager;
import util.TiledMapHelper;

import scripting.luxe.ScriptComponent;

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
        trace("res=" + prefab_res);
        prefabs.load_from_resource(prefab_res);

        prefabs.register_var("physics2d", physics2d);
        prefabs.register_var("map", map);

        // temp workaround to be sure that we have classes we need when loading dynamically
        new ScriptClassLibraryCustom();
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

            prefabs.register_var("$shape", shape);

            if (prefabs.has_prefab(obj.type))
            {
                trace('trying to create ${obj.name} from prefab ${obj.type}');

                entity = prefabs.instantiate(obj.type);
            }
            else
            {
                trace('trying to create pure ${obj.name} from class ${obj.type}');

                entity = ReflectionHelper.try_instantiate(obj.type);
            }

            if (entity == null)
            {
                trace('warning! could not create obj id ${obj.id}');
            }


            if (entity != null)
            {
                entity.pos.copy_from(obj.pos);
                entity.name = obj.name;
            }

            // apply any tiled-specific properties in the same styles as prefabs
            // ie. '[component.]key = value'
            if (entity != null && obj.properties != null)
            {
                trace('trying to set props for entity ${entity.name}');
                var props = PrefabManager.get_properties_with_components(obj.properties);
                prefabs.apply_properties_with_components(entity, props, true);

                var script_comp : ScriptComponent = entity.get("ScriptManager");

                if (script_comp != null)
                {
                    var script_mgr = script_comp.manager;

                    script_mgr.register_variable('map', map);
                    script_mgr.register_variable('physics2d', physics2d);
                    script_mgr.register_variable('prefabs', prefabs);
                }
            }

            prefabs.register_var("$shape", null);
        }
    }

    public inline function find_group(name: String) : TiledObjectGroup
    {
        return Lambda.find(map.tiledmap_data.object_groups, function(g) { return g.name == name;  } );
    }
}
