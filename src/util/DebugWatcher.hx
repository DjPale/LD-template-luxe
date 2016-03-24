package util;

import luxe.Vector;

typedef FormatCallback = Dynamic -> String;
typedef UpdateCallback = String -> Void;
typedef SetterCallback = String -> Dynamic;

typedef WatchedValue = {
    object: Dynamic,
    field: String,
    rate: Float,
    counter: Float,
    update: UpdateCallback,
    format: FormatCallback,
    setter: SetterCallback
};


class DebugWatcher
{
    var polled_values : Array<WatchedValue>;

    public function new()
    {
        polled_values = [];
    }

    public function register_watch(_object: Dynamic, _field: String, _update: UpdateCallback, ?_rate: Float = 1.0, ?_format: FormatCallback = null, ?_setter: SetterCallback = null) : WatchedValue
    {
        var ret = {
            object: _object,
            field: _field,
            rate: _rate,
            counter: 9999.0, // force update at once
            update: _update,
            format: _format,
            setter: _setter
        };

        polled_values.push(ret);

        return ret;
    }

    public function set_watch(watch_item: WatchedValue, v: String)
    {
        var d : Dynamic = v;

        if (watch_item.setter != null)
        {
            d = watch_item.setter(v);
        }

        Reflect.setProperty(watch_item.object, watch_item.field, d);
    }

    public function update(dt:Float)
    {
        for (pv in polled_values)
        {
            pv.counter += dt;
            if (pv.counter > pv.rate)
            {
                var v = Reflect.getProperty(pv.object, pv.field);
                var str;
                if (pv.format != null)
                {
                    str = pv.format(v);
                }
                else
                {
                    str = Std.string(v);
                }

                pv.update(str);

                pv.counter = 0;
            }
        }
    }

    public static function fmt_vec2d(v: Dynamic) : String
    {
        var v : Vector = cast v;

        if (v == null) return '<null>';

        return Math.round(v.x) + ',' + Math.round(v.y);
    }

    public static function fmt_vec2d_f(v: Dynamic) : String
    {
        var v : Vector = cast v;

        if (v == null) return '<null>';

        return v.x + ',' + v.y;
    }

    public static function str_to_vec(str: String, vec: Vector) : Vector
    {
        var ary = str.split(',');

        if (ary.length >= 1)
        {
            vec.x = Std.parseFloat(ary[0]);
        }
        if (ary.length >= 2)
        {
            vec.y = Std.parseFloat(ary[1]);
        }
        if (ary.length >= 3)
        {
            vec.z = Std.parseFloat(ary[2]);
        }
        if (ary.length >= 4)
        {
            vec.w = Std.parseFloat(ary[3]);
        }

        return vec;
    }

    public static function set_vec2d(v: String) : Vector
    {
        return str_to_vec(v, new Vector());
    }

    public static function set_int(v: String) : Int
    {
        return Std.parseInt(v);
    }

    public static function set_float(v: String) : Float
    {
        return Std.parseFloat(v);
    }

    public static function set_bool(v: String) : Bool
    {
        return (v == 'true');
    }
}
