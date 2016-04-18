import luxe.Vector;
import luxe.Color;
import luxe.Input;
import luxe.Entity;
import luxe.Particles;
import luxe.Sprite;

import phoenix.Batcher;

class AfterburnerComponent extends luxe.Component {

    var glowing : Batcher;
    var particle_system : Entity;
    public var particles : ParticleSystem;
    var player : Entity;

    override public function init() {

        player = cast entity;
        glowing = Luxe.renderer.create_batcher({ name:'glowing', camera:Luxe.camera.view });

        particles = new ParticleSystem({name:'particles'});
        particles.pos = new Vector(player.pos.x, player.pos.y + 15);
        particles.add_emitter({
            name : 'flames',
            start_color: new Color(1, 1, 1, 1).rgb(0xaaccee),
            pos: new Vector(0,0),
            pos_random: new Vector(0, 0),
            start_size: new Vector(6, 6),
            start_size_random: new Vector(0, 0),
            end_size: new Vector(0, 0),
            gravity : new Vector(0, 90),
            life: 0.9,
            depth: 2,
            batcher: glowing,
            emit_time: 0.05
        });

        particles.add_emitter({
            name : 'white flames',
            start_color: new Color(1, 1, 1, 1),
            pos: new Vector(0,0),
            pos_random: new Vector(0, 0),
            start_size: new Vector(2, 2),
            start_size_random: new Vector(0, 0),
            end_size: new Vector(0, 0),
            gravity : new Vector(0, 90),
            life: 0.45,
            depth: 3,
            batcher: glowing,
            emit_time: 0.05
        });

    }

    override function update(dt:Float) {
        particles.pos = new Vector(player.pos.x, player.pos.y + 15);
    }

}
