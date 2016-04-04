package util;

import luxe.Entity;

import luxe.resource.Resource;

typedef PrefabComponent = {
    name: String,
    constructor: Array<String>,
    properties: Map<String,String>
}

typedef Prefab = {
    name: String,
    base: String,
    properties: Map<String, Map<String,String>>,
    components: Array<PrefabComponent>
};

class PrefabManager
{
    var res : JSONResource;

    var prefabs : Map<String,Prefab>;
    var var_list : Map<String,Dynamic>;

    static var ROOT : String = "root";

    public function new()
    {
        prefabs = new Map<String,Prefab>();
        var_list = new Map<String,Dynamic>();
    }

    public function register_var(name: String, obj: Dynamic)
    {
        var_list.set(name, obj);
    }

    public function load_from_resouce(_res: JSONResource)
    {
        var json = _res.asset.json;
        var it_prefabs : Array<Dynamic> = json.prefabs;

        for (prefab in it_prefabs)
        {
            var p : Prefab = { name: prefab.name, base: prefab.base, properties: null, components: null };
            prefabs.set(p.name, p);

            p.properties = get_properties_with_components(prefab.properties);

            var components : Array<Dynamic> = prefab.components;
            if (components == null || components.length == 0) continue;

            p.components = new Array<PrefabComponent>();

            for (c in components)
            {
                var comp : PrefabComponent = { name: c.name, constructor: c.constructor, properties: null };
                comp.properties = ReflectionHelper.json_to_properties(c.properties);
                p.components.push(comp);
            }
        }
    }

    function get_properties_with_components(props: Dynamic) : Map<String,Map<String,String>>
    {
        var ret = null;

        if (props == null) return ret;

        var tmp_props = ReflectionHelper.json_to_properties(props);

        if (tmp_props == null) return ret;

        ret = new Map<String,Map<String,String>>();

        for (k in tmp_props.keys())
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
            ret[comp_id].set(comp_key, tmp_props[k]);
        }

        return ret;
    }

    function apply_properties_with_components(entity: Entity, props: Map<String,Map<String,String>>)
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
                if (comp != null)
                {
                    ReflectionHelper.apply_properties(comp, props[k]);
                }
            }
        }
    }

    function build_constructor(clist: Array<String>) : Array<Dynamic>
    {
        var ret = [];

        if (clist == null || clist.length == 0) return ret;

        for (a in clist)
        {
            ret.push(var_list.get(a));
        }

        return ret;
    }

    public function instantiate(name: String) : Entity
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

        apply_properties_with_components(ret, prefab.properties);

        if (prefab.components == null) return ret;

        for (comp in prefab.components)
        {
            var cl = Type.resolveClass(comp.name);
            var constr = build_constructor(comp.constructor);
            var component = Type.createInstance(cl, constr);

            if (component == null) return null;

            ReflectionHelper.apply_properties(component, comp.properties);

            ret.add(component);
        }

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
        load_from_resouce(res);
    }

    public function has_prefab(name: String) : Bool
    {
        return prefabs.exists(name);
    }
}
