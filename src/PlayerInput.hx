import luxe.Input;

import physics2d.Physics2DBody;

class PlayerInput extends luxe.Component
{
    var phys : Physics2DBody;

    public function new(_phys: Physics2DBody, ?_options: luxe.options.ComponentOptions)
    {
        super(_options);

        phys = _phys;
    }

    override function init()
    {
        Luxe.input.bind_key("left", Key.left);
        Luxe.input.bind_key("right", Key.right);
        Luxe.input.bind_key("up", Key.up);
        Luxe.input.bind_key("down", Key.down);
    }

    override public function update(dt: Float)
    {
        handle_input();
    }

    function handle_input()
    {
        var x = 0;
        var y = 0;

        if (Luxe.input.inputdown("left"))
        {
            x = -1;
        }
        else if (Luxe.input.inputdown("right"))
        {
            x = 1;
        }

        if (phys.jump_times <= 0)
        {
            if (Luxe.input.inputdown("up"))
            {
                y = -1;
            }
            else if (Luxe.input.inputdown("down"))
            {
                y = 1;
            }

            phys.move(x, y);
        }
        else
        {
            if (Luxe.input.inputpressed("up"))
            {
                phys.jump();
            }

            phys.move_x(x);
        }

    }
}
