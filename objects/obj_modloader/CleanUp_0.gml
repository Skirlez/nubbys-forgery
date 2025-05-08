clear_all_mods();

ds_map_destroy(global.allocated_objects)
ds_map_destroy(global.modloader_game_events)

ds_map_destroy(global.item_id_to_index_map)
ds_map_destroy(global.index_to_item_id_map)

ds_map_destroy(global.perk_id_to_index_map)
ds_map_destroy(global.index_to_perk_id_map)

ds_map_destroy(global.supervisor_to_index_map)
ds_map_destroy(global.index_to_supervisor_map)


ds_map_destroy(global.mod_id_to_mod_map)

log_info("Modloader Clean Up Event done")