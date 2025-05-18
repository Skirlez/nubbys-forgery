if reroll_cheats_enabled() {
	var obj = agi("obj_ItemMGMT");
	if instance_exists(obj) {
		obj.BaseRerolls = 999	
	}
}

if keyboard_check_pressed(ord("R")) {
	log_info("R Pressed - Reloading mods")
	clear_all_mods();
	read_all_mods()	
}
if keyboard_check_pressed(ord("H")) {
	log_info("H Pressed - Hot-reloading all code")
	var mods = ds_map_values_to_array(global.mod_id_to_mod_map)
	for (var i = 0; i < array_length(mods); i++) {
		ds_map_clear(mods[i].code_files)	
	}
}