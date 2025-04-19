function append_mod_translations() {
	// Assuming English language for now
	
	// global.Translations is a ds_map, mapping keys to rows on the csv
	// global.LocData is the base game csv ds_grid
	
	for (var i = 0; i < array_length(global.mods); i++) {
		var wod = global.mods[i];
		if !ds_map_exists(wod.translations, "en")
			continue;
		var mod_loc_data = ds_map_find_value(wod.translations, "en")
		// TODO error handling if the mod csv isn't two values per row. Check here and log
		
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

