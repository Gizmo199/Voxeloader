angle += !locked;
matrix_build(0, 0, 0, 0, 0, angle, 1, 1, 1, mat);
matrix_set(matrix_world, mat);
shader_set(sh_voxel);
voxel_submit(voxel, debug);
