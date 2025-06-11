if reroll_cheats_enabled() {
	var obj = agi("obj_ItemMGMT");
	if instance_exists(obj) {
		obj.BaseRerolls = 999	
	}
}




if keyboard_check_pressed(ord("R")) && room == agi("Roo_TitleMenu") {
	log_info("R Pressed - Reloading mods")
	clear_all_mods();
	read_all_mods()	
}
if keyboard_check_pressed(ord("H")) {
	log_info("H Pressed - Hot-reloading all code. This probably doesn't do what you think it does right now.")
	hot_reload();
}


