import luxe.States;
import luxe.Text;
import luxe.Vector;
import luxe.Input;
import luxe.Sprite;

import phoenix.Texture;

import Main;

class MenuState extends State
{
    var global : GlobalData;
    var batcher : phoenix.Batcher;

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

    override public function onenabled<T>(ignored:T)
    {
        trace('enable state ' + this.name);
    }

    override public function ondisabled<T>(ignored:T)
    {
        trace('disable state ' + this.name);
    }

    function setup()
    {

    }
}
