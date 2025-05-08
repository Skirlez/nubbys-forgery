// For catspeak
function register_mod_item(item, item_id) {
	static item_contract = {
		display_name : "",
		description : "",
		game_event : "",
		alt_game_event : "",
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
		on_trigger : global.empty_method,
	}

	var wod = global.currently_executing_mod;
	var discompliance = get_struct_discompliance_with_contract(item, item_contract)
	if array_length(discompliance.missing) > 0 || array_length(discompliance.mismatched_types) > 0 {
		throw ($"Item {item_id} from {wod.mod_id} has bad variables!\n" 
			+ generate_discompliance_error_text(item, item_contract, discompliance))
	}
	
	static optional_variables = {
		on_step : noone,
		on_round_init : noone,
	}
	initialize_missing(item, optional_variables)
	
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
		var item = init_code_file_and_get_globals(file, wod)
		if !variable_struct_get(item, "construct") {
			log_error($"Error: Mod {wod.mod_id} called register_all_mod_items in path {path},"
			+ $" but item file {item_file_names[i]} doesn't have a construct() method! Skipping it...")
			continue;
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


// called from gml_Object_obj_ItemMGMT_Create_0
function register_items_for_gameplay() {
	free_all_allocated_objects(allocatable_objects.item)
	ds_map_clear(global.item_id_to_index_map)
	ds_map_clear(global.index_to_item_id_map)
	var mods = ds_map_values_to_array(global.mod_id_to_mod_map)
	for (var i = 0; i < array_length(mods); i++) {
		var wod = mods[i];
		var items = ds_map_values_to_array(wod.items)
		for (var j = 0; j < array_length(items); j++) {			
			var item = items[j];
			
			var item_number_id = array_length(agi("obj_ItemMGMT").ItemID)

			var obj = allocate_object(allocatable_objects.item, item)
			
			object_set_sprite(obj, item.sprite)
			log_info($"Item {item.string_id} gameplay registered from mod {item.mod_of_origin.mod_id}")
			agi("scr_Init_Item")(item_number_id,
				agi("scr_Text")(item.display_name),
				obj,
				item.level, 
				item.type, 
				item.tier, 
				item.status,
				item.effect_id, 
				item.pool, 
				item.offset_price, 
				item.upgrade_item_id, 
				item.game_event, 
				item.alt_game_event,
				agi("scr_Text")(item.description, "\n"))
			agi("scr_Init_ItemExt")(item_number_id, 
				item.odds_weight_early, item.odds_weight_mid, item.odds_weight_end)
			
			ds_map_set(global.item_id_to_index_map, get_full_id(item), item_number_id)
			ds_map_set(global.index_to_item_id_map, item_number_id, get_full_id(item))
		}
	}
	// we need to pass over this array after all items have been registered
	// so we can then resolve the temporary upgrade item ID we put in and replace it with
	// an index ID
	var item_pair_arr = agi("obj_ItemMGMT").ItemPair
	for (var i = 0; i < array_length(item_pair_arr); i++) {
		if !is_string(item_pair_arr[i])
			continue;
		if !ds_map_exists(global.item_id_to_index_map, item_pair_arr[i]) {
			log_error($"Item {ds_map_find_value(global.index_to_item_id_map, i)} has {item_pair_arr[i]} set"
				+ " as its upgrade, but it does not exist!")
			// TODO figure out what to do about the item in this case
		}
		item_pair_arr[i] = ds_map_find_value(global.item_id_to_index_map, item_pair_arr[i])
	}
}
/*
function get_item(string_id) {
	if is_id_valid(string_id) {
		
	}
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