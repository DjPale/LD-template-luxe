package behavior;

import luxe.Entity;
import luxe.Component;

import physics2d.components.Physics2DBody;
import behavior.DamageDealer;

class DamageReceiver extends Component
{
    public static var message : String = "DamageReceiver.dead";

    public var max_hitpoints : Int = 1;
    public var hitpoints : Int = 1;

    var dmg_msg : String;

    public function new(?_options: luxe.options.ComponentOptions)
    {
        super(_options);
    }

    override function init()
    {
        dmg_msg = entity.events.listen(DamageDealer.message, ondamaged);
    }

    public function heal()
    {
        hitpoints = max_hitpoints;
    }

    function ondamaged(e: DamageDealerParams)
    {
        trace('damage from ${e.source.entity.name}');

        hitpoints -= e.source.damage;

        if (hitpoints <= 0)
        {
            hitpoints = 0;
            entity.events.fire(message);
        }
    }

    override function ondestroy()
    {
        entity.events.unlisten(dmg_msg);
    }
}
