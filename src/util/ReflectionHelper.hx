package util;

class ReflectionHelper
{
    private function new()
    {
    }

    public static function set_property(obj: Dynamic, name: String, val: Dynamic)
    {
        Reflect.setProperty(obj, name.toLowerCase(), val);
    }

    public static function set_deep_property(obj: Dynamic, name: String, val: Dynamic)
    {
        var dot = name.indexOf(".");
        if (dot == -1)
        {
            set_property(obj, name, val);
        }
        else
        {
            set_deep_property(Reflect.field(obj, name.substr(0, dot)), name.substr(dot + 1), val);
        }
    }

    public static function apply_properties(obj: Dynamic, props: Map<String,String>)
    {
        if (props == null) return;

        for (p in props.keys())
        {
            set_deep_property(obj, p, props[p]);
        }
    }

    public static function json_to_properties(props: Dynamic) : Map<String,String>
    {
        var ret  = null;

        var fields = Reflect.fields(props);
        if (fields == null || fields.length == 0) return ret;
        ret = new Map<String,String>();

        for (f in fields)
        {
            ret.set(f, Reflect.field(props, f));
        }

        return ret;
    }

    public static function try_instantiate<T>(name: String) : T
    {
        var cl = Type.resolveClass(name);

        if (cl == null) return null;

        var ret : T = cast Type.createInstance(cl, []);
        return ret;
    }
}
