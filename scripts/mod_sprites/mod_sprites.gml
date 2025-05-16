function mod_register_sprite(sprite, name, wod = global.currently_executing_mod) {
	if sprite == -1 {
		log_error($"Mod {wod.mod_id} attempted to register invalid (-1) sprite with name {name}." 
		 + " Check if you are importing the sprite correctly.")
		return;
	}
	ds_map_set(wod.sprites, name, sprite);
}
function mod_get_sprite(name, wod = global.currently_executing_mod) {
	if !ds_map_exists(wod.sprites, name) {
		log_error($"Non-existent sprite {name} requested from mod {wod.mod_id}. Returning spr_empty")
		return agi("spr_empty");
	}
	return ds_map_find_value(wod.sprites, name)
}