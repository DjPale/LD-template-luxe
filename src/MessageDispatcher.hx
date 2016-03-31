import luxe.Entity;
import luxe.Vector;

import util.DebugWatcher;

import luxe.importers.tiled.TiledMap;

import physics2d.components.Physics2DTrigger;

typedef TriggerParams = Physics2DTriggerParams;

class MessageDispatcher
{
    var events : Array<String>;
    var map : TiledMap;

    public function new(_map: TiledMap)
    {
        events = [];
        map = _map;
    }

    public function register_triggers()
    {
        events.push(Luxe.events.listen('Teleport', teleport));
        events.push(Luxe.events.listen('Sfx', sfx));
    }

    public function unregister_triggers()
    {
        while (events.length > 0)
        {
            Luxe.events.unlisten(events.pop());
        }
    }

    public function teleport(e: TriggerParams)
    {
        var vec = new Vector();
        DebugWatcher.str_to_vec(e.parameters, vec);
        vec.x *= map.tile_width * map.visual.options.scale;
        vec.y *= map.tile_height * map.visual.options.scale;
        e.target.collider.position.copy_from(vec);
    }

    public function sfx(e: TriggerParams)
    {
        //Luxe.audio.play();
    }
}
