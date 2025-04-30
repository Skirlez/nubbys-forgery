#macro agi asset_get_index

function create_mod(mod_folder_name) {
	var mod_definition_file = file_text_open_read($"{global.mods_directory}/{mod_folder_name}/mod.json")
	if (mod_definition_file == -1) {
		return new result_error(new generic_error(
			$"Error: Could not find mod.json for mod folder {mod_folder_name}"));
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
			$"Error while parsing mod.json in mod folder {mod_folder_name}: {e}"));
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
		compile_all_code_on_load : 0 // gets parsed as number, despite being boolean.
	}
	
	var discompliance = get_struct_discompliance_with_contract(wod, mod_contract)
	if array_length(discompliance.missing) > 0 || array_length(discompliance.mismatched_types) > 0 {
		return new result_error(new generic_error(
			$"mod.json in {mod_folder_name} has bad variables:\n" 
			+ generate_discompliance_error_text(wod, mod_contract, discompliance)
		))
	}
	
	wod.code_files = ds_map_create();
	wod.folder_name = mod_folder_name;
	
	// not running this line will cause it to lazily evaluate/compile every file
	// the mod requests
	
	//compile_all_files_in_path(wod)
	global.currently_executing_mod = wod;
	try {
		var mod_globals = init_code_file_and_get_globals(wod.entrypoint_path, wod)
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
	
	
	wod.items = ds_map_create();
	wod.perks = ds_map_create();
	//wod.foods = ds_map_create();
	wod.sprites = []
	wod.translations = ds_map_create();
	wod.sprites = ds_map_create();
	wod.audio_streams = ds_map_create();
	
	// TODO check invalid characters
	return new result_ok(wod)
}


function compile_all_files_in_path(path, map, wod) {
	var files = get_all_files(path, ".meow")
	for (var i = 0; i < array_length(files); i++) {
		var buffer = buffer_load($"{path}{files[i]}.meow")
		var ir = Catspeak.parse(buffer);
		var main = Catspeak.compile(ir);
		ds_map_add(map, files[i], main)
	}
	
	var folders = get_all_directories(path)
	for (var i = 0; i < array_length(folders); i++) {
		var folder_name = folders[i]
		var folder_map = ds_map_create();
		ds_map_add_map(map, folders[i], folder_map)
		compile_all_files_in_path($"{path}/{folder_name}", folder_map, wod)
	}
}


// for catspeak use
function execute_mod_code_file(path, wod = global.currently_executing_mod) {
	var code = get_code_file(path, wod)
	code();
}
function get_code_file_globals(path, wod = global.currently_executing_mod) {
	var code = get_code_file(path, wod)
	return catspeak_globals(code)
}
function init_code_file_and_get_globals(path, wod = global.currently_executing_mod) {
	var code = get_code_file(path, wod)
	code();
	return catspeak_globals(code)
}
// For gamemaker and catspeak use
function get_code_file(path, wod = global.currently_executing_mod) {
	var path_arr = string_split(path, "/", true)
	var current_thing = wod.code_files
	var current_full_directory = $"{global.mods_directory}/{wod.folder_name}";
	if array_length(path_arr) == 0 {
		throw $"Error: mod {wod.mod_id} requested code file from bad path ({path})"	
	}
	for (var i = 0; i < array_length(path_arr); i++) {
		var new_location = path_arr[i];
		var last_entry = i == array_length(path_arr) - 1;
		if !ds_map_exists(current_thing, new_location) {
			var error_message = $"Error: mod {wod.mod_id} requested code file from {path}, but {new_location} does not exist";
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
				var buffer = buffer_load($"{current_full_directory}/{new_location}")
				try {
					var ir = Catspeak.parse(buffer);
					var main = Catspeak.compile(ir);
				}
				catch (e) {
					throw $"Error: mod {wod.mod_id} requested file {path} which errored on compilation: {e}"	
				}
				ds_map_add(current_thing, new_location, main)
				buffer_delete(buffer)
				return main
			}
		}
		
		if !ds_map_is_map(current_thing, new_location) && !last_entry
				|| (ds_map_is_map(current_thing, new_location) && last_entry) {
			throw $"Error: requested code file from bad path ({path})"
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
function mod_get_path(path, wod = global.currently_executing_mod) {
	path = strip_initial_path_separator_character(path);
	return $"{global.mods_directory}/{wod.folder_name}/{path}"	
}


function unload_mod(wod) {
	log_info($"Unloading mod {wod.mod_id}")
	var main = get_code_file("mod.meow", wod)
	var main_globals = catspeak_globals(main)
	global.currently_executing_mod = wod;
	try {
		main_globals.on_unload();
	}
	catch (e) {
		log_error($"Mod {wod.mod_id} errored while unloading: {e}")
	}
	
	// TODO: UNLOAD mod happenings
	
	
	ds_map_destroy(wod.items)
	ds_map_destroy(wod.perks)
	
	var translation_keys = ds_map_keys_to_array(wod.translations)
	for (var j = 0; j < array_length(translation_keys); j++) {
		ds_grid_destroy(ds_map_find_value(wod.translations, translation_keys[j]))	
	}
	ds_map_destroy(wod.translations)
		
	var sprite_keys = ds_map_keys_to_array(wod.sprites)
	for (var j = 0; j < array_length(sprite_keys); j++) {
		sprite_delete(ds_map_find_value(wod.sprites, sprite_keys[j]))	
	}
	ds_map_destroy(wod.sprites)
		
	var audio_stream_keys = ds_map_keys_to_array(wod.audio_streams)
	for (var j = 0; j < array_length(audio_stream_keys); j++) {
		audio_destroy_stream(ds_map_find_value(wod.audio_streams, audio_stream_keys[j]))	
	}
	ds_map_destroy(wod.audio_streams)
	ds_map_destroy(wod.code_files)
}


function clear_all_mods() {
	var mods = ds_map_values_to_array(global.mod_id_to_mod_map)
	for (var i = 0; i < array_length(mods); i++) {
		var wod = mods[i]
		unload_mod(wod)
	}
	ds_map_clear(global.mod_id_to_mod_map)
}


// Reads all mods and returns a list of their structs
function read_all_mods() {
	clear_all_mods();
	
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
		
		load_mod_translations(wod)
		
		var main = get_code_file("mod.meow", wod)
		var main_globals = catspeak_globals(main)
		try {
			global.currently_executing_mod = wod;
			main_globals.on_load();
		}
		catch (e) {
			log_error($"Mod {wod.mod_id} errored on load: {e}")
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
	return true;	
}

function get_full_id(appropriate_struct) {
	// TODO check if struct is item/perk
	return $"{appropriate_struct.mod_of_origin.mod_id}:{appropriate_struct.string_id}"	
}
