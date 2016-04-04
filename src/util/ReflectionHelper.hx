package util;

class ReflectionHelper
{
    private function new()
    {
    }

    public static function apply_properties(obj: Dynamic, props: Map<String,String>)
    {
        if (props == null) return;

        for (p in props.keys())
        {
            Reflect.setProperty(obj, p.toLowerCase(), props[p]);
        }
    }

    public static function json_to_properties(props : Dynamic) : Map<String,String>
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
}
