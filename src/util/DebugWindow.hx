
package util;

import mint.Canvas;
import mint.Window;
import mint.Label;
import mint.List;
import mint.Panel;
import mint.layout.margins.Margins;

import util.DebugWatcher;

class DebugWindow extends Window
{
    var list : List;
    var layout : Margins;
    var watcher: DebugWatcher;

    public function new(_watcher: DebugWatcher, _layout: Margins, _options: WindowOptions)
    {
        super(_options);

        layout = _layout;
        watcher = _watcher;

        list = new List({
            name: '${_options.parent.name}-List',
            parent: this,
            x: 4, y: 28, w: _options.parent.w  - 4, h: _options.parent.h - 28 - 4
        });

        layout.margin(list, MarginTarget.right, fixed, 4);
        layout.margin(list, MarginTarget.bottom, fixed, 4);

        setup();
    }

    function setup()
    {
        Luxe.on(luxe.Ev.update, watcher.update);

        ondestroy.listen(cleanup);
    }

    function cleanup()
    {
        Luxe.off(luxe.Ev.update, watcher.update);

        ondestroy.remove(cleanup);
    }

    public function register_watch(_object: Dynamic, _field: String, ?_rate: Float = 1.0, ?_callback: FormatCallback = null)
    {
        var item = create_list_item(_field);

        watcher.register_watch(_object, _field, function(v: String) { trace("tt"); item.text = v; }, _rate, _callback);
    }

    function create_list_item(_name: String) : Label
    {
        var children_count = list.children.length;
        var panel = new Panel({
            name: '${list.name}-$children_count',
            parent: list,
            x: 2, y: 4, w: list.w - 2, h: 24
        });

        layout.margin(panel, MarginTarget.right, fixed, 2);

        var name_label = new Label({
            parent: panel,
            text: _name,
            x: 2, y: 2, w: panel.w / 2 - 2, h: panel.h - 2
        });

        var value_label = new Label({
            parent: panel,
            text: '<unknown>',
            x: panel.w / 2, y: 2, w: panel.w / 2 - 2, h: panel.h - 2
        });

        list.add_item(panel);

        return value_label;
    }


}
