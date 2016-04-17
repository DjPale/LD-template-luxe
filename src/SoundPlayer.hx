import luxe.resource.Resource.AudioResource;
import luxe.Audio;

class SoundPlayer {
    var blaster: AudioResource;
    var impact: AudioResource;
    var master_volume_modifier: Float = 0.5;

    public function new() {

        var load = snow.api.Promise.all([
            Luxe.resources.load_audio('assets/sfx/blaster.wav'),
            Luxe.resources.load_audio('assets/sfx/impact.wav'),
            // Luxe.resources.load_audio('assets/ambience.ogg')
        ]);

        load.then(function(_) {
            blaster = Luxe.resources.audio('assets/sfx/blaster.wav');
            impact = Luxe.resources.audio('assets/sfx/impact.wav');
        });
    }


    public function play(id: String, ?volume: Float) {

        if (volume == null) {
            volume = 1.0;
        }

        volume *= master_volume_modifier;

        var pitch = Luxe.utils.random.float(0.7, 1.0);

        var src : luxe.AudioSource = null;
        switch (id) {
            case 'blaster': src = blaster.source;
            case 'impact': src = impact.source;
        }

        var handle = Luxe.audio.play(src, volume);
        Luxe.audio.pitch(handle, pitch);
    }

}
