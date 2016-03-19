
package util;

import mint.Canvas;
import mint.Window;
import mint.Label;

typedef PolledValueCallback = Dynamic -> String;

typedef PolledValue = {
    name: Label,
    object: Dynamic,
    field: String,
    label: Label,
    rate: Float,
    counter: Float,
    callback: PolledValueCallback
};

class DebugWindow
{
    var canvas : Canvas;
    var window : Window;

    var polled_values : Array<PolledValue>;

    public function new(_canvas: Canvas, _x: Float, _y: Float, _w: Float, _h: Float)
    {
        canvas = _canvas;

        window = new Window({
            name: 'DebugWindow',
            parent: canvas,
            x: _x, y: _y,
            w: _w, h: _h
        });

        polled_values = [];

        Luxe.on(luxe.Ev.update, update);
    }

    public function update(dt:Float)
    {
        for (pv in polled_values)
        {
            pv.counter += dt;
            if (pv.counter > pv.rate)
            {
                var v = Reflect.getProperty(pv.object, pv.field);
                if (pv.callback != null)
                {
                    pv.label.text = pv.callback(v);
                }
                else
                {
                    pv.label.text = Std.string(v);
                }

                pv.counter = 0;
            }
        }
    }

    public function register_watch(_name: String, _object: Dynamic, _field: String, ?_rate: Float = 1.0, ?_callback: PolledValueCallback = null)
    {
        var name_label = new Label({
            parent: window,
            text: _name,
            x: 0, y: 10
        });

        var value_label = new Label({
            parent: window,
            text: '<unknown>',
            x: 50, y: 10
        });

        polled_values.push({
            name: name_label,
            label: value_label,
            object: _object,
            field: _field,
            rate: _rate,
            counter: 0.0,
            callback: _callback
        });
    }
}
