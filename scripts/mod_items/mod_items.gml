function load_mod_items(buffer, items_dir, mod_id) {
	var ir = Catspeak.parse(buffer);
	var main = Catspeak.compile(ir);
	var globals = catspeak_globals(main);
	globals.items_directory = items_dir;
	globals.mod_id = mod_id;
	try {
		catspeak_execute(main);
	}
	catch (e) {
		log($"Error while running items.meow file for mod {mod_id}: {e}")	
	}
}

// For catspeak
function register_mod_item(path, mod_id, item_id) {
	static item_contract = {
		string_id : "",
		display_name : "",
		description : "",
		trigger_condition : "",
		alt_trigger_condition : "",
		sprite : agi("obj_empty"),
		level : 0,
		type : 0,
		tier : 0,
		status : 0,
		effect_id : "",
		pool : 0,
		offset_price : 0,
		upgrade_item_id : "",
		odds_weight_early : 0,
		odds_weight_mid : 0,
		odds_weight_end : 0,
		on_create : global.empty_method,
		on_round_init : global.empty_method,
		on_step : global.empty_method,
		on_trigger : global.empty_method,
	}
	if !ds_map_exists(global.mod_id_to_mod_map, mod_id)
		throw $"Attempting to register item {item_id} to non-existent mod ID: {mod_id}"
		
	var item_buffer = buffer_load(path)
	var ir = Catspeak.parse(item_buffer);
	var main = Catspeak.compile(ir);
	var globals = catspeak_globals(main);
	globals.mod_id = mod_id
	globals.string_id = item_id
	try {
		catspeak_execute(main);	
	}
	catch(e) {
		throw $"Error while running item definition file for item {item_id}! {e}"
	}
	
	var item = globals;
	
	var discompliance = get_struct_discompliance_with_contract(item, item_contract)
	if array_length(discompliance.missing) > 0 || array_length(discompliance.mismatched_types) > 0 {
		throw ($"Item {item_id} has bad variables!\n" 
			+ generate_discompliance_error_text(item, item_contract, discompliance))
	}
	
	
	var wod = ds_map_find_value(global.mod_id_to_mod_map, mod_id)
	ds_map_set(wod.items, item_id, item)
	return item;
}

// For catspeak
function register_all_mod_items(directory, mod_id) {
	var folder_name = directory // TODO
	if !ds_map_exists(global.mod_id_to_mod_map, mod_id)
		throw $"Attempted to register items in {folder_name} directory to non-existent mod {mod_id}"
	var item_files = get_all_files(directory, "meow")
	for (var j = 0; j < array_length(item_files); j++) {
		var file_path = directory + item_files[j] + ".meow";
		register_mod_item(file_path, mod_id, item_files[j])
	}
}

function get_item(string_id) {
	var struct = split_id(string_id);
	if !ds_map_exists(global.mod_id_to_mod_map, struct.namespace) {
		throw ($"Item {struct.resource} requested from mod {struct.namespace} but that mod does not exist")
	}
	var wod = ds_map_find_value(global.mod_id_to_mod_map, struct.namespace)
	if !ds_map_exists(wod.items, struct.resource) {
		throw ($"Item {struct.resource} requested from {struct.namespace} but the item does not exist there")
	}
	return ds_map_find_value(wod.items, struct.resource);
}
function get_full_item_id(item) {
	return $"{item.mod_id}:{item.string_id}"	
}
