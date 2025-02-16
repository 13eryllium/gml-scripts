global.icoso_functions = ds_map_create();
global.icoso_function_args = ds_map_create();
global.icoso_variables = ds_map_create();
global.icoso_variable_expressions = ds_map_create();

function icoso_reveal(internal_name, function_ref, args_count) {
    ds_map_add(global.icoso_functions, internal_name, function_ref);
    ds_map_add(global.icoso_function_args, internal_name, args_count);
}

function icoso_reveal_global(var_name, var_to_read) {
    ds_map_add(global.icoso_variables, var_name, var_to_read);
}

function icoso_add_variable(var_name, expression) {
    ds_map_add(global.icoso_variable_expressions, var_name, expression);
}

function icoso_get_variable_value(var_path) {
    if (string_copy(var_path, 1, 7) == "global.") {
        var var_name = string_delete(var_path, 1, 7);
        return variable_global_get(var_name);
    }
    return 0;
}

function icoso_parse(str) {
    str = string_replace_all(str, " ", "");
    var tokens = [];
    var current_token = "";
    var in_string = false;
    var i = 0;
    
    while (i < string_length(str)) {
        var char = string_char_at(str, i + 1);
        
        if (char == "'") {
            if (in_string) {
                current_token += char;
                array_push(tokens, current_token);
                current_token = "";
                in_string = false;
            } else {
                if (string_length(current_token) > 0) {
                    array_push(tokens, current_token);
                    current_token = "";
                }
                current_token = char;
                in_string = true;
            }
        }
        else if (in_string) {
            current_token += char;
        }
        else if (char == "+" || char == "-" || char == "*" || char == "/" || char == "(" || char == ")" || char == "^" || char == ",") {
            if (string_length(current_token) > 0) {
                array_push(tokens, current_token);
                current_token = "";
            }
            array_push(tokens, char);
        }
        else {
            current_token += char;
        }
        i++;
    }
    
    if (string_length(current_token) > 0) {
        array_push(tokens, current_token);
    }
    
    return icoso_evaluate(tokens);
}

function icoso_evaluate(tokens) {
    var output_queue = ds_queue_create();
    var operator_stack = ds_stack_create();
    var arg_count_stack = ds_stack_create();
    
    var precedence = ds_map_create();
    ds_map_add(precedence, "+", 1);
    ds_map_add(precedence, "-", 1);
    ds_map_add(precedence, "*", 2);
    ds_map_add(precedence, "/", 2);
    ds_map_add(precedence, "^", 3);
    
    for (var i = 0; i < array_length(tokens); i++) {
        var token = tokens[i];
        
        if (string_char_at(token, 1) == "'") {
            ds_queue_enqueue(output_queue, token);
        }
        else if (string_digits(token) == token || 
            (string_length(token) > 1 && string_char_at(token, 1) == "-" && 
             string_digits(string_delete(token, 1, 1)) == string_delete(token, 1, 1))) {
            ds_queue_enqueue(output_queue, real(token));
        }
        else if (ds_map_exists(global.icoso_functions, token)) {
            ds_stack_push(operator_stack, token);
            ds_stack_push(arg_count_stack, 1);
        }
        else if (ds_map_exists(global.icoso_variables, token)) {
            var var_path = ds_map_find_value(global.icoso_variables, token);
            var value = icoso_get_variable_value(var_path);
            ds_queue_enqueue(output_queue, value);
        }
        else if (ds_map_exists(global.icoso_variable_expressions, token)) {
            var expression = ds_map_find_value(global.icoso_variable_expressions, token);
            var value = icoso_parse(expression);
            ds_queue_enqueue(output_queue, value);
        }
        else if (token == ",") {
            while (!ds_stack_empty(operator_stack) && ds_stack_top(operator_stack) != "(") {
                ds_queue_enqueue(output_queue, ds_stack_pop(operator_stack));
            }
            if (!ds_stack_empty(arg_count_stack)) {
                var current_count = ds_stack_pop(arg_count_stack);
                ds_stack_push(arg_count_stack, current_count + 1);
            }
        }
        else if (ds_map_exists(precedence, token)) {
            while (!ds_stack_empty(operator_stack) &&
                   ds_map_exists(precedence, ds_stack_top(operator_stack)) &&
                   precedence[? ds_stack_top(operator_stack)] >= precedence[? token]) {
                ds_queue_enqueue(output_queue, ds_stack_pop(operator_stack));
            }
            ds_stack_push(operator_stack, token);
        }
        else if (token == "(") {
            ds_stack_push(operator_stack, token);
        }
        else if (token == ")") {
            while (!ds_stack_empty(operator_stack) && ds_stack_top(operator_stack) != "(") {
                ds_queue_enqueue(output_queue, ds_stack_pop(operator_stack));
            }
            if (!ds_stack_empty(operator_stack)) {
                ds_stack_pop(operator_stack);
                
                if (!ds_stack_empty(operator_stack) && 
                    ds_map_exists(global.icoso_functions, ds_stack_top(operator_stack))) {
                    var func = ds_stack_pop(operator_stack);
                    var actual_args = 1;
                    if (!ds_stack_empty(arg_count_stack)) {
                        actual_args = ds_stack_pop(arg_count_stack);
                    }
                    ds_queue_enqueue(output_queue, [func, actual_args]);
                }
            }
        }
    }
    
    while (!ds_stack_empty(operator_stack)) {
        ds_queue_enqueue(output_queue, ds_stack_pop(operator_stack));
    }
    
    var eval_stack = ds_stack_create();
    
    while (!ds_queue_empty(output_queue)) {
        var token = ds_queue_dequeue(output_queue);
        
        if (is_real(token)) {
            ds_stack_push(eval_stack, token);
        }
        else if (is_string(token) && string_char_at(token, 1) == "'") {
            var str_value = string_copy(token, 2, string_length(token) - 2);
            ds_stack_push(eval_stack, str_value);
        }
        else if (is_array(token)) {
            var func_name = token[0];
            var arg_count = token[1];
            var args = array_create(arg_count);
            
            for (var j = arg_count - 1; j >= 0; j--) {
                if (!ds_stack_empty(eval_stack)) {
                    args[j] = ds_stack_pop(eval_stack);
                }
            }
            
            var func = ds_map_find_value(global.icoso_functions, func_name);
            var result = script_execute_ext(func, args);
            ds_stack_push(eval_stack, result);
        }
        else if (ds_map_exists(precedence, token)) {
            if (ds_stack_size(eval_stack) >= 2) {
                var b = ds_stack_pop(eval_stack);
                var a = ds_stack_pop(eval_stack);
                
                var result = 0;
                if (is_string(a) || is_string(b)) {
                    if (token == "+") {
                        result = string(a) + string(b);
                    } else {
                        result = 0;
                    }
                } else {
                    switch (token) {
                        case "+": result = a + b; break;
                        case "-": result = a - b; break;
                        case "*": result = a * b; break;
                        case "/": result = a / b; break;
                        case "^": result = power(a, b); break;
                    }
                }
                ds_stack_push(eval_stack, result);
            }
        }
    }
    
    var final_result = 0;
    if (!ds_stack_empty(eval_stack)) {
        final_result = ds_stack_pop(eval_stack);
    }
    
    ds_queue_destroy(output_queue);
    ds_stack_destroy(operator_stack);
    ds_stack_destroy(eval_stack);
    ds_stack_destroy(arg_count_stack);
    ds_map_destroy(precedence);
    
    return final_result;
}