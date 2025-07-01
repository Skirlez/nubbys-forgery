// TARGET: LINENUMBER
// 28
// Prevent loading save if mods are missing
if (array_length(missing_resources) > 0) {
	mod_message = load_button_create_message(missing_resources)
}
else

// TARGET: HEAD
// Prevent pressing on the button while the notice exists
if instance_exists(mod_message) {
	mask_index = spr_empty
}
else
	mask_index = sprite_index