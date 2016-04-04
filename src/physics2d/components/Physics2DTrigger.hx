
package physics2d.components;

import physics2d.PhysicsEngine2D;

import luxe.Entity;
import luxe.Vector;

import luxe.collision.shapes.Shape;
import luxe.collision.data.ShapeCollision;

typedef Physics2DTriggerParams = {
    trigger: Physics2DRigidBody,
    target: Physics2DRigidBody,
    parameters: String
};

class Physics2DTrigger extends luxe.Component
{
    var physics : PhysicsEngine2D;
    var shape : Shape;

    public var body : Physics2DRigidBody;
    public var message : String;
    public var parameters : String;
    public var once : Bool;
    public var message2 : String;
    public var parameters2 : String;

    var has_triggered : Bool;

    public function new(_physics: PhysicsEngine2D, _shape: Shape, ?_options: luxe.options.ComponentOptions = null)
    {
        if (_options == null)
        {
            _options = {};
        }

        if (_options.name == null || _options.name == '')
        {
            _options.name = 'Physics2DTrigger';
        }

        super(_options);

        physics = _physics;
        shape = _shape;
    }

    override public function init()
    {
        body = physics.add_trigger(shape);
        body.ontrigger = ontrigger;
    }

    override public function update(dt: Float)
    {
        if (body != null && body.collider != null) this.pos.copy_from(body.collider.position);
    }

    override public function onremoved()
    {
        physics.remove_body(body);
    }

    public function ontrigger(target: Physics2DRigidBody)
    {
        if (once && has_triggered) return;

        has_triggered = true;

        if (message != null && message.length > 0)
        {
            fire_event(message, {trigger: this.body, target: target, parameters: parameters});
        }

        if (message2 != null && message2.length > 0)
        {
            fire_event(message2, {trigger: this.body, target: target, parameters: parameters2});
        }
    }

    // added function to improve type safety check on parameter since it is dynamic for luxe events
    inline function fire_event(msg: String, e: Physics2DTriggerParams)
    {
        Luxe.events.fire(msg, e);
    }
}
