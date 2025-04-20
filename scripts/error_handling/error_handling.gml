/*
function optional_empty() constructor {
	self.get = method(self, function() {
		throw ("Called get() on an empty optional!")
	});
	self.get_or_else = method(self, function(else_var) {
		return else_var;
	});
	self.is_empty = method(self, function() {
		return true;
	});
}
function optional_value(val) constructor {
	self.val = val;
	self.get = method(self, function() {
		return val;
	});
	self.get_or_else = method(self, function(else_var) {
		return val;
	});
	self.is_empty = method(self, function() {
		return false;
	});
}
*/

function result_ok(value) constructor {
	self.value = value;
	self.is_error = function() {
		return false;	
	}
}
function result_error(error) constructor {
	self.error = error;
	self.is_error = function() {
		return true;	
	}
}


function generic_error(text) constructor {
	self.text = text;
}
function error_with_id(error_id) constructor {
	self.error_id = error_id;
}

function log(text) {
	// TODO
	show_debug_message(text)
	show_message(text)
	
}