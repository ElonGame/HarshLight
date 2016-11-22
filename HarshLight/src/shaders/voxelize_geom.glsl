#version 450 core

layout(triangles, invocations = 1) in;
layout(triangle_strip, max_vertices = 3) out;

layout (std140) uniform CamMtx
{
    mat4 View;
    mat4 Proj;
};

uniform float PixelDiagonal;

in vec2 vs_Texcoord[];
in vec3 vs_WorldPosition[];
in vec3 vs_WorldNormal[];

out vec2 gs_Texcoord;
out vec3 gs_WorldPosition;
out vec3 gs_WorldNormal;
out vec4 gs_BBox;
out flat ivec3 gs_ProjDir;


void main()
{
	//view space face normal
	vec3 view_e01 = gl_in[1].gl_Position.xyz - gl_in[0].gl_Position.xyz;
	vec3 view_e02 = gl_in[2].gl_Position.xyz - gl_in[0].gl_Position.xyz;
	vec3 view_normal = abs(cross(view_e01, view_e02));
	float dominant_axis = max(view_normal.x, max(view_normal.y, view_normal.z));
	if(dominant_axis == view_normal.x)
	{
		gs_ProjDir = ivec3(2, 1, 0);
	}
	else if(dominant_axis == view_normal.y)
	{
		gs_ProjDir = ivec3(0, 2, 1);
	}
	else
	{
		gs_ProjDir = ivec3(0, 1, 2);
	}

	const mat3 identity = mat3(vec3(1.0, 0.0, 0.0), vec3(0.0, 1.0, 0.0), vec3(0.0, 0.0, 1.0));
	mat3 swizzle = mat3(identity[gs_ProjDir[0]], identity[gs_ProjDir[1]], identity[gs_ProjDir[2]]);

	vec4 screen_pos[3];
	screen_pos[0] = Proj * mat4(swizzle) * gl_in[0].gl_Position;
	screen_pos[1] = Proj * mat4(swizzle) * gl_in[1].gl_Position;
	screen_pos[2] = Proj * mat4(swizzle) * gl_in[2].gl_Position;
	screen_pos[0] /= screen_pos[0].w;
	screen_pos[1] /= screen_pos[1].w;
	screen_pos[2] /= screen_pos[2].w;

	gs_BBox.xy = min(screen_pos[0].xy, min(screen_pos[1].xy, screen_pos[2].xy));
    gs_BBox.zw = max(screen_pos[0].xy, max(screen_pos[1].xy, screen_pos[2].xy));
    gs_BBox.xy -= vec2(PixelDiagonal);
    gs_BBox.zw += vec2(PixelDiagonal);

	gs_Texcoord = vs_Texcoord[0];
	gs_WorldPosition = vs_WorldPosition[0];
	gs_WorldNormal = vs_WorldNormal[0];
	gl_Position = screen_pos[0];
	EmitVertex();

	gs_Texcoord = vs_Texcoord[1];
	gs_WorldPosition = vs_WorldPosition[1];
	gs_WorldNormal = vs_WorldNormal[1];
	gl_Position = screen_pos[1];
	EmitVertex();

	gs_Texcoord = vs_Texcoord[2];
	gs_WorldPosition = vs_WorldPosition[2];
	gs_WorldNormal = vs_WorldNormal[2];
	gl_Position = screen_pos[2];
	EmitVertex();

	EndPrimitive();
}