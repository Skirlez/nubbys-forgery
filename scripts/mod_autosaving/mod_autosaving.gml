// Called after writing the base game save
function save_forgery_autosave(base_save_string) {
	var base_save_hash = sha1_string_utf8(base_save_string)
	
	var maps = {};
	
	for (var resource = 0; resource < mod_resources.size; resource++) {
		var indices = bimap_lefts_array(global.index_registry[resource])
		var entries = array_create(array_length(indices));
		for (var i = 0; i < array_length(indices); i++) {
			entries[i] = {
				index : indices[i],
				string_id : mod_registries_exchange(global.index_registry, global.registry, resource, indices[i])
			}
		}
		maps[$ global.resource_names[resource]] = entries;
	}
	// with items, perks, etc... the map should look something like this:
	/*
	var maps = {
		items : [
			{ index : 174, string_id : "example_mod:whatever"}, {index : 175, "cool_mod:whatever"} ...
		],
		perks : [
			{ index : number, string_id : "example_mod:whatever_perk" } ...
		]
	}
	*/
	var mods_save_data = {};
	var mods = ds_map_values_to_array(global.mod_id_to_mod_map)
	for (var i = 0; i < array_length(mods); i++) {
		var wod = mods[i];
		var mod_save_data = {}
		global.cmod = wod;
		for (var j = 0; j < array_length(wod.autosave_save_callbacks); j++) {
			try {
				execute(wod.autosave_save_callbacks[j], mod_save_data)
			}
			catch (e) {
				log_error($"Mod {wod.mod_id} errored on an autosave-save callback: {e}")	
			}
		}
		mods_save_data[$ wod.mod_id] = mod_save_data;
	}
	var save_struct = { 
		index_mappings : maps,
		base_save_hash : base_save_hash,
		custom : mods_save_data
	};
	var save_string = json_stringify(save_struct);
	var buf = buffer_create(string_byte_length(save_string) + 1, buffer_fixed, 1);
	buffer_write(buf, buffer_string, save_string);
	buffer_save(buf, "NUBBY_AutoSave_F.save.forgery");
	buffer_delete(buf);
}


function mod_register_autosave_save_callback(func, wod = global.cmod) {
	array_push(wod.autosave_save_callbacks, func)
}
function mod_register_autosave_load_callback(func, wod = global.cmod) {
	array_push(wod.autosave_load_callbacks, func)
}

// Called from gml_Object_obj_LoadGameBtn_Create_0
function load_button_is_save_loadable() {
	if (file_exists("NUBBY_AutoSave_F.save") && file_exists("NUBBY_AutoSave_F.save.forgery")) {
		var buf = buffer_load("NUBBY_AutoSave_F.save");
		var load_string = buffer_read(buf, buffer_string);
		buffer_delete(buf);
		
		buf = buffer_load("NUBBY_AutoSave_F.save.forgery");
		var load_forgery = buffer_read(buf, buffer_string);
		buffer_delete(buf);
		var data = json_parse(load_forgery);
		if (data.base_save_hash != sha1_string_utf8(load_string)) {
			log_info("Hash inside forgery autosave does not match autosave, deleting")
			file_delete("NUBBY_AutoSave_F.save.forgery")
			return [];
		}
		
		var missing = [];
		var mods_save_data = data.custom;
		var required_mods = struct_get_names(mods_save_data);
		for (var i = 0; i < array_length(required_mods); i++) {
			if !ds_map_exists(global.mod_id_to_mod_map, required_mods[i])
				array_push(missing, required_mods[i])
		}
		
		
		for (var resource = 0; resource < mod_resources.size; resource++) {
			var entries = data.index_mappings[$ global.resource_names[resource]]
			for (var i = 0; i < array_length(entries); i++) {
				if !mod_registry_left_exists(global.registry, resource, entries[i].string_id) {
					array_push(missing, entries[i].string_id)
				}
			}
		}
		
		if array_length(missing) != 0 {
			log_info($"Some mods are missing in this autosave. Can't safely start it. Missing resources: {missing}")
		}
		else {
			log_info("All modded resources accounted for in autosave")	
		}
		return missing;
	}	
}
// Called from gml_Object_obj_LoadGameBtn_Step_0
function load_button_create_message(missing_resources) {
	return instance_create_depth(x, y, depth - 1, agi("obj_modloader_message"), {
		text : $"This autosave cannot be loaded,\nbecause the following resources are missing:\n{missing_resources}\nPlease delete this autosave, or load those resources."	
	})
}

function parse_autosave_array(str) {
	var arr = string_split(str, ",", true)
	for (var i = 0; i < array_length(arr); i++) {
		arr[i] = real(arr[i])
	}
	return arr;
}
function write_autosave_array(arr) {
	if array_length(arr) == 0
		return "";
	var out = string(arr[0]);
	for (var i = 1; i < array_length(arr); i++) {
		out += $",{arr[i]}"	
	}
	return out;
}


function load_forgery_autosave(base_data) {
	if !file_exists("NUBBY_AutoSave_F.save.forgery") {
		return;
	}
	base_data = base_data[0]; // I don't know why it's wrapped in an array like that
	
	function find_string_id_from_data(data, resource, index) {
		var entries = data.index_mappings[$ global.resource_names[resource]]
		for (var i = 0; i < array_length(entries); i++) {
			if entries[i].index == index
				return entries[i].string_id;
		}
		return "";
	}
	
	// Assuming this file is meant for the base save, and that it is valid (as it would have been deleted by the button otherwise)
	var buf = buffer_load("NUBBY_AutoSave_F.save.forgery");
	var load_forgery = buffer_read(buf, buffer_string);
	buffer_delete(buf);
	var data = json_parse(load_forgery);
	
	// Game calls this twice - we only care about replacing indices once everything has loaded.
	if (!agi("obj_LvlMGMT").GameLoaded) {
		
		// We gotta load the modded supervisor if there is one, since usually they are gameplay registered at the supervisors screen, which is skipped here.
		var svid = real(base_data.A_SVID)
		if svid > global.last_indices[mod_resources.supervisor] {
			log_info("Modded supervisor detected in autosave")
			var string_id = find_string_id_from_data(data, mod_resources.supervisor, svid);
			var supervisor = mod_registry_get_right(global.registry, mod_resources.supervisor, string_id)
			free_all_allocated_objects(mod_resources.supervisor)
			clear_index_assignments(mod_resources.supervisor)
			register_supervisor_for_gameplay(supervisor, global.last_indices[mod_resources.supervisor] + 1, string_id)
		}
		return;
	}
	
	// Load mods' save data
	var mod_ids = struct_get_names(data.custom);
	for (var i = 0; i < array_length(mod_ids); i++) {
		var mod_id = mod_ids[i];
		if !ds_map_exists(global.mod_id_to_mod_map, mod_id) {
			// shouldn't be possible
			log_warn($"Missing mod {mod_id} in autosave, skipping")
			continue;
		}
		var wod = ds_map_find_value(global.mod_id_to_mod_map, mod_id)
		var mod_save_data = data.custom[$ mod_id]
		global.cmod = wod;
		for (var j = 0; j < array_length(wod.autosave_load_callbacks); j++) {
			try {
				execute(wod.autosave_load_callbacks[j], mod_save_data)
			}
			catch (e) {
				log_error($"Mod {wod.mod_id} errored on an autosave-load callback: {e}")	
			}
		}
	}
	

	var fields_list_map = array_create(mod_resources.size, []);
	fields_list_map[mod_resources.item] = ["A_Items", "A_FrozenItems", "A_ShopItems", "A_CafeItems", "A_BMItems"]
	fields_list_map[mod_resources.perk] = ["A_Perks"]
	fields_list_map[mod_resources.supervisor] = ["A_SVID"]
	for (var resource = 0; resource < mod_resources.size; resource++) {
		var fields_list = fields_list_map[resource];
		//log_info($"Going over all fields for {global.resource_names[resource]}")
		for (var i = 0; i < array_length(fields_list); i++) {
			var field = fields_list[i];
			//log_info($"Going over {field}")
			
			var array = parse_autosave_array(base_data[$ field])
			for (var j = 0; j < array_length(array); j++) {
				var index = array[j];
				//log_info($"Checking {index}")
				if index <= global.last_indices[resource] {
					// vanilla item
					continue;
				}
				//log_info($"Index {index} isn't vanilla")
				
				var string_id = find_string_id_from_data(data, resource, index);
				if string_id == "" {
					log_warn($"While going over autosave type {global.resource_names[resource]} - No resource for index {index}, replacing with 0")
					array[j] = 0
				}
				else {
					var new_index = mod_registries_exchange(global.registry, global.index_registry, resource, string_id);
					if (new_index == undefined) {
						log_warn($"While going over autosave type {global.resource_names[resource]} - No resource for {string_id}, replacing with index 0");
						new_index = 0;
					}
					//log_info($"Replaced {index} with {new_index}")
					array[j] = new_index
				}
			}
			base_data[$ field] = write_autosave_array(array)
		}
	}
}