function optional(val = pointer_invalid) constructor {
	self.val = val;

	if (val != pointer_invalid) {
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
	else {
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
}
function result_ok(value) constructor {
	self.value = value;
	self.get = method(self, function() {
		return value;
	});
}
function result_error(error) constructor {
	self.error = error;
	self.get = method(self, function() {
		throw ("Called get() on an error result!\n" + error.get())
	});
}

function error(text) constructor {
	self.text = text;
}