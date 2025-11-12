function voxel_submit(_voxel, _debug=false){
	
	// Statics
	static __voxel_bbox_line = function(_vb, _x1, _y1, _z1, _x2, _y2, _z2, _color=c_white){
		vertex_position_3d(_vb, _x1, _y1, _z1);
		vertex_color(_vb, _color, 1);
		vertex_position_3d(_vb, _x2, _y2, _z2);
		vertex_color(_vb, _color, 1);
	}
	static __voxel_bbox_format = undefined;
	static __voxel_bbox_buffer = undefined;
	static __voxel_bbox_origin = undefined;
	
	// Normal rendering
	with ( _voxel )
	{
		vertex_submit(buffer, pr_trianglelist, -1);
	
		// Debug box rendering
		if ( !_debug ) return;
		if ( __voxel_bbox_format == undefined or __voxel_bbox_buffer == undefined or __voxel_bbox_origin == undefined )
		{
			vertex_format_begin();
			vertex_format_add_position_3d();
			vertex_format_add_color();
			__voxel_bbox_format = vertex_format_end();
		
			__voxel_bbox_buffer = vertex_create_buffer();
			vertex_begin(__voxel_bbox_buffer, __voxel_bbox_format);
			__voxel_bbox_line(__voxel_bbox_buffer, -0.5, -0.5, -0.5,  0.5, -0.5, -0.5);
			__voxel_bbox_line(__voxel_bbox_buffer,  0.5, -0.5, -0.5,  0.5, -0.5,  0.5);
			__voxel_bbox_line(__voxel_bbox_buffer,  0.5, -0.5,  0.5, -0.5, -0.5,  0.5);
			__voxel_bbox_line(__voxel_bbox_buffer, -0.5, -0.5,  0.5, -0.5, -0.5, -0.5);
			__voxel_bbox_line(__voxel_bbox_buffer, -0.5, 0.5, -0.5,  0.5, 0.5, -0.5);
			__voxel_bbox_line(__voxel_bbox_buffer,  0.5, 0.5, -0.5,  0.5, 0.5,  0.5);
			__voxel_bbox_line(__voxel_bbox_buffer,  0.5, 0.5,  0.5, -0.5, 0.5,  0.5);
			__voxel_bbox_line(__voxel_bbox_buffer, -0.5, 0.5,  0.5, -0.5, 0.5, -0.5);
			__voxel_bbox_line(__voxel_bbox_buffer, -0.5, -0.5, -0.5, -0.5, 0.5, -0.5);
			__voxel_bbox_line(__voxel_bbox_buffer,  0.5, -0.5, -0.5,  0.5, 0.5, -0.5);
			__voxel_bbox_line(__voxel_bbox_buffer,  0.5, -0.5,  0.5,  0.5, 0.5,  0.5);
			__voxel_bbox_line(__voxel_bbox_buffer, -0.5, -0.5,  0.5, -0.5, 0.5,  0.5);
			vertex_end(__voxel_bbox_buffer);
			vertex_freeze(__voxel_bbox_buffer);
		
			__voxel_bbox_origin = vertex_create_buffer();
			vertex_begin(__voxel_bbox_origin, __voxel_bbox_format);
			__voxel_bbox_line(__voxel_bbox_origin, 0, 0, 0, 4, 0, 0, c_red);
			__voxel_bbox_line(__voxel_bbox_origin, 0, 0, 0, 0, 4, 0, c_lime);
			__voxel_bbox_line(__voxel_bbox_origin, 0, 0, 0, 0, 0, 4, c_blue);
			vertex_end(__voxel_bbox_origin);
			vertex_freeze(__voxel_bbox_origin);
		}	
	
		var _shader = shader_current();
		var _worldm = matrix_get(matrix_world);
		var _gpu_test = gpu_get_ztestenable();
		shader_reset();
		gpu_set_ztestenable(false);
		var _matrix = matrix_build(bbox.x[0] + width/2, bbox.y[0] + depth/2, bbox.z[0] + height/2, 0, 0, 0, width, depth, height);
	
		// Bounding Box
		matrix_set(matrix_world, matrix_multiply(_matrix, _worldm));
		vertex_submit(__voxel_bbox_buffer, pr_linelist, -1);
	
		// Orientation & Origin
		matrix_set(matrix_world, _worldm);
		vertex_submit(__voxel_bbox_origin, pr_linelist, -1);
	
		// Reset
		gpu_set_ztestenable(_gpu_test);
		shader_set(_shader);
	}
	

}