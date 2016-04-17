import luxe.States;
import luxe.Text;
import luxe.Vector;
import luxe.Input;
import luxe.Sprite;

import phoenix.Texture;

import luxe.tween.Actuate;

import Main;

class MenuState extends State
{
    var global : GlobalData;
    var batcher : phoenix.Batcher;

    var txt1 : Text;
    var txt2 : Text;

    var input_disable : Bool = false;

    public function new(_global:GlobalData, _batcher:phoenix.Batcher)
    {
        super({ name: 'MenuState' });

        global = _global;
        batcher = _batcher;
    }

    override function onenter<T>(ignored:T)
    {
        trace('enter state ' + this.name);

        setup();
    }

    override function onleave<T>(ignored:T)
    {
        trace('leave state ' + this.name);

        cleanup();
    }

    override function onkeydown(event: KeyEvent)
    {
        if (input_disable) return;

        if (event.keycode == Key.space)
        {
            start_game();
        }
    }

    function start_game()
    {
        input_disable = true;
        Actuate.stop(txt2.color);
        txt2.color.a = 0;
        Actuate.tween(txt2.color, 0.2, { a: 1 }).repeat(5).reflect().onComplete(fade_out);
    }

    function cleanup()
    {
        Actuate.stop(txt1.color);
        Actuate.stop(txt2.color);

        txt1.destroy();
        txt2.destroy();
    }

    function fade_out(_)
    {
        txt2.color.a = 0;
        txt1.color.a = 1;
        Actuate.tween(txt1.color, 1, { a: 0 }).onComplete(function(_) { global.states.set("MainState"); });
    }

    function ready_steady(_)
    {
        Actuate.tween(txt2.color, 0.5, { a: 1 }).repeat().reflect();

        input_disable = false;
    }

    function setup()
    {
        txt1 = new Text({
            name: 'Title',
            font: global.font,
            text: 'SPACE SHIFT',
            sdf: false,
            align : TextAlign.center,
            align_vertical : TextAlign.center,
            point_size: 24,
            pos: new Vector(Luxe.camera.size.x / 2, 100)
        });

        txt1.color.a = 0;

        txt2 = new Text({
            name: 'Title',
            font: global.font,
            text: 'SPACE TO START',
            sdf: false,
            align : TextAlign.center,
            align_vertical : TextAlign.center,
            point_size: 8,
            pos: new Vector(Luxe.camera.size.x / 2, 250)
        });

        txt2.color.a = 0;

        Actuate.tween(txt1.color, 2, { a: 1 }).onComplete(ready_steady);
    }
}
