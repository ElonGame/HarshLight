#version 450 core

in vec2 vs_Texcoord;
in vec3 vs_WorldPosition;
in vec3 vs_WorldNormal;

out vec4 fragColor;

uniform sampler2D TexAlbedo;
uniform sampler3D TexVoxel;

uniform mat4 CamVoxelViewMtx;
uniform mat4 CamVoxelProjMtx;
uniform float VoxelDim;

void main()
{
	vec4 voxel_space_pos = CamVoxelProjMtx * CamVoxelViewMtx * vec4(vs_WorldPosition, 1.0);
	voxel_space_pos /= voxel_space_pos.w;
	voxel_space_pos *= vec4(VoxelDim);
	ivec3 voxel_idx = ivec3(floor(voxel_space_pos.xyz));
	fragColor = texture(TexVoxel, vec3(0,0,0));
	//fragColor = imageLoad(TexVoxel, ivec3(0,0,0));
	//fragColor = vec4(0.5, 0.5, 0.5, 1);
}