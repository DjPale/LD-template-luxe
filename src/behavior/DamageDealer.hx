package behavior;

import luxe.Entity;
import luxe.Component;

import physics2d.components.Physics2DBody;

typedef DamageDealerParams = {
    source: DamageDealer,
};

class DamageDealer extends Component
{
    public static var message : String = "DamageDealer.damage";

    public var damage : Int = 1;

    public var destroy_on_impact : Bool = false;

    var col_msg : String;

    public function new(?_options: luxe.options.ComponentOptions)
    {
        super(_options);

    }

    override function init()
    {
        col_msg = entity.events.listen(Physics2DBody.message, onimpact);
    }

    function onimpact(e: Physics2DBodyCollisionParams)
    {
        if (e.target == null) return;

        fire_event(message, e.target, { source: this });

        if (destroy_on_impact && entity != null && !entity.destroyed) entity.destroy();
    }

    function fire_event(msg: String, tgt: Entity, params: DamageDealerParams)
    {
        trace('giving $damage damage to ${tgt.name}');

        tgt.events.fire(msg, params);
    }

    override function ondestroy()
    {
        entity.events.unlisten(col_msg);
    }
}
