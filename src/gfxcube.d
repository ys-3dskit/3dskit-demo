module gfxcube;

import ys3ds.ctru._3ds.svc;
import ys3ds.ctru._3ds.gfx;
import ys3ds.ctru._3ds.gpu.shaderProgram;
import ys3ds.ctru._3ds.gpu.gx;
import ys3ds.ctru._3ds.gpu.shbin;
import ys3ds.ctru._3ds.gpu.enums;
import ys3ds.citro3d;
import ys3ds.citro3d.tex3ds;

import core.stdc.math;

import btl.autoptr : UniquePtr;
import ys3ds.memory;

import vshader_shbin : vshader_shbin, vshader_shbin_end, vshader_shbin_size;
import biden_L_t3x : biden_L_t3x, biden_L_t3x_end, biden_L_t3x_size;

import main : loadTextureFromMem;

@nogc nothrow:

private
{
	struct vertex_ { float[3] position; float[2] texcoord; float[3] normal; }

	__gshared vertex_[36] vertex_list =
	[
		// First face (PZ)
		// First triangle
		{ [-0.5f, -0.5f, +0.5f], [0.0f, 0.0f], [0.0f, 0.0f, +1.0f] },
		{ [+0.5f, -0.5f, +0.5f], [1.0f, 0.0f], [0.0f, 0.0f, +1.0f] },
		{ [+0.5f, +0.5f, +0.5f], [1.0f, 1.0f], [0.0f, 0.0f, +1.0f] },
		// Second triangle
		{ [+0.5f, +0.5f, +0.5f], [1.0f, 1.0f], [0.0f, 0.0f, +1.0f] },
		{ [-0.5f, +0.5f, +0.5f], [0.0f, 1.0f], [0.0f, 0.0f, +1.0f] },
		{ [-0.5f, -0.5f, +0.5f], [0.0f, 0.0f], [0.0f, 0.0f, +1.0f] },

		// Second face (MZ)
		// First triangle
		{ [-0.5f, -0.5f, -0.5f], [0.0f, 0.0f], [0.0f, 0.0f, -1.0f] },
		{ [-0.5f, +0.5f, -0.5f], [1.0f, 0.0f], [0.0f, 0.0f, -1.0f] },
		{ [+0.5f, +0.5f, -0.5f], [1.0f, 1.0f], [0.0f, 0.0f, -1.0f] },
		// Second triangle
		{ [+0.5f, +0.5f, -0.5f], [1.0f, 1.0f], [0.0f, 0.0f, -1.0f] },
		{ [+0.5f, -0.5f, -0.5f], [0.0f, 1.0f], [0.0f, 0.0f, -1.0f] },
		{ [-0.5f, -0.5f, -0.5f], [0.0f, 0.0f], [0.0f, 0.0f, -1.0f] },

		// Third face (PX)
		// First triangle
		{ [+0.5f, -0.5f, -0.5f], [0.0f, 0.0f], [+1.0f, 0.0f, 0.0f] },
		{ [+0.5f, +0.5f, -0.5f], [1.0f, 0.0f], [+1.0f, 0.0f, 0.0f] },
		{ [+0.5f, +0.5f, +0.5f], [1.0f, 1.0f], [+1.0f, 0.0f, 0.0f] },
		// Second triangle
		{ [+0.5f, +0.5f, +0.5f], [1.0f, 1.0f], [+1.0f, 0.0f, 0.0f] },
		{ [+0.5f, -0.5f, +0.5f], [0.0f, 1.0f], [+1.0f, 0.0f, 0.0f] },
		{ [+0.5f, -0.5f, -0.5f], [0.0f, 0.0f], [+1.0f, 0.0f, 0.0f] },

		// Fourth face (MX)
		// First triangle
		{ [-0.5f, -0.5f, -0.5f], [0.0f, 0.0f], [-1.0f, 0.0f, 0.0f] },
		{ [-0.5f, -0.5f, +0.5f], [1.0f, 0.0f], [-1.0f, 0.0f, 0.0f] },
		{ [-0.5f, +0.5f, +0.5f], [1.0f, 1.0f], [-1.0f, 0.0f, 0.0f] },
		// Second triangle
		{ [-0.5f, +0.5f, +0.5f], [1.0f, 1.0f], [-1.0f, 0.0f, 0.0f] },
		{ [-0.5f, +0.5f, -0.5f], [0.0f, 1.0f], [-1.0f, 0.0f, 0.0f] },
		{ [-0.5f, -0.5f, -0.5f], [0.0f, 0.0f], [-1.0f, 0.0f, 0.0f] },

		// Fifth face (PY)
		// First triangle
		{ [-0.5f, +0.5f, -0.5f], [0.0f, 0.0f], [0.0f, +1.0f, 0.0f] },
		{ [-0.5f, +0.5f, +0.5f], [1.0f, 0.0f], [0.0f, +1.0f, 0.0f] },
		{ [+0.5f, +0.5f, +0.5f], [1.0f, 1.0f], [0.0f, +1.0f, 0.0f] },
		// Second triangle
		{ [+0.5f, +0.5f, +0.5f], [1.0f, 1.0f], [0.0f, +1.0f, 0.0f] },
		{ [+0.5f, +0.5f, -0.5f], [0.0f, 1.0f], [0.0f, +1.0f, 0.0f] },
		{ [-0.5f, +0.5f, -0.5f], [0.0f, 0.0f], [0.0f, +1.0f, 0.0f] },

		// Sixth face (MY)
		// First triangle
		{ [-0.5f, -0.5f, -0.5f], [0.0f, 0.0f], [0.0f, -1.0f, 0.0f] },
		{ [+0.5f, -0.5f, -0.5f], [1.0f, 0.0f], [0.0f, -1.0f, 0.0f] },
		{ [+0.5f, -0.5f, +0.5f], [1.0f, 1.0f], [0.0f, -1.0f, 0.0f] },
		// Second triangle
		{ [+0.5f, -0.5f, +0.5f], [1.0f, 1.0f], [0.0f, -1.0f, 0.0f] },
		{ [-0.5f, -0.5f, +0.5f], [0.0f, 1.0f], [0.0f, -1.0f, 0.0f] },
		{ [-0.5f, -0.5f, -0.5f], [0.0f, 0.0f], [0.0f, -1.0f, 0.0f] },
	];

	__gshared C3D_Mtx material = C3D_Mtx([
		C3D_FVec(c: [ 0.0f, 0.2f, 0.2f, 0.2f ]), // Ambient
		C3D_FVec(c: [ 0.0f, 0.4f, 0.4f, 0.4f ]), // Diffuse
		C3D_FVec(c: [ 0.0f, 0.8f, 0.8f, 0.8f ]), // Specular
		C3D_FVec(c: [ 1.0f, 0.0f, 0.0f, 0.0f ]), // Emission
	]);

	// copied from textured_cube example
	enum DISPLAY_TRANSFER_FLAGS =
		(GX_TRANSFER_FLIP_VERT(0) | GX_TRANSFER_OUT_TILED(0) | GX_TRANSFER_RAW_COPY(0)
		| GX_TRANSFER_IN_FORMAT(GX_TRANSFER_FORMAT.GX_TRANSFER_FMT_RGBA8)
		| GX_TRANSFER_OUT_FORMAT(GX_TRANSFER_FORMAT.GX_TRANSFER_FMT_RGB8)
		| GX_TRANSFER_SCALING(GX_TRANSFER_SCALE.GX_TRANSFER_SCALE_NO));
}


struct GfxCube
{
@nogc nothrow:

	alias LinearUniquePtr(T) = typeof(UniquePtr!T.make!LinearCtruMallocator(0));

	C3D_RenderTarget* target;

	DVLB_s* vshader_dvlb;
	shaderProgram_s program;
	int uLoc_projection, uLoc_modelView, uLoc_lightVec, uLoc_lightHalfVec, uLoc_lightClr, uLoc_material;
	C3D_Mtx projection;

	LinearUniquePtr!(vertex_[]) vbo_data;
	C3D_Tex biden_tex;
	float angleX = 0, angleY = 0;

	C3D_AttrInfo vbo_attrInfo;
	C3D_BufInfo vbo_bufInfo;

	@property void* vbo_data_raw()
	{
		return cast(void*)(*vbo_data).ptr;
	}

	static GfxCube opCall()
	{
		GfxCube s;
		s.setup();
		return s;
	}

	private void setup()
	{
		target = C3D_RenderTargetCreate(240, 320, GPU_COLORBUF.GPU_RB_RGBA8, C3D_DEPTHTYPE(GPU_DEPTHBUF.GPU_RB_DEPTH24_STENCIL8));
		C3D_RenderTargetSetOutput(target, gfxScreen_t.GFX_BOTTOM, gfx3dSide_t.GFX_LEFT, DISPLAY_TRANSFER_FLAGS);

		// TODO: shader support in the toolchain
		vshader_dvlb = DVLB_ParseFile(cast(uint*) vshader_shbin, vshader_shbin_size);
		shaderProgramInit(&program);
		shaderProgramSetVsh(&program, &vshader_dvlb.DVLE[0]);

		// get uniform locations
		uLoc_projection = shaderInstanceGetUniformLocation(program.vertexShader, "projection");
		uLoc_modelView = shaderInstanceGetUniformLocation(program.vertexShader, "modelView");
		uLoc_lightVec = shaderInstanceGetUniformLocation(program.vertexShader, "lightVec");
		uLoc_lightHalfVec = shaderInstanceGetUniformLocation(program.vertexShader, "lightHalfVec");
		uLoc_lightClr = shaderInstanceGetUniformLocation(program.vertexShader, "lightClr");
		uLoc_material = shaderInstanceGetUniformLocation(program.vertexShader, "material");

		// vertex shader attribute config
		AttrInfo_Init(&vbo_attrInfo);
		AttrInfo_AddLoader(&vbo_attrInfo, 0, GPU_FORMATS.GPU_FLOAT, 3); // v0=position
		AttrInfo_AddLoader(&vbo_attrInfo, 1, GPU_FORMATS.GPU_FLOAT, 2); // v1=texcoord
		AttrInfo_AddLoader(&vbo_attrInfo, 2, GPU_FORMATS.GPU_FLOAT, 3); // v2=normal

		// Compute the projection matrix
		Mtx_PerspTilt(&projection, C3D_AngleFromDegrees(80.0f), C3D_AspectRatioBot, 0.01f, 1000.0f, false);

		// create the VBO, exact copy of vertex_list
		//auto vertex_list_bytes = typeof(vertex_list).sizeof;
		vbo_data = UniquePtr!(vertex_[]).make!LinearCtruMallocator(vertex_list.length);
		(*vbo_data)[] = vertex_list[];

		// configure buffers
		BufInfo_Init(&vbo_bufInfo);
		BufInfo_Add(&vbo_bufInfo, vbo_data_raw, vertex_.sizeof, 3, 0x210);

		// load texture and assign to first texture unit
		// TODO: texture support in toolchain
		if (!loadTextureFromMem(&biden_tex, null, biden_L_t3x.ptr, biden_L_t3x_size))
			svcBreak(UserBreakType.USERBREAK_PANIC);
		C3D_TexSetFilter(&biden_tex, GPU_TEXTURE_FILTER_PARAM.GPU_LINEAR, GPU_TEXTURE_FILTER_PARAM.GPU_LINEAR);
	}

	private void bind()
	{
		C3D_BindProgram(&program);
		C3D_SetAttrInfo(&vbo_attrInfo);
		C3D_SetBufInfo(&vbo_bufInfo);

		C3D_TexBind(0, &biden_tex);

		// Configure the first fragment shading substage to blend the texture color with
		// the vertex color (calculated by the vertex shader using a lighting algorithm)
		// See https://www.opengl.org/sdk/docs/man2/xhtml/glTexEnv.xml for more insight
		auto env = C3D_GetTexEnv(0);
		C3D_TexEnvInit(env);
		C3D_TexEnvSrc(env, C3D_TexEnvMode.C3D_Both, GPU_TEVSRC.GPU_TEXTURE0, GPU_TEVSRC.GPU_PRIMARY_COLOR, GPU_TEVSRC
				.GPU_PRIMARY_COLOR);
		C3D_TexEnvFunc(env, C3D_TexEnvMode.C3D_Both, GPU_COMBINEFUNC.GPU_MODULATE);

		// Clear out the other texenvs
		C3D_TexEnvInit(C3D_GetTexEnv(1));
		C3D_TexEnvInit(C3D_GetTexEnv(2));
		C3D_TexEnvInit(C3D_GetTexEnv(3));
		C3D_TexEnvInit(C3D_GetTexEnv(4));
		C3D_TexEnvInit(C3D_GetTexEnv(5));
	}

	void render()
	{
		C3D_RenderTargetClear(target, C3D_ClearBits.C3D_CLEAR_ALL, 0x68B0D8FF, 0); // lmfao this constant
		C3D_FrameDrawOn(target);

		bind();
		_render();
	}

	private void _render()
	{
		// calculate modelview matrix
		C3D_Mtx modelView;
		Mtx_Identity(&modelView);
		Mtx_Translate(&modelView, 0.0, 0.0, -2.0 + 0.5 * sinf(angleX), true);
		Mtx_RotateX(&modelView, angleX, true);
		Mtx_RotateY(&modelView, angleY, true);

		// Rotate the cube each frame
		angleX += M_PI / 180;
		angleY += M_PI / 360;

		// Update the uniforms
		C3D_FVUnifMtx4x4(GPU_SHADER_TYPE.GPU_VERTEX_SHADER, uLoc_projection, &projection);
		C3D_FVUnifMtx4x4(GPU_SHADER_TYPE.GPU_VERTEX_SHADER, uLoc_modelView, &modelView);
		C3D_FVUnifMtx4x4(GPU_SHADER_TYPE.GPU_VERTEX_SHADER, uLoc_material, &material);
		C3D_FVUnifSet(GPU_SHADER_TYPE.GPU_VERTEX_SHADER, uLoc_lightVec, 0.0f, 0.0f, -1.0f, 0.0f);
		C3D_FVUnifSet(GPU_SHADER_TYPE.GPU_VERTEX_SHADER, uLoc_lightHalfVec, 0.0f, 0.0f, -1.0f, 0.0f);
		C3D_FVUnifSet(GPU_SHADER_TYPE.GPU_VERTEX_SHADER, uLoc_lightClr, 1.0f, 1.0f, 1.0f, 1.0f);

		// Draw the VBO
		C3D_DrawArrays(GPU_Primitive_t.GPU_TRIANGLES, 0, vertex_list.length);
	}

	// RAII go brr
	~this()
	{
		C3D_TexDelete(&biden_tex);

		shaderProgramFree(&program);
		DVLB_Free(vshader_dvlb);
	}
}
