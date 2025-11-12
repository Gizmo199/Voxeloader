if ( !locked or !free_movement ) exit;
var ix = ( keyboard_check(ord("D")) - keyboard_check(ord("A")) );
var iy = ( keyboard_check(ord("S")) - keyboard_check(ord("W")) );
var ir = keyboard_check(vk_shift);
var md = point_direction(0, 0, ix, iy) - rotation.z - 90;
if ( point_distance(0, 0, ix, iy) > 0 )
{
	x += dcos(md) * ( 1 + ir );
	y -= dsin(md) * ( 1 + ir );
}