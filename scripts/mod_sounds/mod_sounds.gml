function mod_register_sound(sound, name, wod = global.currently_executing_mod) {
	if sound == -1 {
		log_error($"Mod {wod.mod_id} attempted to register invalid (-1) sound with name {name}." 
		 + " Check if you are importing the sound correctly.")
		return;
	}
	ds_map_set(wod.sounds, name, sound);
}
function mod_get_sound(name, wod = global.currently_executing_mod) {
	if !ds_map_exists(wod.sounds, name) {
		log_error($"Non-existent sound {name} requested from mod {wod.mod_id}. Returning snd_silence")
		return agi("snd_silence");
	}
	return ds_map_find_value(wod.sounds, name)
}


