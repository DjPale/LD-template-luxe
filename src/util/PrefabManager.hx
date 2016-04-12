package util;

import luxe.Entity;

import luxe.resource.Resource;

typedef PrefabComponent = {
    name: String,
    constructor: Array<String>,
};

typedef Prefab = {
    name: String,
    base: String,
    properties: Map<String, Map<String,String>>,
    components: Array<String>
};

class PrefabManager
{
    var res : JSONResource;

    var components : Map<String,PrefabComponent>;
    var prefabs : Map<String,Prefab>;
    var var_list : Map<String,Dynamic>;

    static var ROOT : String = "root";

    public function new()
    {
        prefabs = new Map<String,Prefab>();
        components = new Map<String,PrefabComponent>();
        var_list = new Map<String,Dynamic>();
    }

    public function register_var(name: String, obj: Dynamic)
    {
        var_list.set(name, obj);
    }

    public function load_from_resource(_res: JSONResource)
    {
        var json = _res.asset.json;

        var it_components : Array<Dynamic> = json.components;
        for (comp in it_components)
        {
            var c : PrefabComponent = { name: comp.name, constructor: comp.constructor };
            var idx = c.name.lastIndexOf(".");
            components.set(c.name.substr(idx + 1), c);
        }

        var it_prefabs : Array<Dynamic> = json.prefabs;

        for (prefab in it_prefabs)
        {
            var p : Prefab = { name: prefab.name, base: prefab.base, properties: null, components: null };
            prefabs.set(p.name, p);

            var tmp_props = ReflectionHelper.json_to_properties(prefab.properties);

            p.properties = get_properties_with_components(tmp_props);

            p.components = prefab.components;
        }
    }

    public static function get_properties_with_components(props: Map<String,String>) : Map<String,Map<String,String>>
    {
        var ret = null;

        if (props == null) return ret;

        ret = new Map<String,Map<String,String>>();

        for (k in props.keys())
        {
            var comp_id = ROOT;
            var comp_key = k;

            var dot = k.indexOf(".");
            if (dot != -1 && dot < k.length - 1)
            {
                comp_id = k.substring(0, dot);
                comp_key = k.substring(dot + 1);
            }

            if (ret[comp_id] == null) ret.set(comp_id, new Map<String,String>());
            ret[comp_id].set(comp_key, props[k]);
        }

        return ret;
    }

    public function apply_properties_with_components(entity: Entity, props: Map<String,Map<String,String>>, ?auto_create_comps : Bool = false)
    {
        if (props == null) return;

        var keys = props.keys();
        for (k in keys)
        {
            if (k == ROOT)
            {
                ReflectionHelper.apply_properties(entity, props[k]);
            }
            else
            {
                var comp = entity.get(k);
                if (comp == null && auto_create_comps)
                {
                    comp = instantiate_component(k);
                }

                if (comp != null)
                {
                    ReflectionHelper.apply_properties(comp, props[k]);
                }
            }
        }
    }

    public function build_constructor(clist: Array<String>) : Array<Dynamic>
    {
        var ret = [];

        if (clist == null || clist.length == 0) return ret;

        for (a in clist)
        {
            ret.push(var_list.get(a));
        }

        return ret;
    }

    public function instantiate_component(name: String) : luxe.Component
    {
        var pfcomp = components.get(name);

        if (pfcomp == null) return null;

        var cl = Type.resolveClass(pfcomp.name);
        var constr = build_constructor(pfcomp.constructor);
        return Type.createInstance(cl, constr);
    }

    public function instantiate(name: String) : luxe.Entity
    {
        var ret = null;

        var prefab = prefabs.get(name);

        if (prefab == null) return ret;

        if (has_prefab(prefab.base))
        {
            ret = instantiate(prefab.base);
        }
        else
        {
            ret = Type.createInstance(Entity, []);
        }

        if (ret == null) return ret;

        for (comp in prefab.components)
        {
            var component = instantiate_component(comp);

            if (component == null) return null;

            ret.add(component);
        }

        apply_properties_with_components(ret, prefab.properties);

        if (prefab.components == null) return ret;

        return ret;
    }

    public function clear()
    {
        var pkeys = prefabs.keys();

        for (pk in pkeys) prefabs.remove(pk);

        var vkeys = var_list.keys();

        for (vk in vkeys)
        {
            var_list.set(vk, null);
            var_list.remove(vk);
        }
    }

    public function reload()
    {
        clear();
        load_from_resource(res);
    }

    public function has_prefab(name: String) : Bool
    {
        return prefabs.exists(name);
    }
}
