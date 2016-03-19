import luxe.Input;
import luxe.States;
import luxe.Vector;

import mint.Canvas;
import mint.render.luxe.LuxeMintRender;


typedef GlobalData = {
    states: States,
    ui: phoenix.Batcher,
    canvas: Canvas
};

class Main extends luxe.Game
{
    var global : GlobalData = { states: null, ui: null, canvas: null };

    override function config(config:luxe.AppConfig) : luxe.AppConfig
    {
        config.preload.jsons.push({id: 'assets/parcel.json'});
        config.render.depth = 24;

        return config;
    }

    function setup()
    {
        global.ui = Luxe.renderer.create_batcher({
            name: 'ui',
            layer: 1
        });

        var renderer = new LuxeMintRender();

        global.canvas = new Canvas({
            name: 'Canvas',
            rendering: renderer,
            x: 0, y: 0, w: Luxe.screen.w, h: Luxe.screen.h
        });

        // Set up batchers, states etc.
        global.states = new States({ name: 'states' });
        global.states.add(new MainState(global, Luxe.renderer.batcher));
        global.states.set('MainState');

        trace(Luxe.screen.size);
    }

    function load_complete(_)
    {
        setup();
    }

    override function ready()
    {
        var preload = new luxe.Parcel();
        preload.from_json(Luxe.resources.json('assets/parcel.json').asset.json);

        new luxe.ParcelProgress({
          parcel: preload,
          oncomplete: load_complete
        });

        preload.load();
    } //ready

    override function onkeyup( e:KeyEvent )
    {
        if (e.keycode == Key.escape)
        {
            Luxe.shutdown();
        }
    } //onkeyup

    override function update(dt:Float)
    {
    } //update

} //Main
