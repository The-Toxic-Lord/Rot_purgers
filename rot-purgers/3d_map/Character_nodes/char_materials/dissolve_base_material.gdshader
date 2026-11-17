// NOTE: Shader automatically converted from Godot Engine 4.7.1.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, diffuse_burley, specular_schlick_ggx;

uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;
uniform ivec2 albedo_texture_size;
uniform float point_size : hint_range(0.1, 128.0, 0.1);

uniform float roughness : hint_range(0.0, 1.0);
uniform sampler2D texture_metallic : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform vec4 metallic_texture_channel;
uniform sampler2D texture_roughness : hint_roughness_r, filter_linear_mipmap, repeat_enable;

uniform float specular : hint_range(0.0, 1.0, 0.01);
uniform float metallic : hint_range(0.0, 1.0, 0.01);

uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;

uniform sampler2D noise_texture;
uniform float dissolve = -0.1;
uniform vec4 dissolve_color : source_color;
uniform vec4 rot : source_color;

uniform vec4 emission : source_color;
uniform float emission_energy;

uniform int rot_stage;
uniform float non_rot_array[4];
uniform int divisions;
uniform sampler2D rot_noise;
uniform float rot_wave_strength = 1.0;
uniform float wave_size = 0.10000000149012;
uniform float wave_wave_size = 0.00999999977648;
uniform sampler2D ramka;

struct rot_overlay_output {
    vec3 albedo_out;
    float alpha_out;
    vec3 emission_out;
};



rot_overlay_output rot_overlay(vec2 uv, vec3 node_pos) {
	// ColorConstant:42
	vec4 n_out42p0 = vec4(0.000000, 0.101625, 0.015891, 1.000000);


// FloatParameter:7
	float n_out7p0 = 1.0 - non_rot_array[rot_stage];


//// Input:17
	//vec2 n_out17p0 = uv;


//// Vector2Constant:31
	//vec2 n_out31p0 = vec2(1.000000, 1.000000);


//// IntParameter:37
	//int n_out37p0 = divisions;


//// VectorOp:32
	//vec2 n_out32p0 = n_out31p0 * vec2(float(n_out37p0));


//// VectorOp:24
	//vec2 n_out24p0 = n_out17p0 / n_out32p0;

//
//// Input:10
	////vec3 n_out10p0 = NODE_POSITION_WORLD;
	//vec3 n_out10p0 = node_pos;
//
//
//// VectorDecompose:12
	//float n_out12p0 = n_out10p0.x;
	//float n_out12p1 = n_out10p0.y;
	//float n_out12p2 = n_out10p0.z;
//
//
//// FloatOp:28
	//float n_in28p1 = 2.00000;
	//float n_out28p0 = n_out12p0 / n_in28p1;
//
//
//// FloatOp:33
	//float n_out33p0 = n_out28p0 / float(n_out37p0);
//
//
//// FloatOp:29
	//float n_in29p1 = 2.00000;
	//float n_out29p0 = n_out12p2 / n_in29p1;
//
//
//// FloatOp:34
	//float n_out34p0 = n_out29p0 / float(n_out37p0);
//
//
//// VectorCompose:35
	//vec2 n_out35p0 = vec2(n_out33p0, n_out34p0);
//
//
//// VectorOp:36
	//vec2 n_out36p0 = n_out24p0 + n_out35p0;


	vec4 n_out11p0;
// Texture2D:11
	n_out11p0 = texture(rot_noise, uv);
	float n_out11p1 = n_out11p0.r;


// Step:5
	float n_out5p0 = step(n_out7p0, n_out11p1);


// VectorOp:43
	vec3 n_out43p0 = vec3(n_out42p0.xyz) * vec3(n_out5p0);


// ColorConstant:44
	vec4 n_out44p0 = vec4(0.122864, 0.341398, 0.000000, 1.000000);


// FloatParameter:60
	float n_out60p0 = rot_wave_strength;


// VectorCompose:59
	vec3 n_out59p0 = vec3(n_out60p0, n_out60p0, n_out60p0);


// VectorOp:58
	vec3 n_out58p0 = vec3(n_out44p0.xyz) * n_out59p0;


// FloatParameter:38
	float n_out38p0 = wave_size;


// Input:23
	float n_out23p0 = TIME;


// FloatFunc:20
	float n_out20p0 = sin(n_out23p0);


// FloatParameter:47
	float n_out47p0 = wave_wave_size;


// FloatOp:48
	float n_out48p0 = n_out20p0 * n_out47p0;


// FloatOp:49
	float n_out49p0 = n_out38p0 + n_out48p0;


// FloatOp:40
	float n_out40p0 = n_out7p0 + n_out49p0;


// Step:39
	float n_out39p0 = step(n_out40p0, n_out11p1);


// FloatOp:41
	float n_out41p0 = n_out5p0 - n_out39p0;


// VectorOp:45
	vec3 n_out45p0 = n_out58p0 * vec3(n_out41p0);


	vec4 n_out62p0;
// Texture2D:62
	n_out62p0 = texture(ramka, uv);
	float n_out62p1 = n_out62p0.r;


// Step:66
	float n_in66p0 = 0.50000;
	float n_out66p0 = step(n_in66p0, n_out62p1);


// VectorOp:64
	vec3 n_out64p0 = vec3(n_out66p0) * n_out58p0;


// VectorOp:65
	vec3 n_out65p0 = n_out45p0 + n_out64p0;


// Output:0
	//ALBEDO = n_out43p0;
	//ALPHA = n_out5p0;
	//EMISSION = n_out65p0;
	
	rot_overlay_output output;
	output.albedo_out = n_out43p0;
	output.alpha_out = n_out5p0;
	output.emission_out = n_out65p0;
	return output;
}


void vertex() {
	UV = UV * uv1_scale.xy + uv1_offset.xy;
}

void fragment() {
	vec2 base_uv = UV;


	float metallic_tex = dot(texture(texture_metallic, base_uv), metallic_texture_channel);
	METALLIC = metallic_tex * metallic;
	SPECULAR = specular;

	vec4 roughness_texture_channel = vec4(1.0, 0.0, 0.0, 0.0);
	float roughness_tex = dot(texture(texture_roughness, base_uv), roughness_texture_channel);
	ROUGHNESS = roughness_tex * roughness;
	
	
	vec4 n_out4p0;
// Texture2D:4
	n_out4p0 = texture(noise_texture, UV);
	
	
	// ColorConstant:23
	vec4 n_out23p0 = dissolve_color;
// FloatConstant:9
	float n_out9p0 = 0.100000;
// Input:5
	float n_out7p0 = dissolve;
	float n_out10p0 = n_out9p0 + n_out7p0;

// Mix:17
	vec4 n_in17p0 = vec4(0.00000, 0.00000, 0.00000, 0.00000);
	vec4 n_out17p0 = mix(n_in17p0, n_out23p0, vec4(n_out10p0));
	
	float n_out4p1 = n_out4p0.r;
	vec4 n_out18p0 = step(vec4(n_out4p1), n_out17p0);

	vec4 albedo_tex = texture(texture_albedo, base_uv);
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	ALBEDO = mix(ALBEDO.rgb, rot.rgb, rot.a);

	ALPHA = n_out4p0.x;
	ALPHA_SCISSOR_THRESHOLD = dissolve;
	
	if (emission_energy == 0.0){
		EMISSION = vec3(n_out18p0.xyz);
	} else {
	// Emission Operator: Add
	EMISSION = emission.rgb * emission_energy;
	}
	
	rot_overlay_output rot_out = rot_overlay(UV, NODE_POSITION_WORLD);
	if (rot_out.alpha_out == 1.0)
		ALBEDO = rot_out.albedo_out;
		EMISSION = rot_out.emission_out;
}
