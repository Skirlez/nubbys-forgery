/*
This function returns a struct like so:
{
	missing (array)
	mismatched_types (array)
}
the missing array contains variable names that are present on the contract struct, but
missing on the struct parameter.

the mismatched types contains variable names that are present on both structs,
but have different types.
*/
function get_struct_discompliance_with_contract(struct, contract_struct) {
	var discompliance = {
		missing : [],
		mismatched_types : [],
	};
	var arr = struct_get_names(contract_struct)
	for (var i = 0; i < array_length(arr); i++) {
		var variable_name = arr[i];
		if !variable_struct_exists(struct, variable_name)
			array_push(discompliance.missing, variable_name)
		else if typeof(contract_struct[$ variable_name]) != typeof(struct[$ variable_name])
			array_push(discompliance.mismatched_types, variable_name)
	}
	return discompliance;
}

function generate_discompliance_error_text(struct, contract_struct, discompliance) {
	var text = ""
	for (var i = 0; i < array_length(discompliance.missing); i++) {
		text += $"Missing variable: {discompliance.missing[i]}\n";	
	}
	for (var i = 0; i < array_length(discompliance.mismatched_types); i++) {
		var variable_name = discompliance.mismatched_types[i];
		text += $"Mismatched types for variable {variable_name}: "
			+ $"got {typeof(struct[$ variable_name])}, but expected {typeof(contract_struct[$ variable_name])}\n"
	}
	string_delete(text, string_length(text), 1) // remove trailing newline
	return text;
}
function initialize_missing(struct, optional_struct) {
	var arr = struct_get_names(optional_struct)
	for (var i = 0; i < array_length(arr); i++) {
		var variable_name = arr[i];
		if !variable_struct_exists(struct, variable_name)
			struct[$ variable_name] = optional_struct[$ variable_name]
	}
}
