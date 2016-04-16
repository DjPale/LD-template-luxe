import luxe.Input;
import luxe.States;
import luxe.Vector;

import mint.Canvas;
import mint.render.luxe.LuxeMintRender;
import mint.layout.margins.Margins;

typedef GlobalData = {
    states: States,
    ui: phoenix.Batcher,
    canvas: Canvas,
    layout: Margins
};

class Main extends luxe.Game
{
    var global : GlobalData = { states: null, ui: null, canvas: null, layout: null };

    override function config(config:luxe.AppConfig) : luxe.AppConfig
    {
        config.preload.jsons.push({id: 'assets/parcel.json'});
        config.render.depth = 24;

        return config;
    }

    function setup()
    {
        trace(Luxe.screen.size);

        var ratio = Luxe.screen.device_pixel_ratio;
        trace('device ratio = $ratio');

        // if (ratio >= 2)
        // {
        //     var vp_size = Luxe.screen.size.divideScalar(ratio);
        //     Luxe.camera.size = vp_size;
        // }
        // else
        // {
        //     Luxe.camera.size = Luxe.screen.size;
        // }

        Luxe.camera.size = new Vector(300, 400);

        global.ui = Luxe.renderer.create_batcher({
            name: 'ui',
            layer: 3
        });

        setup_canvas();

        // Set up batchers, states etc.
        global.states = new States({ name: 'states' });
        global.states.add(new MainState(global, Luxe.renderer.batcher));
        global.states.set('MainState');

    }

    function setup_canvas()
    {
        var renderer = new LuxeMintRender({
            batcher: global.ui
        });

        var canvas = new util.AutoCanvas({
            name: 'Canvas',
            rendering: renderer,
            x: 0, y: 0, w: Luxe.screen.w, h: Luxe.screen.h
        });

        canvas.auto_listen();

        new mint.focus.Focus(canvas);

        global.canvas = canvas;

        global.layout = new Margins();
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
