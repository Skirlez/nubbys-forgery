// This object is cloned by the merger script a lot, but all of them run the same event code.

// We need to determine at runtime what number object we are:
allocated_id = real(string_digits(object_get_name(object_index)))

// These objects are allocated to different items.
// Get the item this object is allocated to
item = get_resource_allocated_to_object(mod_resources.item, allocated_id)
// This item struct determines how this object behaves.

// Get the item's index ID
MyItemID = bimap_get_left(global.index_registry[mod_resources.item], item)

// Get its string ID, for logging
string_id = bimap_get_left(global.registry[mod_resources.item], item)

mod_of_origin = ds_map_find_value(global.mod_id_to_mod_map, mod_identifier_get_namespace(string_id))

// The following variables are set before create, so modders can override if they want to for some reason
EvType = agi("obj_ItemMGMT").ItemTrig[MyItemID]
EvTypeAlt = "Empty"
EvTypeExt = "Empty"
if instance_exists(agi("obj_SV4Manager")) {
    EvTypeAlt = agi("obj_ItemMGMT").MutantTrig[MyItemID]
}
MyDesc = -1
//ItemLevel = 1
// Keep in mind, after merging, this object does inherit from obj_ItemParent,
// so this may seem like it does nothing in the IDE, this does do something after merging.
alarm_set(10, 1)
TrigLimit = -1
WhatSlot = -1
ItemQueue = ds_list_create()
RndFireNum = 0
PrevTurnFireNum = 0;
GameFireNum = 0
ItemTemporary = 0
DisableItem = 0
RoundsAlive = 0

ItemLevel = item.level - 1 // This is actually set manually for items, seemingly. Automated here.
if (ItemLevel == 1)
    alarm_set(6, 1)

MyItemBacker = -1
global.currently_executing_mod = mod_of_origin;
try {
	catspeak_execute_ext(item.on_create, self)
}
catch (e) {
	log_error($"Item {string_id} errored on creation: {pretty_error(e)}")
	// TODO disable item
}