// This object is meant to be used by modders if they want to add an object to their game.
// It has events for almost everything you'd need from a regular object.
wod = global.currently_executing_mod;
if name == ""
	error_string = $"Functional object from {wod.mod_id} errored on"
else
	error_string = $"Functional object from {wod.mod_id} with given name {name} errored on"

if on_create == noone
	exit;
try {
	catspeak_execute_ext(on_create, self)
}
catch (e) {
	log_error($"{error_string} Create and will destroy itself: {e.message}")
	instance_destroy(id)
}

