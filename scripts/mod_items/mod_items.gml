// For catspeak
function register_mod_item(item, item_id) {
	static item_contract = {
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

	var wod = global.currently_executing_mod;

	var discompliance = get_struct_discompliance_with_contract(item, item_contract)
	if array_length(discompliance.missing) > 0 || array_length(discompliance.mismatched_types) > 0 {
		throw ($"Item {item_id} from {wod.mod_id} has bad variables!\n" 
			+ generate_discompliance_error_text(item, item_contract, discompliance))
	}
	
	item.mod_of_origin = wod;
	item.string_id = item_id
	ds_map_set(wod.items, item_id, item)
	log_info($"Item {item_id} registered to {wod.mod_id}");
	return item;
}

// For catspeak
function register_all_mod_items(path, wod = global.currently_executing_mod) {
	var current_folder_map = wod.code_files;
	var paths_to_take = string_split(path, "/", true);
	for (var i = 0; i < array_length(paths_to_take); i++) {
		if !ds_map_is_map(current_folder_map, paths_to_take[i]) {
			throw $"Error: Mod {wod.mod_id} called register_all_mod_items with a bad folder path {path}"
		}
		current_folder_map = ds_map_find_value(current_folder_map, paths_to_take[i])
	}
	var item_file_names = ds_map_keys_to_array(current_folder_map);
	
	for (var i = 0; i < array_length(item_file_names); i++) {
		if ds_map_is_map(current_folder_map, item_file_names[i]) {
			array_delete(item_file_names, 0, 1);
			i--;	
		}
	}
	for (var i = 0; i < array_length(item_file_names); i++) {
		var file = ds_map_find_value(current_folder_map, item_file_names[i])
		var item = get_code_file_globals(file, wod)
		if !variable_struct_get(item, "construct") {
			throw $"Error: Mod {wod.mod_id} called register_all_mod_items in path {path},"
			+ $" but item file {item_file_names[i]} doesn't have a construct() method!"
		}
		var item_id = remove_file_extension(item_file_names[i])
		register_mod_item(file, item_id)
	}
}
function remove_file_extension(name) {
	var arr = string_split(name, ".", true, 1)
	if array_length(arr) == 0
		return name
	return arr[0]
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
	return $"{item.mod_of_origin.mod_id}:{item.string_id}"	
}
