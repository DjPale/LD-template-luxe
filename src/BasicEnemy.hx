import luxe.Component;

import behavior.DamageReceiver;

class BasicEnemy extends Component
{
    var dead_msg : String;

    public function new(?_options: luxe.options.ComponentOptions)
    {
        super(_options);
    }

    override function init()
    {
        dead_msg = entity.events.listen(DamageReceiver.message, ondead);
    }

    override function ondestroy()
    {
        entity.events.unlisten(dead_msg);
    }

    function ondead(_)
    {
        entity.destroy();
    }
}
