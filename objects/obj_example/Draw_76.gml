// Set position
var px = x, py = y, pz = z;
var _perspectiveScale = ( third_person ? -distance : distance );
var lx = px + ( dcos(rotation.z) * dcos(rotation.x) * _perspectiveScale );
var ly = py + ( dsin(rotation.z) * dcos(rotation.x) * _perspectiveScale );
var lz = pz + ( dsin(rotation.x) * _perspectiveScale );

// Swap look at and look from
if ( third_person )
{
	px = lx;
	py = ly;
	pz = lz;
	lx = x;
	ly = y;
	lz = z;
}		

// Smooth look
if ( smoothing > 0 ) 
{
	lookat.x = lerp(lookat.x, lx, smoothing);
	lookat.y = lerp(lookat.y, ly, smoothing);
	lookat.z = lerp(lookat.z, lz, smoothing);
	position.x = lerp(position.x, px, smoothing);
	position.y = lerp(position.y, py, smoothing);
	position.z = lerp(position.z, pz, smoothing);
}
else
{
	lookat.x = lx;
	lookat.y = ly;
	lookat.z = lz;
	position.x = px;
	position.y = py;
	position.z = pz;
}
	
// Set matrices
matrix_build_projection_perspective_fov(-FOV, -ASPECT, NEAR, FAR, PROJ);
matrix_build_lookat(position.x, position.y, position.z, lookat.x, lookat.y, lookat.z, up.x, up.y, up.z, VIEW);


// Apply matrices to camera
matrix_inverse(VIEW, INV_VIEW);
matrix_inverse(PROJ, INV_PROJ);
camera_set_view_mat(view_camera[0], VIEW);
camera_set_proj_mat(view_camera[0], PROJ);