// Basic shading
varying vec4 v_color;
varying vec3 v_normal;

void main()
{
    vec4 color = v_color;
	color.rgb *= .5 + .5 * max(dot(v_normal, vec3(1)), 0.0);
	gl_FragColor = color;
}
