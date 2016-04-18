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

    var txt_logo : Text;
    var txt_start : Text;
    var txt_credits : Text;

    var input_disable : Bool = false;
    var sound_player : SoundPlayer;

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
        Actuate.stop(txt_start.color);
        txt_start.color.a = 0;
        Actuate.tween(txt_start.color, 0.5, { a: 1 }).reflect().onComplete(fade_out);
    }

    function cleanup()
    {
        Actuate.stop(txt_logo.color);
        Actuate.stop(txt_start.color);
        Actuate.stop(txt_credits.color);

        txt_logo.destroy();
        txt_start.destroy();
        txt_credits.destroy();
    }

    function fade_out(_)
    {
        txt_start.color.a = 0;
        txt_logo.color.a = 1;
        Actuate.tween(txt_credits.color, 1, { a: 0 });
        Actuate.tween(txt_logo.color, 1, { a: 0 }).onComplete(function(_) { global.states.set("MainState"); });
    }

    function ready_steady(_)
    {
        Actuate.tween(txt_credits.color, 0.5, { a: 1 }).reflect();
        Actuate.tween(txt_start.color, 0.5, { a: 1 }).reflect();

        input_disable = false;
    }

    function setup()
    {
        sound_player = new SoundPlayer();

        sound_player.play_music();

        input_disable = true;

        txt_logo = new Text({
            name: 'Logo',
            font: global.font,
            text: 'SPACE SHIFT',
            sdf: false,
            align : TextAlign.center,
            align_vertical : TextAlign.center,
            point_size: 24,
            pos: new Vector(Luxe.camera.size.x / 2, -100)
        });

        txt_credits = new Text({
            name: 'Credits',
            font: global.font,
            text: 'DIGITAL APATHY\nCODE - DJ_PALE\nGFX AND ASS.CODE - PLINK\nMUSIC - SKURK',
            sdf: false,
            align : TextAlign.center,
            align_vertical : TextAlign.center,
            point_size: 8,
            pos: new Vector(Luxe.camera.size.x / 2, 300)
        });
        txt_credits.color.a = 0;

        txt_start = new Text({
            name: 'Title',
            font: global.font,
            text: 'SPACE TO START',
            sdf: false,
            align : TextAlign.center,
            align_vertical : TextAlign.center,
            point_size: 10,
            pos: new Vector(Luxe.camera.size.x / 2, 200)
        });
        txt_start.color.a = 0;

        Actuate.tween(txt_logo.pos, 0.5, { x: Luxe.camera.size.x / 2, y: 100 }).onComplete(ready_steady);
    }
}
