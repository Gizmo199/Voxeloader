function voxel_load(_path, _origin=0.5)
{	
	// Can use single alignment as well
	if ( !is_array(_origin) ) _origin = array_create(3, _origin);
	var _align = _origin;
	_align[0] = clamp(_align[0], 0, 1);
	_align[1] = clamp(_align[1], 0, 1);
	_align[2] = clamp(_align[2], 0, 1);
	
	// Static values
	static __palette = undefined;
	if ( __palette == undefined )
	{
		__palette = [];
		repeat(256) array_push(__palette, c_black);
	}
	static __format = undefined;
	if ( __format == undefined )
	{
		vertex_format_begin();
		vertex_format_add_position_3d();
		vertex_format_add_normal();
		vertex_format_add_color();
		__format = vertex_format_end();
	}
	
	// Static functions
	static __buffer_header = function(_buffer, _bytecount=4, _bytetype=buffer_u8){
		var _header = "";
		repeat(_bytecount) _header += chr(buffer_read(_buffer, _bytetype));	
		return _header;
	}
	static __buffer_eof = function(_buffer){
		return ( buffer_tell(_buffer) >= buffer_get_size(_buffer) );	
	}
	static __face = function(_vb, _x, _y, _z, _col, _face_idx=-1)
	{
		static offset_position = [
			[0, 0, 0], 
			[1, 0, 0], 
			[1, 1, 0], 
			[0, 1, 0], 
			[0, 0, 1], 
			[1, 0, 1], 
			[1, 1, 1], 
			[0, 1, 1]  
		];
		static faces = [
			{ t: [0,1,2, 0,2,3], n: [ 0, 0,-1] }, 
			{ t: [5,4,7, 5,7,6], n: [ 0, 0, 1] }, 
			{ t: [4,0,3, 4,3,7], n: [-1, 0, 0] }, 
			{ t: [1,5,6, 1,6,2], n: [ 1, 0, 0] }, 
			{ t: [3,2,6, 3,6,7], n: [ 0, 1, 0] }, 
			{ t: [4,5,1, 4,1,0], n: [ 0,-1, 0] }  
		];
		
		var tri = faces[_face_idx].t;
		var nrm = faces[_face_idx].n;
		var i = 0;
		repeat(6)
		{
			var v = offset_position[tri[i++]];
			vertex_position_3d(_vb, _x+v[0], _y+v[1], _z+v[2]);
			vertex_normal(_vb, nrm[0], nrm[1], nrm[2]);
			vertex_color(_vb, _col[0], _col[1]);
		}
	}
	static __print = function(_message){
		show_debug_message($"[Voxeload] {_message}");	
	}
	static __csnum = function(v){
		var r, i;
		r = string(v)
		i = string_pos(".", r);
		if (i == 0) i = string_length(r) - 2; else i -= 3;
		while (i > 1) {
		    r = string_insert(",", r, i)
		    i -= 3;
		}
		return r;;
	}

	// Load
	var buffer = buffer_load(_path);
	buffer_seek(buffer, buffer_seek_start, 0);
	
	var header = __buffer_header(buffer);
	if ( string_copy(header, 1, 3) != "VOX") {
	    __print($"ERROR! Invalid .vox file '{_path}'...Could not load!");
	    buffer_delete(buffer);
	    return undefined;
	}
		
	var version = buffer_read(buffer, buffer_u32);
	__print($"Loading '{filename_name(_path)}' - Version {version}...");
		
	var voxels  = [];
	var palette = array_create(256);
	var bbox = 
	{
		x : [9999, -9999],
		y : [9999, -9999],
		z : [9999, -9999]
	}
	
	var _start_time = current_time;
	while (!__buffer_eof(buffer)) {
	    var chunk_id = __buffer_header(buffer);
	    if (string_length(chunk_id) < 4) break;
		
	    var chunk_size  = buffer_read(buffer, buffer_u32);
	    var child_size  = buffer_read(buffer, buffer_u32);
	    var chunk_start = buffer_tell(buffer);
		
	    switch (chunk_id)
	    {
	    	case "MAIN": break;
	    	case "XYZI":
				var i = 0;
	    	    var num_voxels = buffer_read(buffer, buffer_u32);
				repeat(num_voxels)
				{
	    	        var vx = buffer_read(buffer, buffer_u8);
	    	        var vy =-buffer_read(buffer, buffer_u8);
	    	        var vz = buffer_read(buffer, buffer_u8);
	    	        var ci = buffer_read(buffer, buffer_u8);
					if( ci == 0 ) continue;
	    	        array_push(voxels, [vx, vy, vz, ci]);
					bbox.x = [min(bbox.x[0], vx), max(bbox.x[1], vx+1)]; 
					bbox.y = [min(bbox.y[0], vy), max(bbox.y[1], vy+1)]; 
					bbox.z = [min(bbox.z[0], vz), max(bbox.z[1], vz+1)]; 
	    	    }
	    	    break;
	    	case "RGBA":
				var i = 0;
				repeat(256)
				{
	    	        var r = buffer_read(buffer, buffer_u8);
	    	        var g = buffer_read(buffer, buffer_u8);
	    	        var b = buffer_read(buffer, buffer_u8);
	    	        var a = buffer_read(buffer, buffer_u8);
	    	        palette[i++] = [make_color_rgb(r,g,b), a];
	    	    }
	    	    break;
	    	default: // Unused headers
	    	    buffer_seek(buffer, buffer_seek_start, chunk_start + chunk_size);
	    	    break;
	    }
		
	    // Skip any child chunks automatically
	    if ( chunk_id != "MAIN" ) buffer_seek(buffer, buffer_seek_start, chunk_start + chunk_size + child_size);
	}
	
	// Calculate bounding box width, height & depth
	var _width = abs(bbox.x[1] - bbox.x[0]);
	var _height= abs(bbox.z[1] - bbox.z[0]);
	var _depth = abs(bbox.y[1] - bbox.y[0]);
	
	// Correct orientation based on alignment
	var _ox = -bbox.x[0];
	var _oy = -bbox.y[0];
	var _oz = -bbox.z[0];	
	bbox.x[0] += _ox - ( _width * _align[0] );
	bbox.x[1] += _ox - ( _width * _align[0] );
	bbox.y[0] += _oy - ( _depth * _align[1] );
	bbox.y[1] += _oy - ( _depth * _align[1] );
	bbox.z[0] += _oz - ( _height* _align[2] );
	bbox.z[1] += _oz - ( _height* _align[2] );
	
	// Time capture
	var _load_time = ( current_time - _start_time ) / 1000;
	var _total_time = _start_time;
	var _start_time = current_time;
	
	// Build
	var vb = vertex_create_buffer();
	vertex_begin(vb, __format);
			
	var i = 0;
	var s = array_length(voxels);
	repeat(s)
	{
		var v = voxels[i++];
		var _x = v[0] + ( _ox - _width * _align[0] );
		var _y = v[1] + ( _oy - _depth * _align[1] );
		var _z = v[2] + ( _oz - _height* _align[2] );
		var _c = palette[v[3] - 1];
		
		// Bulid faces
		__face(vb, _x, _y, _z, _c, 0);
		__face(vb, _x, _y, _z, _c, 1);
		__face(vb, _x, _y, _z, _c, 2);
		__face(vb, _x, _y, _z, _c, 3);
		__face(vb, _x, _y, _z, _c, 4);
		__face(vb, _x, _y, _z, _c, 5);
	}
	var _build_time = (current_time - _start_time)/1000;
	var _total_time = (current_time - _total_time)/1000;
	
	__print($"Built {__csnum(i)} voxels successfully!\n    > Loading : {_load_time}s | Building : {_build_time}s | Total : {_total_time}s");
	vertex_end(vb);
	vertex_freeze(vb);
	return 
	{
		width	: _width,
		height	: _height,
		depth	: _depth,
		buffer	: vb,
		bbox	: bbox
	};
}
