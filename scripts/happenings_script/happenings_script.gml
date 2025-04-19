/* Happenings
A happening object represents an in-game event. Instances may create happenings, and anyone can then subscribe
to the happening, supplying a callback function. When the happening is triggered, the callbacks will all be called.

You are allowed to subscribe more than once to a happening with the same function. It will do nothing.

A list of happenings can be found in TODO
*/

global.happenings = ds_map_create();

function happening_struct() constructor {
	self.callbacks = []
	function subscribe(callback) {
		if (array_contains(callbacks, callback))
			return;
		array_push(callbacks, callback)
	}
	function unsubscribe(callback) {
		for (var i = 0; i < array_length(callbacks); i++) {
			if (callbacks[i] == callback) {
				array_delete(callbacks, i, 1)
				return;
			}
		}
	}
	
	function trigger(struct) {
		for (var i = 0; i < array_length(callbacks); i++) {
			callbacks[i](struct);
		}
	}
}

function register_happening(name) {
	var happening = new happening_struct();
	ds_map_add(global.happenings, name, happening)
	return happening;
}
function get_happening(name) {
	return ds_map_find_value(global.happenings, name);
}