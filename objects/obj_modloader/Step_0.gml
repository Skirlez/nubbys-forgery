if reroll_cheats_enabled() {
	var obj = agi("obj_ItemMGMT");
	if instance_exists(obj) {
		obj.BaseRerolls = 999	
	}
}
if is_console_and_devmode_enabled() {
	if keyboard_check_pressed(ord("R")) {
		read_all_mods()	
	}
}
