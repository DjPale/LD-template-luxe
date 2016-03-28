package physics2d;

import luxe.Vector;

import luxe.collision.shapes.Shape;
import luxe.collision.data.ShapeCollision;

typedef Physics2DCollisionCallback = Physics2DRigidBody -> ShapeCollision -> Void;
typedef Physics2DTriggerCallback = Physics2DRigidBody -> Void;

class Physics2DRigidBody
{
    public var collider : Shape = null;
    public var enabled : Bool = true;
    public var is_trigger : Bool = false;
    public var velocity : Vector = new Vector();
    public var damp : Vector = new Vector(0.0, 0.997);
    public var oncollision : Physics2DCollisionCallback;
    public var ontrigger : Physics2DTriggerCallback;
    public var layer : Int = PhysicsEngine2D.DEFAULT_LAYER;

    public var add : Vector = new Vector();

    var trigger_list : Map<Physics2DRigidBody,Bool> = null;

    public function new()
    {
    }

    public function apply_velocity(x: Float, y: Float)
    {
        add.x = x;
        add.y = y;
    }

    inline public function set_trigger(tgt: Physics2DRigidBody)
    {
        if (trigger_list == null) trigger_list = new Map<Physics2DRigidBody, Bool>();
        trigger_list.set(tgt, true);
    }

    inline public function had_trigger(tgt: Physics2DRigidBody) : Bool
    {
        return (trigger_list != null && trigger_list.exists(tgt));
    }

    inline public function invalidate_triggers()
    {
        if (trigger_list == null) return;

        for (key in trigger_list.keys())
        {
            trigger_list.set(key, false);
        }
    }

    inline public function purge_inactive_triggers()
    {
        if (trigger_list == null) return;

        for (key in trigger_list.keys())
        {
            if (!trigger_list.get(key)) trigger_list.remove(key);
        }
    }
}
