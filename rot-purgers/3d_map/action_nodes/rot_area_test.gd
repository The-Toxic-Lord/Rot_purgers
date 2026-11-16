@tool extends MeshInstance3D

class_name Rot_area_test

@export_tool_button("redraw") var bt = test



func test():
	var shader : ShaderMaterial = self.material_override
	var shader_texture : VisualShaderNodeTexture = shader.shader.get_node(1, 11)
	print(shader_texture)
	print(2%4)
