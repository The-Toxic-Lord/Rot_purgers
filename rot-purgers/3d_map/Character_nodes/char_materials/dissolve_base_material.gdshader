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

void vertex() {
	UV = UV * uv1_scale.xy + uv1_offset.xy;
}

void fragment() {
	vec2 base_uv = UV;

	vec4 albedo_tex = texture(texture_albedo, base_uv);
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	ALBEDO = mix(ALBEDO.rgb, rot.rgb, rot.a);

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
	

	ALPHA = n_out4p0.x;
	ALPHA_SCISSOR_THRESHOLD = dissolve;
	
	if (emission_energy == 0.0){
		EMISSION = vec3(n_out18p0.xyz);
	} else {
	// Emission Operator: Add
	EMISSION = emission.rgb * emission_energy;
	}
}
