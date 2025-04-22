function load_mod_translations(wod) {
	var translation_folder = strip_initial_path_separator_character(wod.translations_path);
	// we're gonna assume there's only 1 .csv for now
	var trans_dir = $"{global.mods_directory}/{wod.folder_name}/{translation_folder}";
	//var csv_files = get_all_files(trans_dir, "csv")
	/*for (var i = 0; i < array_length(item_files); i++)*/ {
		var file_path = trans_dir + "/en.csv";
		var translation = load_csv(file_path)
		ds_map_add(wod.translations, "en", translation)
	}	
}

function append_mod_translations() {
	// Assuming English language for now
	
	// global.Translations is a ds_map, mapping keys to rows on the csv
	// global.LocData is the base game csv ds_grid
	var mods = ds_map_values_to_array(global.mod_id_to_mod_map)
	for (var i = 0; i < array_length(mods); i++) {
		var wod = mods[i];
		if !ds_map_exists(wod.translations, "en")
			continue;
		var mod_loc_data = ds_map_find_value(wod.translations, "en")
		// TODO error handling if the mod csv isn't two values per row. Check here and log
		// Also disallow semicolon in key name
		var h = ds_grid_height(global.LocData)
		ds_grid_resize(global.LocData, 
			ds_grid_width(global.LocData), 
			h + ds_grid_height(mod_loc_data))
			
		for (var i = 0; i < ds_grid_height(mod_loc_data); i++) {
			var key = ds_grid_get(mod_loc_data, 0, i);
			var line = h + i;
			ds_map_set(global.Translations, key, line)
			ds_grid_set(global.LocData, 0, line, key)
			ds_grid_set(global.LocData, 1, line, ds_grid_get(mod_loc_data, 1, i))
		}
		
			
	}
}

