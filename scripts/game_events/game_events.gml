global.modloader_game_events = ds_map_create();

function mod_subscribe_to_game_event(name, callback, wod = global.cmod) {
	var arr;
	if !ds_map_exists(global.modloader_game_events, name) {
		arr = []
		ds_map_add(global.modloader_game_events, name, arr)
	}
	else
		arr = ds_map_find_value(global.modloader_game_events, name)
	
	array_push(wod.callback_records, {
		game_event_name : name,
		callback : callback 
	});
	array_push(arr, { 
		mod_of_origin : wod,
		callback : callback,
	});
}

// Called from scr_GameEv
function on_game_event(name, parameter_struct) {
	if !ds_map_exists(global.modloader_game_events, name)
		return;
	var arr = ds_map_find_value(global.modloader_game_events, name)
	for (var i = 0; i < array_length(arr); i++) {
		var struct = arr[i];
		global.cmod = struct.mod_of_origin;
		try {
			struct.callback(parameter_struct);
		}
		catch (e) {
			log_error($"Mod ${struct.mod_of_origin.mod_id} errored on {name} Game Event callback: {pretty_error(e)}")
		}
	}
}