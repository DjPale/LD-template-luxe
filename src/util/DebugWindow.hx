
package util;

import mint.Canvas;
import mint.Control;
import mint.Window;
import mint.Label;
import mint.List;
import mint.Panel;
import mint.TextEdit;
import mint.layout.margins.Margins;
import mint.types.Types;

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

    public function register_watch(_object: Dynamic, _field: String, ?_rate: Float = 1.0, ?_format: FormatCallback = null, ?_setter: SetterCallback = null)
    {
        var watch_item = watcher.register_watch(
            _object, _field,
            null, // fill in update function when creating list item
            _rate, _format,
            _setter
        );

        // a bit messy - but we need to determine to render a text edit or a label later and create the correct callbacks
        create_list_item(_field, watch_item);
    }

    function create_list_item(_name: String, _watch: WatchedValue)
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

        if (_watch.setter != null)
        {
            var edit = new TextEdit({
                parent: panel,
                text: '<unknown>',
                text_size: 14,
                x: panel.w / 2, y: 2, w: panel.w / 2 - 2, h: panel.h - 2
            });

            _watch.update = function(v:String)
            {
                if (!edit.isfocused && v != edit.text) edit.text = v;
            }

            edit.onkeydown.listen(function(k: KeyEvent, c: Control)
            {
                if (k.key == KeyCode.enter)
                {
                    edit.unfocus();
                    watcher.set_watch(_watch, edit.text);
                }
            });
        }
        else
        {
            var label = new Label({
                parent: panel,
                text: '<unknown>',
                align: TextAlign.left,
                x: panel.w / 2, y: 2, w: panel.w / 2 - 2, h: panel.h - 2
            });

            _watch.update = function(v:String)
            {
                label.text = v;
            };
        }

        list.add_item(panel);
    }
}
