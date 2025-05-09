// This object is cloned by the merger script a lot, but all of them run the same event code.

// We need to determine at runtime what number object we are:
allocated_id = real(string_digits(object_get_name(object_index)))

// These objects are allocated to different items.
// Get the perk this object is allocated to
perk = get_allocated_object(allocatable_objects.perk, allocated_id)
// This perk struct determines how this object behaves.

// Get the perk's index ID
MyPerkID = ds_map_find_value(global.perk_id_to_index_map, get_full_id(perk))

show_message(string(MyPerkID))

EvType = agi("obj_PerkMGMT").PerkTrigger[MyPerkID]
MyDesc = agi("obj_PerkMGMT").PerkDesc[MyPerkID]
RndFireNum = 0
GameFireNum = 0
DisablePerk = 0
PerkQueue = ds_list_create()
WhatSlot = -1

try {
	global.currently_executing_mod = perk.mod_of_origin;
	catspeak_execute_ext(perk.on_create, self)
}
catch (e) {
	log_error($"Perk {perk.string_id} errored on creation: {e}")
	// TODO disable perk
}