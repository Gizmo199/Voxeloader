// Camera macros
#macro VIEW				global.__VIEW
#macro PROJ				global.__PROJ
#macro INV_VIEW			global.__INV_VIEW
#macro INV_PROJ			global.__INV_RPOJ
#macro FOV				global.__FOV
#macro ASPECT			global.__ASPECT
#macro NEAR				1
#macro FAR				2048

// Set macros
INV_VIEW = matrix_build_identity();
INV_PROJ = matrix_build_identity();
VIEW = matrix_build_identity();
PROJ = matrix_build_identity();
FOV = 60;
ASPECT = 16/9;

// Set camera values
z = 0;
locked = false;
sens = 0.1;
lookat = { x : x, y : y, z : z };
rotation = { x : 0, y : 0, z : 0 };
position = { x : x, y : y, z : z };
up = { x : 0, y : 0, z : 1 };
distance = 64;
third_person = true; 
invert_y = true;
invert_x = false;
smoothing = 0;
free_movement = false;
matrix_default = matrix_build_identity();

// View and 3D
view_enabled = true;
view_visible[0] = true;
layer_force_draw_depth(true, 0);
gpu_set_ztestenable(true);
gpu_set_zwriteenable(true);
display_reset(4, true);

// Voxel
mat = matrix_build_identity();
origin = [0.5, 0.5, 0.5]; //<- can also just be '0.5' for all 3 axes. 
voxel = voxel_load("knight.vox", origin); 
debug = false;
angle = 0;