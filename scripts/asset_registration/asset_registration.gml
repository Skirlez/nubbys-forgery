function register_mod_sprite(sprite, mod_id, name) {
	if !ds_map_exists(global.mod_id_to_mod_map, mod_id) {
		log($"Non-existent mod ID {mod_id} provided while registering sprite {name}")
		return;
	}
	var wod = ds_map_find_value(global.mod_id_to_mod_map, mod_id)
	ds_map_set(wod.sprites, name, sprite);
}
function get_mod_sprite(mod_id, name) {
	if !ds_map_exists(global.mod_id_to_mod_map, mod_id) {
		log($"Non-existent mod ID {mod_id} provided while trying to get sprite sprite {name}")
		return noone;
	}
	var wod = ds_map_find_value(global.mod_id_to_mod_map, mod_id)
	if !ds_map_exists(wod.sprites, name) {
		log($"Non-existent sprite {name} requested from mod {mod_id}")
		return noone;
	}
	return ds_map_find_value(wod.sprites, name)
}