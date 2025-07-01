function mod_get_path(path, warn = true, wod = global.cmod) {
	path = strip_initial_path_separator_character(path);
	var full_path = $"{global.mods_directory}/{wod.folder_name}/{path}";
	
	if warn {
		if string_ends_with(full_path, "/") || string_ends_with(full_path, "\\") {
			if !directory_exists(full_path) {
				log_warn($"Mod {wod.mod_id} requested path {path}, evaluated to {full_path}, but there's no such directory")
			}
		}
		else if !file_exists(full_path) {
			log_warn($"Mod {wod.mod_id} requested path {path}, evaluated to {full_path}, but there's no such file")
		}
	}
	return full_path;
}

function mod_register_function(name, func, wod = global.cmod) {
	// TODO check name and whatnot
	ds_map_set(wod.functions, name, func)
}


function mod_run_delayed(frames, func, wod = global.cmod) {
	agi("obj_modloader").add_to_run_delayed(frames, func, wod)
}