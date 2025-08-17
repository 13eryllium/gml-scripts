function read_and_parse(filename) {
	if (!file_exists(filename)) {
		show_debug_message("ERROR: File " + filename + " does not exist");
		return -1;
	}
	
	var buffer = buffer_load(filename);
	if (buffer == -1) {
		show_debug_message("ERROR: Failed to load file " + filename + " into buffer");
		return -1;
	}
	
	var json_string = buffer_read(buffer, buffer_text);
	buffer_delete(buffer);

	try {
		var json_data = json_parse(json_string);
		return json_data;
	} catch (e) {
		show_debug_message("ERROR: Failed to parse JSON from file " + filename + ": " + string(e));
		return -1;
	}
}
