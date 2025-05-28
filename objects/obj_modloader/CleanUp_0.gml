clear_all_mods();

ds_map_destroy(global.modloader_game_events)
hashset_destroy(global.disallowed_functions_set)

registry_destroy(global.registry)
registry_destroy(global.index_registry)
ds_map_destroy(global.mod_id_to_mod_map)

log_info("Modloader Clean Up Event done")