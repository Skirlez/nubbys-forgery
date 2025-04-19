if is_console_and_devmode_enabled() {
	var obj = agi("obj_ItemMGMT");
	if instance_exists(obj) {
		obj.BaseRerolls = 999	
	}
}