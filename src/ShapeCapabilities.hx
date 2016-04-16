import luxe.Component;

import physics2d.components.Physics2DBody;
import behavior.DamageReceiver;
import behavior.DamageDealer;

typedef ShapeTemplate = {
    attack: Float,
    defense: Float,
    speed: Float
};


class ShapeCapabilities extends Component
{
    public var attack : Float = 1;
    public var defense : Float = 1;
    public var speed : Float = 1;

    public static var templates : Array<ShapeTemplate> = new Array<ShapeTemplate>();

    var base_attack : Int;
    var base_defense : Int;
    var base_speed : Int;

    var _defense : DamageReceiver;
    var _attack : DamageDealer;
    var _speed : Physics2DBody;

    public var current_shape(default,null) : Int;

    public function new(_atk: DamageDealer, _spd: Physics2DBody, _def: DamageReceiver, ?_options: luxe.options.ComponentOptions)
    {
        super(_options);

        _attack = _atk;
        _defense = _def;
        _speed = _spd;

        current_shape = -1;
    }

    function snapshot()
    {
        base_attack = _attack.damage;
        base_defense = _defense.max_hitpoints;
        base_speed = Std.int(_speed.move_speed.x);
    }

    function restore()
    {
        _attack.damage = base_attack;
        _defense.max_hitpoints = base_defense;
        _speed.move_speed.set_xy(base_speed, base_speed);
    }

    public function apply_abilities(num: Int)
    {
        if (num < 0 || num >= templates.length) return;

        restore();

        var tmpl = templates[num];
        current_shape = num;

        _attack.damage = Std.int(_attack.damage * tmpl.attack);
        _defense.max_hitpoints = Std.int(_defense.max_hitpoints * tmpl.defense);
        _defense.heal();
        _speed.move_speed.set_xy(_speed.move_speed.x * tmpl.speed, _speed.move_speed.x * tmpl.speed);
    }

    override function init()
    {
        snapshot();

        apply_abilities(0);
    }

    override function update(dt: Float)
    {
    }
}
