// This object is meant to be used by modders if they want to add an object to their game.
// It has events for almost everything you'd need from a regular object.
wod = global.cmod;
if name == ""
	error_string = $"Functional object from {wod.mod_id} errored on"
else
	error_string = $"Functional object from {wod.mod_id} with given name {name} errored on"

if on_create == noone
	exit;
try {
	execute(on_create, id)
}
catch (e) {
	log_error($"{error_string} Create and will destroy itself: {pretty_error(e)}")
	instance_destroy(id)
}

