# GML Scripts
A repository of GML scripts I've made.

# Drawing
### [draw_sprite_anchored_ext()](https://github.com/13eryllium/gml-scripts/blob/9e4363f2e4a52d2fb067001b23697e5dc70fb282/scripts/draw_sprite_anchored.gml)
#### draw_sprite_anchored_ext(sprite,subimg,x,y,xscale,yscale,rot,col,alpha,xoff,yoff)
#####
```gml
draw_sprite_anchored_ext(spr_cat,0,x,y,image_xscale,image_yscale,image_angle,image_blend,image_alpha,0.5,0);
```
Draws a sprite at an anchored offset.

# Libraries
## [Icoso](https://github.com/13eryllium/gml-scripts/blob/e8a9b1674c06b117e2beea961a45325c323eeaf4/scripts/icoso.gml)
###### A GML string parser
##### not finished, bugs are present. known bugs include:
###### negatives not working
###### decimals not working
### icoso_parse(expression)
#### Evaluates a mathematical or functional expression string, supporting numbers, strings, operators, and function calls.

```gml
icoso_parse("2 + 2")  // Returns 4
icoso_parse("concat('hello', '2')")  // Returns "hello2"
```

### icoso_reveal(internal_name, function_ref, args_count)
#### Registers a function to be used within ICOSO expressions.

```gml
function add(a, b) { return a + b; }
icoso_reveal("add", add, 2)
```

### icoso_reveal_global(var_name, var_to_read)
#### Exposes a global variable to be read in ICOSO expressions.

```gml
global.health = 100
icoso_reveal_global("health", "global.health")
```

### icoso_add_variable(var_name, expression)
#### Creates a variable that evaluates to an expression result.

```gml
icoso_add_variable("double_health", "health * 2")
```
