// For catspeak
function mod_register_perk(perk, perk_id, wod = global.currently_executing_mod) {
	if !mod_is_id_component_valid(perk_id) {
		log_error($"Mod {wod.mod_id} tried to register an item with invalid ID {perk_id}")
		return;
	}
	if bimap_right_exists(global.registry[mod_resources.perk], perk) {
		var current_id = bimap_get_left(global.registry[mod_resources.perk], perk)
		log_error($"Mod {wod.mod_id} tried to register a perk struct with ID {perk_id},"
			+ $" but this struct has already been registered prior to {current_id}! Each struct registered must be unique.")
		return;
	}
	
	static perk_contract = {
		display_name : "",
		description : "",
		sprite : agi("obj_empty"),
		game_event : "",
		tier : 0,
		type : 0,
		pool : 0,
		trigger_fx_color : int64(0),
		additional_info_type : 0,
		on_create : global.empty_method,
		on_trigger : global.empty_method,
	}

	var discompliance = get_struct_discompliance_with_contract(perk, perk_contract)
	if array_length(discompliance.missing) > 0 || array_length(discompliance.mismatched_types) > 0 {
		log_error($"Perk {perk_id} from {wod.mod_id} has bad variables!\n" 
			+ generate_discompliance_error_text(perk, perk_contract, discompliance)
			+ "\nThe perk is not registered.")
			
		return;
	}	

	var full_id = $"{wod.mod_id}:{perk_id}"
	bimap_set(global.registry[mod_resources.perk], full_id, perk)
	array_push(wod.perks, perk)
	log_info($"Perk {full_id} registered");
	return perk;
}

// called from gml_Object_obj_PerkMGMT_Create_0
function register_perks_for_gameplay() {
	free_all_allocated_objects(mod_resources.perk)
	clear_index_assignments(mod_resources.perk)
		
	var perk_ids = bimap_lefts_array(global.registry[mod_resources.perk])
	for (var i = 0; i < array_length(perk_ids); i++) {			
		var perk = bimap_get_right(global.registry[mod_resources.perk], perk_ids[i])
			
		var perk_index = array_length(agi("obj_PerkMGMT").PerkID)

		var obj = allocate_object(mod_resources.perk, perk)
		object_set_sprite(obj, perk.sprite)
			
		agi("scr_Init_Perk")(perk_index,
			agi("scr_Text")(perk.display_name),
			obj,
			perk.game_event, 
			perk.tier, 
			perk.type, 
			perk.pool,
			perk.trigger_fx_color, 
			perk.additional_info_type,
			agi("scr_Text")(perk.description, "\n"))
			
		assign_index_to_resource(mod_resources.perk, perk, perk_index)
		log_info($"Perk {perk_ids[i]} has been indexed: {perk_index}")
	}
}


