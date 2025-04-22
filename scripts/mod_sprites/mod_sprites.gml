function register_mod_sprite(sprite, name, wod = global.currently_executing_mod) {
	ds_map_set(wod.sprites, name, sprite);
}
function get_mod_sprite(name, wod = global.currently_executing_mod) {
	if !ds_map_exists(wod.sprites, name) {
		log_error($"Non-existent sprite {name} requested from mod {wod.mod_id}")
		return noone;
	}
	return ds_map_find_value(wod.sprites, name)
}