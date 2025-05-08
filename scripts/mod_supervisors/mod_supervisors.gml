// For catspeak
function register_mod_supervisor(supervisor, supervisor_id) {
	static supervisor_contract = {
		display_name : "",
		description : "",
		sprites : {},
		name_color : int64(0),
		cost : 0,
		on_create : global.empty_method,
		on_destroy : global.empty_method,
	}
	var wod = global.currently_executing_mod;
	var discompliance = get_struct_discompliance_with_contract(supervisor, supervisor_contract)
	if array_length(discompliance.missing) > 0 || array_length(discompliance.mismatched_types) > 0 {
		throw ($"Supervisor {supervisor_id} from {wod.mod_id} has bad variables!\n" 
			+ generate_discompliance_error_text(supervisor, supervisor_contract, discompliance))
	}
	
	static sprites_contract = {
		idle_neutral : agi("obj_empty"),
		preview : agi("obj_empty"),
	}
	
	var sprites_discompliance = get_struct_discompliance_with_contract(supervisor.sprites, sprites_contract)
	if array_length(sprites_discompliance.missing) > 0 || array_length(sprites_discompliance.mismatched_types) > 0 {
		throw ($"Supervisor {supervisor_id} from {wod.mod_id} has bad sprite variables!\n" 
			+ generate_discompliance_error_text(supervisor.sprites, sprites_contract, sprites_discompliance))
	}
	
	var idle_neutral_sprite = supervisor.sprites.idle_neutral;

	var optional_sprites = {
		angry : idle_neutral_sprite,
		evil : idle_neutral_sprite,
		head_swivel : idle_neutral_sprite,
		scream : idle_neutral_sprite,
		idle_happy : idle_neutral_sprite,
		idle_sad : idle_neutral_sprite,
		idle_weird : idle_neutral_sprite,
		talk : idle_neutral_sprite,
		sad : idle_neutral_sprite,
		happy : idle_neutral_sprite,
		idle_grimace : idle_neutral_sprite
	}
	initialize_missing(supervisor.sprites, optional_sprites)
	
	supervisor.mod_of_origin = wod;
	supervisor.string_id = supervisor_id
	ds_map_set(wod.supervisors, supervisor_id, supervisor)
	log_info($"Supervisor {supervisor_id} registered to {wod.mod_id}");
	return supervisor;
}


// Called from gml_Object_obj_SupervisorMGMT_Create_0
function register_supervisors_for_gameplay() {
	ds_map_clear(global.supervisor_to_index_map)
	ds_map_clear(global.index_to_supervisor_map)
	
	free_all_allocated_objects(allocatable_objects.supervisor)
	
	var mods = ds_map_values_to_array(global.mod_id_to_mod_map)
	for (var i = 0; i < array_length(mods); i++) {
		var wod = mods[i];
		
		var supervisors = ds_map_values_to_array(wod.supervisors)
		for (var j = 0; j < array_length(supervisors); j++) {		
			with (agi("obj_SupervisorMGMT")) {
				var supervisor_number_id = array_length(SuperVisorName)
				var supervisor = supervisors[j];
				SuperVisorName[supervisor_number_id] = agi("scr_Text")(supervisor.display_name);
				SuperVisorDesc[supervisor_number_id] = agi("scr_Text")(supervisor.description, "\n");
				SVSprite[supervisor_number_id] = supervisor.sprites.preview;
				SuperVisorCol1[supervisor_number_id] = supervisor.name_color;
				SuperVisorCol2[supervisor_number_id] = 255; // Unused as of now
				SVCost[supervisor_number_id] = supervisor.cost;
				
				var obj = allocate_object(allocatable_objects.supervisor, supervisor)
				
				supervisor.object = obj;

				
				log_info($"Supervisor {supervisor.string_id} gameplay registered from mod {supervisor.mod_of_origin.mod_id}")
				ds_map_set(global.supervisor_to_index_map, supervisor, supervisor_number_id)
				ds_map_set(global.index_to_supervisor_map, supervisor_number_id, supervisor)

			}

		}
	}
}
// Called from gml_Object_obj_LvlMGMT_Other_4
function create_mod_supervisor_object(index_id) {
	if !ds_map_exists(global.index_to_supervisor_map, index_id) {
		return;	// Vanilla supervisor
	}

	var obj = ds_map_find_value(global.index_to_supervisor_map, index_id).object
	
	agi("obj_LvlMGMT").SVManager = instance_create_layer(0, 0, "GAME", obj)
	
}

// Called from gml_Object_obj_TonyMGMT_Create_0
function register_supervisors_sprites_for_gameplay() {
	var mods = ds_map_values_to_array(global.mod_id_to_mod_map)
	for (var i = 0; i < array_length(mods); i++) {
		var wod = mods[i];
		var supervisors = ds_map_values_to_array(wod.supervisors)
		for (var j = 0; j < array_length(supervisors); j++) {		
			with (agi("obj_TonyMGMT")) {
				var supervisor = supervisors[j];
				var supervisor_number_id = ds_map_find_value(global.supervisor_to_index_map, supervisor)
				var sprites = supervisor.sprites;
				
				TonyAngrySpr[supervisor_number_id] = sprites.angry
				TonyEvilSpr[supervisor_number_id] = sprites.evil
				TonyHappySpr[supervisor_number_id] = sprites.happy
				TonyHeadSwivelSpr[supervisor_number_id] = sprites.head_swivel
				TonyIdleGrimaceSpr[supervisor_number_id] = sprites.idle_grimace
				TonyIdleHappySpr[supervisor_number_id] = sprites.idle_happy
				TonyIdleNeutralSpr[supervisor_number_id] = sprites.idle_neutral
				TonyIdleSadSpr[supervisor_number_id] = sprites.idle_sad
				TonyIdleWeirdSpr[supervisor_number_id] = sprites.idle_weird
				TonySadSpr[supervisor_number_id] = sprites.sad
				TonyScreamSpr[supervisor_number_id] = sprites.scream
				TonyTalkSpr[supervisor_number_id] = sprites.talk
				
				log_info($"Supervisor {supervisor.string_id} sprites registered from mod {supervisor.mod_of_origin.mod_id}")
			}
		}
	}
}
