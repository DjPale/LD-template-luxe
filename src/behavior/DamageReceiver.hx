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
    public var invulnerable : Bool = false;

    var dmg_msg : String;
    var sound_player : SoundPlayer;

    public function new(_sound_player: SoundPlayer, ?_options: luxe.options.ComponentOptions)
    {
        super(_options);

        sound_player = _sound_player;
    }

    override function init()
    {
        dmg_msg = entity.events.listen(DamageDealer.message, ondamaged);
    }

    public function heal()
    {
        hitpoints = max_hitpoints;
    }

    public function deal(source: Entity, dmg: Int)
    {
        if (entity.name == 'player') {
            sound_player.play('impact');
        }

        trace('$dmg damage from ${source.name} invuln=$invulnerable');

        if (invulnerable) return;

        hitpoints -= dmg;

        if (hitpoints <= 0)
        {
            hitpoints = 0;
            entity.events.fire(message, entity);
        }
    }

    function ondamaged(e: DamageDealerParams)
    {
        deal(e.source.entity, e.source.damage);
    }

    override function ondestroy()
    {
        entity.events.unlisten(dmg_msg);
    }
}
