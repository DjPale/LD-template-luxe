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
    properties: Map<String, String>,
    components: Array<PrefabComponent>
};

class PrefabManager
{
    var res : JSONResource;

    var prefabs : Map<String,Prefab>;
    var var_list : Map<String,Dynamic>;

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

            p.properties = ReflectionHelper.json_to_properties(prefab.properties);

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

        ret = Type.createInstance(Entity, []);

        ReflectionHelper.apply_properties(ret, prefab.properties);

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

        trace(ret);

        return ret;
    }


    public function clear()
    {

    }

    public function reload()
    {
        clear();
        load_from_resouce(res);
    }

    public function has_prefab(name: String) : Bool
    {
        return false;
    }

    public function load_prefab(name: String) : Entity
    {
        return null;
    }
}
