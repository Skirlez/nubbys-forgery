// This object is cloned by the merger script a lot, but all of them run the same event code.

// We need to determine at runtime what number object we are:
allocated_id = real(string_digits(object_get_name(object_index)))

// These objects are allocated to different items.
// Get the perk this object is allocated to
perk = get_resource_allocated_to_object(mod_resources.perk, allocated_id)
// This perk struct determines how this object behaves.

// Get the perk's index ID
MyPerkID = bimap_get_left(global.index_registry[mod_resources.perk], perk)

// Get its string ID, for logging
string_id = bimap_get_left(global.registry[mod_resources.perk], perk)

mod_of_origin = ds_map_find_value(global.mod_id_to_mod_map, mod_identifier_get_namespace(string_id))


EvType = agi("obj_PerkMGMT").PerkTrigger[MyPerkID]
MyDesc = agi("obj_PerkMGMT").PerkDesc[MyPerkID]
RndFireNum = 0
GameFireNum = 0
DisablePerk = 0
PerkQueue = ds_list_create()
WhatSlot = -1

global.currently_executing_mod = mod_of_origin;
try {
	catspeak_execute_ext(perk.on_create, self)
}
catch (e) {
	log_error($"Perk {string_id} errored on creation: {pretty_error(e)}")
	// TODO disable perk
}