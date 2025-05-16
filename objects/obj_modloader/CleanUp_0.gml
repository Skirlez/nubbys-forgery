clear_all_mods();

ds_map_destroy(global.modloader_game_events)

for (var i = 0; i < array_length(global.indexed_resources); i++) {
	bimap_destroy(global.indexed_resources[i]);
}
ds_map_destroy(global.mod_id_to_mod_map)

log_info("Modloader Clean Up Event done")