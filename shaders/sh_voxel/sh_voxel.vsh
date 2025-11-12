// NOTE : Voxels do not have texture coordinates, only colors, normals, and position!
attribute vec3 in_Position;                
attribute vec3 in_Normal;                
attribute vec4 in_Colour;           

varying vec4 v_color;
varying vec3 v_normal;
void main()
{
    vec4 osp = vec4(in_Position, 1.0);
	vec4 osn = vec4(in_Normal, 0.0);
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * osp;
    v_color = in_Colour;
	v_normal = normalize(vec3(gm_Matrices[MATRIX_WORLD] * osn));
}
