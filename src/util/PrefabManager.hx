import luxe.Entity;

import luxe.resource.Resource;

typedef Prefab = {

};

class PrefabManager
{
    var res : JSONResource;

    var prefabs : Map<String,{ Array<>>;

    public function load_from_resouce(var _res: JSONResource)
    {
        var json = res.asset.json;
        for (prefab in json.prefabs)
        {

        }
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
