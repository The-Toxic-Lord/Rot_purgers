// NOTE: Shader automatically converted from Godot Engine 4.7.2.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

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

uniform vec2 Direction;
uniform float Speed;

void vertex() {
	
	vec2 n_out2p0 = UV;


// Vector2Parameter:6
	vec2 n_out6p0 = Direction;


// FloatParameter:8
	float n_out8p0 = Speed;


// VectorOp:7
	vec3 n_out7p0 = vec3(n_out6p0, 0.0) * vec3(n_out8p0);


// Input:4
	float n_out4p0 = TIME;


// VectorOp:5
	vec2 n_in5p1 = vec2(1.00000, 1.00000);
	vec2 n_out5p0 = vec2(n_out4p0) * n_in5p1;


// UVFunc:3
	vec2 n_out3p0 = n_out5p0 * vec2(n_out7p0.xy) + n_out2p0;

	
	UV = n_out3p0 * uv1_scale.xy + uv1_offset.xy;
}

void fragment() {
	vec2 base_uv = UV;

	vec4 albedo_tex = texture(texture_albedo, base_uv);
	ALBEDO = albedo.rgb * albedo_tex.rgb;

	float metallic_tex = dot(texture(texture_metallic, base_uv), metallic_texture_channel);
	METALLIC = metallic_tex * metallic;
	SPECULAR = specular;

	vec4 roughness_texture_channel = vec4(1.0, 0.0, 0.0, 0.0);
	float roughness_tex = dot(texture(texture_roughness, base_uv), roughness_texture_channel);
	ROUGHNESS = roughness_tex * roughness;
}
