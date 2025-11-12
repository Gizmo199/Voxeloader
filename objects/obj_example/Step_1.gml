// Set aspect ratio
ASPECT = window_get_width()/window_get_height();

// Set mouse look
locked ^= keyboard_check_pressed(vk_escape);
window_mouse_set_locked(locked);
if ( locked )
{
	rotation.z += window_mouse_get_delta_x() * sens * ( invert_x ? -1 : 1 );
	rotation.x += window_mouse_get_delta_y() * sens * ( invert_y ? -1 : 1 );
	rotation.x = clamp(rotation.x, -89, 89);
}

// Set distance if 3rd person
if ( third_person )
{
	distance += ( mouse_wheel_down() - mouse_wheel_up() ) * ( 1/sens );
	distance = max(distance, 16);
}

// Set Debug
if ( keyboard_check_pressed(vk_space) ) 
{
	var _filepath = get_open_filename("*.vox", "");
	if( _filepath != "" )
	{
		var _newmesh = voxel_load(_filepath, origin);
		if( _newmesh != undefined )
		{
			voxel_delete(voxel);	
			voxel = _newmesh;
		}
	}
}
debug ^= keyboard_check_pressed(ord("D"));