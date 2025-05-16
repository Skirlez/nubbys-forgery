global.items = bimap_create();

// For catspeak
function mod_register_item(item, item_id, wod = global.currently_executing_mod) {
	if !mod_is_id_component_valid(item_id) {
		log_error($"Mod {wod.mod_id} tried to register an item with invalid ID {item_id}")
		return;
	}
	if bimap_right_exists(global.items, item) {
		var current_id = bimap_get_left(global.perks, item)
		log_error($"Mod {wod.mod_id} tried to register an item struct with ID {item_id},"
			+ $" but this struct has already been registered prior to {current_id}! Each struct registered must be unique.")	
		return;
	}
	
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
		pair_id : "",
		odds_weight_early : 0,
		odds_weight_mid : 0,
		odds_weight_end : 0,
		on_create : global.empty_method,
		on_trigger : global.empty_method,
	}

	
	var discompliance = get_struct_discompliance_with_contract(item, item_contract)
	if array_length(discompliance.missing) > 0 || array_length(discompliance.mismatched_types) > 0 {
		log_error($"Item {item_id} from {wod.mod_id} has bad variables!\n" 
			+ generate_discompliance_error_text(item, item_contract, discompliance)
			+ "\nThe item is not registered.")
		return;
	}
	
	static optional_variables = {
		on_step : noone,
		on_round_init : noone,
	}
	initialize_missing(item, optional_variables)
	
	var full_id = $"{wod.mod_id}:{item_id}"
	
	bimap_set(global.items, full_id, item)
	array_push(wod.perks, item)
	log_info($"Item {full_id} registered");
	return item;
}


function remove_file_extension(name) {
	var arr = string_split(name, ".", true, 1)
	if array_length(arr) == 0
		return name
	return arr[0]
}


// called from gml_Object_obj_ItemMGMT_Create_0
function register_items_for_gameplay() {
	free_all_allocated_objects(mod_resources.item)
	clear_index_assignments(mod_resources.item)
	
	var item_ids = bimap_lefts_array(global.items)
	for (var i = 0; i < array_length(item_ids); i++) {			
		var item = bimap_get_right(global.items, item_ids[i])
			
		var item_index = array_length(agi("obj_ItemMGMT").ItemID)

		var obj = allocate_object(mod_resources.item, item)
			
		object_set_sprite(obj, item.sprite)
		agi("scr_Init_Item")(item_index,
			agi("scr_Text")(item.display_name),
			obj,
			item.level, 
			item.type, 
			item.tier, 
			item.status,
			item.effect_id, 
			item.pool, 
			item.offset_price, 
			item.pair_id, 
			item.game_event, 
			item.alt_game_event,
			agi("scr_Text")(item.description, "\n"))
			
		agi("scr_Init_ItemExt")(item_index, 
			item.odds_weight_early, item.odds_weight_mid, item.odds_weight_end)
			
		assign_index_to_resource(mod_resources.item, item, item_index)
			
		log_info($"Item {item_ids[i]} has been indexed: {item_index}")
	}
	
	// we need to pass over this array after all items have been registered
	// so we can then resolve the temporary upgrade item ID we put in and replace it with
	// an index ID
	var item_pair_arr = agi("obj_ItemMGMT").ItemPair
	for (var i = 0; i < array_length(item_pair_arr); i++) {
		if !is_string(item_pair_arr[i])
			continue;
		
		if !bimap_left_exists(global.items, item_pair_arr[i]) {
			var this_item = get_resource_by_index(mod_resources.item, i)
			var this_item_id = bimap_get_left(global.items, this_item);
			
			log_error($"Item {this_item_id} has {item_pair_arr[i]} set"
				+ " as its pair, but it does not exist! Setting it to Pants")
			item_pair_arr[i] = 0;
			continue;
		}
		item_pair_arr[i] = bimap_get_left(global.items, item_pair_arr[i])
	}
}

