
package physics2d.components;

import physics2d.PhysicsEngine2D;

import luxe.Vector;
import luxe.utils.Maths;

class Physics2DBody extends luxe.Component
{
    var physics : PhysicsEngine2D;

    public var body : Physics2DRigidBody;
    public var move_speed : Vector = new Vector(200.0, 100.0);

    public var jump_times : Int = 1;
    public var jump_pause : Float = 0.05;

    // this is to help the debugger TBH - for some reason shape.position won't play nice
    public var proxy_pos(get,set) : Vector;

    public var was_airborne(default,null) : Bool = true;

    var jump_counter : Int = 0;
    var jump_timer : Float = 0;

    public function new(_physics: PhysicsEngine2D, ?_options: luxe.options.ComponentOptions = null)
    {
        if (_options == null)
        {
            _options = {};
        }

        if (_options.name == null || _options.name == '')
        {
            _options.name = 'Physics2DBody';
        }

        super(_options);

        body = new Physics2DRigidBody();
        physics = _physics;
    }

    override public function init()
    {
        physics.add_body(body);
    }

    override public function update(dt: Float)
    {
        if (body != null && body.collider != null) this.pos.copy_from(body.collider.position);

        check_state(dt);
    }

    override public function onremoved()
    {
        physics.remove_body(body);
    }

    function check_state(dt: Float)
    {
        // between-jump delay timer
        if (jump_timer > 0)
        {
            jump_timer -= dt;
        }

        // simply check collision y + 1 ("under feet")
        var on_ground = physics.check_static_collision(body, 0, 1);

        if (on_ground)
        {
            // reset jump counter whenever we are touching ground
            jump_counter = jump_times;

            // also add delay when landing
            if (was_airborne)
            {
                jump_timer = jump_pause;
            }
        }

        was_airborne = !on_ground;
    }

    public function set_proxy_pos(v:Vector) : Vector
    {
        body.collider.position = v;
        return entity.pos;
    }

    public function get_proxy_pos() : Vector
    {
        return entity.pos;
    }

    public function move(x: Float, y: Float)
    {
        body.apply_velocity(Maths.sign0(x) * move_speed.x, Maths.sign0(y) * move_speed.y);
    }

    public function move_x(x: Float)
    {
        body.add.x = Maths.sign0(x) * move_speed.x;
    }

    public function jump()
    {
        // exit immediately if we cannot jump
        if (jump_counter == 0 || jump_timer > 0) return;

        // reset speed to gain same jump height - or else it will be affected by where you are in the jump
        if (was_airborne)
        {
            body.velocity.y = 0;
        }

        body.add.y = -move_speed.y;

        jump_counter--;
        // small delay before we can jump again mid-air as well
        jump_timer = jump_pause;
    }

    public function set_platformer_configuration(_move_speed: Float, height_maxjump: Float, height_time: Float, ?_damp_factor:Float = 0, ?_jump_times: Int = 1, ?_setgravity: Bool = false)
    {
        move_speed.x = _move_speed;
        set_jump_equation(height_maxjump, height_time, _setgravity);
        jump_times = _jump_times;
        body.damp.x = _damp_factor;
        body.damp.y = 0.997;
        jump_counter = jump_times;
        jump_timer = 0;
    }

    public function set_topdown_configuration(_move_speed: Float, ?_damp_factor: Float = 0.997, ?_setgravity: Bool = false)
    {
        if (_setgravity)
        {
            physics.gravity.set_xy(0, 0);
        }

        move_speed.x = _move_speed;
        move_speed.y = _move_speed;

        body.damp.x = _damp_factor;
        body.damp.y = _damp_factor;

        jump_times = 0;
    }

    // from http://error454.com/2013/10/23/platformer-physics-101-and-the-3-fundamental-equations-of-platformers/
    public function set_jump_equation(height_maxjump: Float, height_time: Float, ?_setgravity: Bool = false)
    {
        if (_setgravity)
        {
            physics.gravity.y = (2 * height_maxjump) / (height_time * height_time);
        }

        move_speed.y = Math.sqrt(2 * physics.gravity.y * height_maxjump);

        trace("jump_equation: g=" + physics.gravity.y + " y=" + move_speed.y);
    }
}
