/// @function draw_sprite_anchored_ext(sprite,subimg,x,y,xscale,yscale,rot,col,alpha,xoff,yoff)
/// @description Draws a sprite at an anchored offset.
/// @param {Asset.GMSprite} spr The sprite to draw.
/// @param {Real} sub The subimage (frame) to draw.
/// @param {Real} _x The x position to draw the sprite at.
/// @param {Real} _y The y position to draw the sprite at.
/// @param {Real} xs The width to draw the sprite.
/// @param {Real} ys The height to draw the sprite.
/// @param {Real} rot The angle to draw the sprite.
/// @param {Constant.Color} col The multiplied color to apply to the sprite.
/// @param {Real} alpha The opacity to draw the image at.
/// @param {Real} xoff The x origin offset to draw at. If the image is centered, it ranges from -0.5 to 0.5.
/// @param {Real} yoff The y origin offset to draw at. If the image is centered, it ranges from -0.5 to 0.5.

function draw_sprite_anchored_ext(spr,sub,_x,_y,xs,ys,rot,col,alpha,xoff,yoff) {
	var x_scale = sprite_get_width(spr)*xs;
	var y_scale = sprite_get_height(spr)*ys;
	
	var true_x = _x;
	var true_y = _y;
	
	true_x += lengthdir_x(x_scale*xoff,rot);
	true_y += lengthdir_y(x_scale*xoff,rot);
	
	true_x += lengthdir_x(y_scale*yoff,rot+90);
	true_y += lengthdir_y(y_scale*yoff,rot+90);
	
	draw_sprite_ext(spr,sub,true_x,true_y,xs,ys,rot,col,alpha);
}
