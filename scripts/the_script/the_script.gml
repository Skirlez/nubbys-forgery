// Everything used to be in this script. Then I put things in other scripts.
#macro agi asset_get_index

function create_mod(mod_folder_name) {
	var mod_definition_file = file_text_open_read($"{global.mods_directory}/{mod_folder_name}/mod.json")
	if (mod_definition_file == -1) {
		return new result_error(new generic_error(
			$"Could not find mod.json for mod folder {mod_folder_name}"));
	}
	var mod_definition_string = ""
	while (!file_text_eof(mod_definition_file)) {
		mod_definition_string += file_text_readln(mod_definition_file) + "\n"
	}
	file_text_close(mod_definition_file)
		
	try {
		var wod = json_parse(mod_definition_string)
	}
	catch (e) {
		return new result_error(new generic_error(
			$"Error while parsing mod.json in mod folder {mod_folder_name}: {pretty_error(e)}"));
	}
	
	static mod_contract = {
		mod_id : "",
		display_name : "",
		description : "",
		version : "",
		credits : [],
		target_modloader_version : 0,
		entrypoint_path : "",
		translations_path : "",
		compile_all_code_on_load : false
	}
	
	var discompliance = get_struct_discompliance_with_contract(wod, mod_contract)
	if array_length(discompliance.missing) > 0 || array_length(discompliance.mismatched_types) > 0 {
		return new result_error(new generic_error(
			$"mod.json in {mod_folder_name} has bad variables:\n" 
			+ generate_discompliance_error_text(wod, mod_contract, discompliance)
		))
	}
	
	wod.folder_name = mod_folder_name;
	wod.translations = ds_map_create();
	
	load_mod_translations(wod)
	
	wod.code_files = ds_map_create();
	wod.functions = ds_map_create();

	if wod.compile_all_code_on_load {
		log_info($"Compiling all files belonging to mod {wod.mod_id}")
		compile_all_files_in_path_recursively("/", wod, wod.code_files)
	}
	global.cmod = wod;
	try {
		var mod_globals = mod_get_code_globals(wod.entrypoint_path, wod)
	}
	catch (e) {
		return new result_error(new generic_error(e))
	}

	static mod_globals_contract = {
		on_load : global.empty_method,
		on_unload : global.empty_method,
	}
	var discompliance = get_struct_discompliance_with_contract(mod_globals, mod_globals_contract)
	if array_length(discompliance.missing) > 0 || array_length(discompliance.mismatched_types) > 0 {
		return new result_error(new generic_error(
			$"Mod entrypoint {wod.entrypoint_path} has bad variables:\n" 
			+ generate_discompliance_error_text(mod_globals, mod_globals_contract, discompliance)
		))
	}
	
	
	wod.items = []
	wod.perks = []
	wod.supervisors =  []
	//wod.foods = ds_map_create();
	wod.sprites = ds_map_create();
	wod.sounds = ds_map_create();
	
	
	wod.game_events = [];
	wod.callback_records = [];
	wod.autosave_save_callbacks = []
	wod.autosave_load_callbacks = []
	
	// TODO check invalid characters
	return new result_ok(wod)
}


function compile_all_files_in_path_recursively(path, map, wod) {
	var type = mod_get_code_type(path)
	var files = get_all_files(path, ".meow")
	for (var i = 0; i < array_length(files); i++) {
		var main;
		try {
			main = compile_code_file($"{path}{files[i]}.meow");
		}
		catch (e) {
			log_error($"While compiling all files, {path} errored on compilation: {pretty_error(e)}")
			continue;
		}
		ds_map_add(map, files[i], main)
	}
	
	var folders = get_all_directories(path)
	for (var i = 0; i < array_length(folders); i++) {
		var folder_name = folders[i]
		var folder_map = ds_map_create();
		ds_map_add_map(map, folders[i], folder_map)
		compile_all_files_in_path_recursively($"{path}/{folder_name}", folder_map, wod)
	}
}


// For catspeak use
function mod_execute_code(path, wod = global.cmod) {
	try {
		var code = mod_get_code(path, wod)
		execute(code)
	}
	catch (e) {
		log_error($"While calling mod_execute_code (path: {path}): " + pretty_error(e))	
	}
}
// For catspeak use
function mod_get_code_globals(path, wod = global.cmod) {
	var code = mod_get_code(path, wod)
	var globals = catspeak_globals(code);
	if variable_struct_names_count(globals) == 0 {
		try {
			execute(code)
		}
		catch (e) {
			log_error($"While calling mod_get_code_globals (path: {path}): " + pretty_error(e))	
		}
	}
	return globals;
}

/*
TODO:
I cannot remember why I implemented code_files with nested maps.
I don't think it needs nested maps. Could just have code_files be a map of path strings to code files.
Probably should rewrite this to do that.
*/

// For gamemaker and catspeak use
function mod_get_code(path, wod = global.cmod) {
	var path_arr = string_split(path, "/", true)
	var current_thing = wod.code_files
	var current_full_directory = $"{global.mods_directory}/{wod.folder_name}";
	if array_length(path_arr) == 0 {
		throw $"Mod {wod.mod_id} requested code file from bad path ({path})"	
	}
	for (var i = 0; i < array_length(path_arr); i++) {
		var new_location = path_arr[i];
		var last_entry = i == array_length(path_arr) - 1;
		if !ds_map_exists(current_thing, new_location) {
			var error_message = $"Mod {wod.mod_id} requested code file from {path}, but {new_location} does not exist";
			if !(last_entry) {
				// missing folder
				if !directory_exists($"{current_full_directory}/{new_location}")
					throw error_message;
				ds_map_add_map(current_thing, new_location, ds_map_create())
			}
			else {
				// missing file
				if !file_exists($"{current_full_directory}/{new_location}")
					throw error_message;
				
				var main;
				try {
					main = compile_code_file($"{current_full_directory}/{new_location}");
				}
				catch (e) {
					throw $"Mod {wod.mod_id} requested file {path} which errored on compilation: {pretty_error(e)}"	
				}
				ds_map_add(current_thing, new_location, main)
				return main;
			}
		}
		
		if !ds_map_is_map(current_thing, new_location) && !last_entry
				|| (ds_map_is_map(current_thing, new_location) && last_entry) {
			throw $"Requested code file from bad path ({path})"
		}
		current_thing = ds_map_find_value(current_thing, new_location)
		current_full_directory += $"/{new_location}"
	}
	return current_thing;
	
}
function strip_initial_path_separator_character(path) {
	if string_starts_with(path, "/") || string_starts_with(path, "\\")
		path = string_delete(path, 1, 1)	
	return path
}


function unload_mod(wod) {
	log_info($"Unloading mod {wod.mod_id}")
	global.cmod = wod;
	var main_globals = mod_get_code_globals(wod.entrypoint_path)
	try {
		main_globals.on_unload();
	}
	catch (e) {
		log_error($"Mod {wod.mod_id} errored while unloading: {pretty_error(e)}")
	}
	
	// Remove any Game Event callbacks this mod has
	for (var i = 0; i < array_length(wod.callback_records); i++) {
		var callback = wod.callback_records[i].callback;
		var game_event_name = wod.callback_records[i].game_event_name;
		
		var callback_mod_structs = ds_map_find_value(global.modloader_game_events, game_event_name)
		for (var j = 0; j < array_length(callback_mod_structs); j++) {
			if (callback_mod_structs[j].callback == callback) {
				array_delete(callback_mod_structs, j, 1)
				break;	
			}
		}
		if array_length(callback_mod_structs) == 0
			ds_map_delete(global.modloader_game_events, game_event_name);
	}
	
	for (var i = 0; i < array_length(wod.items); i++) {
		bimap_delete_right(global.registry[mod_resources.item], wod.items[i])	
	}
	for (var i = 0; i < array_length(wod.perks); i++) {
		bimap_delete_right(global.registry[mod_resources.perk], wod.perks[i])	
	}
	for (var i = 0; i < array_length(wod.supervisors); i++) {
		bimap_delete_right(global.registry[mod_resources.supervisor], wod.supervisors[i])	
	}
	
	var translation_keys = ds_map_keys_to_array(wod.translations)
	for (var i = 0; i < array_length(translation_keys); i++) {
		ds_grid_destroy(ds_map_find_value(wod.translations, translation_keys[i]))	
	}
	ds_map_destroy(wod.translations)
		
	var sprite_keys = ds_map_keys_to_array(wod.sprites)
	for (var i = 0; i < array_length(sprite_keys); i++) {
		var sprite = ds_map_find_value(wod.sprites, sprite_keys[i]);
		if sprite >= global.sprite_count
			sprite_delete(sprite)
	}
	ds_map_destroy(wod.sprites)
	
	var sound_keys = ds_map_keys_to_array(wod.sounds)
	for (var i = 0; i < array_length(sound_keys); i++) {
		var sound = ds_map_find_value(wod.sounds, sound_keys[i])
		if (sound >= global.sound_count)
			audio_destroy_stream(sound)
	}
	ds_map_destroy(wod.sounds)
	
	ds_map_destroy(wod.code_files)
	
	ds_map_destroy(wod.functions)
	
	remove_mod_from_run_delayed(wod)
	
	ds_map_delete(global.mod_id_to_mod_map, wod.mod_id);
}


function clear_all_mods() {
	log_info("Clearing/Unloading all mods")
	var mods = ds_map_values_to_array(global.mod_id_to_mod_map)
	for (var i = 0; i < array_length(mods); i++) {
		var wod = mods[i]
		unload_mod(wod)
	}
	ds_map_clear(global.mod_id_to_mod_map)
	registry_clear(global.registry)
	registry_clear(global.index_registry)
}


// Reads all mods and returns a list of their structs
function read_all_mods() {
	var folders = get_all_directories(global.mods_directory)
	for (var i = 0; i < array_length(folders); i++) {
		var mod_folder_name = folders[i];
		var mod_result = create_mod(mod_folder_name)
		if (mod_result.is_error()) {
			log_error(mod_result.error.text)
			continue;
		}
		var wod = mod_result.value
		ds_map_set(global.mod_id_to_mod_map, wod.mod_id, wod);
		
		var main = mod_get_code(wod.entrypoint_path, wod)
		var main_globals = catspeak_globals(main)
		try {
			global.cmod = wod;
			main_globals.on_load();
		}
		catch (e) {
			log_error($"Mod {wod.mod_id} errored on load: {pretty_error(e)}")
			// TODO what to do
			unload_mod(wod)
			continue;
		}
		log_info($"Mod {wod.mod_id} successfully loaded")
		
		
	}
}


function is_console_and_devmode_enabled() {
	return true;	
}
function reroll_cheats_enabled() {
	return false;	
}

function pretty_error(e) {
	// TODO
	return string(e);
}

function hot_reload() {
	var mods = ds_map_values_to_array(global.mod_id_to_mod_map)
	for (var i = 0; i < array_length(mods); i++) {
		var wod = mods[i]
		ds_map_clear(wod.code_files)
		/*
		for (var j = 0; j < array_length(wod.items); j++) {
			var item = wod.items[j];
			
		}
		*/
	}
}
function get_nf_version_string() {
	return "Nubby's Forgery BETA V2"	
}
function get_nf_loaded_string() {
	return $"({ds_map_size(global.mod_id_to_mod_map)} mod(s) loaded, "
		+ $"{bimap_size(global.registry[mod_resources.item])} item(s), "
		+ $"{bimap_size(global.registry[mod_resources.perk])} perk(s), "
		+ $"{bimap_size(global.registry[mod_resources.supervisor])} supervisor(s))"
}