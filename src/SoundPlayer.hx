import luxe.resource.Resource.AudioResource;
import luxe.Audio;

class SoundPlayer {
    var sfx_blaster: AudioResource;
    var sfx_impact: AudioResource;
    var sfx_transform: AudioResource;
    var sfx_enemy_explodes: AudioResource;
    var sfx_player_explodes: AudioResource;
    var sfx_music: AudioResource;
    var master_volume_modifier: Float = 0.25;

    public function new() {
        sfx_blaster = Luxe.resources.audio('assets/sfx/blaster.wav');
        sfx_impact = Luxe.resources.audio('assets/sfx/impact.wav');
        sfx_transform = Luxe.resources.audio('assets/sfx/transform.wav');
        sfx_enemy_explodes = Luxe.resources.audio('assets/sfx/enemy_explodes.wav');
        sfx_player_explodes = Luxe.resources.audio('assets/sfx/player_explodes.wav');
        sfx_music = Luxe.resources.audio('assets/sfx/music.mp3');
    }

    public function play_music() {
        Luxe.audio.loop(sfx_music.source, master_volume_modifier);
    }

    public function play(id: String, ?volume: Float) {

        if (volume == null) {
            volume = 1.0;
        }

        volume *= master_volume_modifier;

        var pitch = Luxe.utils.random.float(0.7, 1.0);

        var src : luxe.AudioSource = null;
        switch (id) {
            case 'blaster': src = sfx_blaster.source;
            case 'impact': src = sfx_impact.source;
            case 'transform': src = sfx_transform.source;
            case 'enemy_explodes': src = sfx_enemy_explodes.source;
            case 'player_explodes': src = sfx_player_explodes.source;
        }

        var handle = Luxe.audio.play(src, volume);
        Luxe.audio.pitch(handle, pitch);
    }

}
