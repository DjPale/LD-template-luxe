package util;

import luxe.Vector;

typedef FormatCallback = Dynamic -> String;
typedef UpdateCallback = String -> Void;

typedef PolledValue = {
    object: Dynamic,
    field: String,
    rate: Float,
    counter: Float,
    update: UpdateCallback,
    format: FormatCallback,
};


class DebugWatcher
{
    var polled_values : Array<PolledValue>;

    public function new()
    {
        polled_values = [];
    }

    public function register_watch(_object: Dynamic, _field: String, _update: UpdateCallback, ?_rate: Float = 1.0, ?_format: FormatCallback = null)
    {
        polled_values.push({
            object: _object,
            field: _field,
            rate: _rate,
            counter: 0.0,
            update: _update,
            format: _format
        });
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
}
