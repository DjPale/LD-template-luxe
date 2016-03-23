package physics2d;

import luxe.Vector;

import luxe.collision.shapes.Shape;
import luxe.collision.data.ShapeCollision;

typedef Physics2DCollisionCallback = Physics2DRigidBody -> ShapeCollision -> Void;

class Physics2DRigidBody
{
    public var collider : Shape = null;
    public var collides_body : Bool = false;
    public var is_trigger : Bool = false;
    public var velocity : Vector = new Vector();
    public var damp : Vector = new Vector(0.0, 0.997);
    public var oncollision : Physics2DCollisionCallback;

    public var add : Vector = new Vector();

    public function new()
    {
    }

    public function apply_velocity(x: Float, y: Float)
    {
        add.x = x;
        add.y = y;
    }
}
