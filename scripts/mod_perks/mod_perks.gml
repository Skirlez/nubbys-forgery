// For catspeak
function register_mod_perk(perk, perk_id) {
	static perk_contract = {
		display_name : "",
		description : "",
		sprite : agi("obj_empty"),
		game_event : "",
		tier : 0,
		type : 0,
		pool : 0,
		trigger_fx_color : int64(0),
		on_create : global.empty_method,
		on_trigger : global.empty_method,
	}

	var wod = global.currently_executing_mod;

	var discompliance = get_struct_discompliance_with_contract(perk, perk_contract)
	if array_length(discompliance.missing) > 0 || array_length(discompliance.mismatched_types) > 0 {
		throw ($"Perk {perk_id} from {wod.mod_id} has bad variables!\n" 
			+ generate_discompliance_error_text(perk, perk_contract, discompliance))
	}	
	perk.mod_of_origin = wod;
	perk.string_id = perk_id;
	ds_map_set(wod.perks, perk_id, perk)
	log_info($"Perk {perk_id} registered to {wod.mod_id}");
	return perk;
}

// called from gml_Object_obj_PerkMGMT_Create_0
function register_perks_for_gameplay() {
	free_all_allocated_perk_objects()

	ds_map_clear(global.perk_id_to_index_map)
	ds_map_clear(global.index_to_perk_id_map)
	var mods = ds_map_values_to_array(global.mod_id_to_mod_map)
	for (var i = 0; i < array_length(mods); i++) {
		var wod = mods[i];
		var perks = ds_map_values_to_array(wod.perks)
		for (var j = 0; j < array_length(perks); j++) {			
			var perk = perks[j];
			
			var perk_number_id = array_length(agi("obj_PerkMGMT").PerkID)

			var obj = allocate_object_for_perk(perk)
			object_set_sprite(obj, perk.sprite)
			log_info($"Perk {perk.string_id} gameplay registered from mod {perk.mod_of_origin.mod_id}")
			
			agi("scr_Init_Perk")(perk_number_id,
				agi("scr_Text")(perk.display_name),
				obj,
				perk.game_event, 
				perk.tier, 
				perk.type, 
				perk.pool,
				perk.trigger_fx_color, 
				perk.additional_info_type,
				agi("scr_Text")(perk.description, "\n"))
			
			ds_map_set(global.perk_id_to_index_map, get_full_id(perk), perk_number_id)
			ds_map_set(global.index_to_perk_id_map, perk_number_id, get_full_id(perk))
		}
	}
}