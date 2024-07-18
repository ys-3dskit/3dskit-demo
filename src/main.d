import ys3ds.ctru;
import ys3ds.citro2d;
import ys3ds.citro3d;

import gfxcube;
import gfx2d;

@nogc nothrow:

auto loadTextureFromMem(bool t3xret = false)(C3D_Tex* tex, C3D_TexCube* cube, const(void)* data, size_t length)
{
	auto t3x = Tex3DS_TextureImport(data, length, tex, cube, false);

	static if (t3xret)
	{
		return t3x;
	}
	else
	{
		if (!t3x)
			return false;

		// we don't need the t3x object, we just used it to make loading easier
		Tex3DS_TextureFree(t3x);
		return true;
	}
}

// render a spinny biden cube on the bottom screen pls
extern(C) void main()
{
	gfxInitDefault();
	gfxSet3D(true);
	C3D_Init(C3D_DEFAULT_CMDBUF_SIZE);
	C2D_Init(C2D_DEFAULT_MAX_OBJECTS);

	// graphics scope
	{
		// rendered on bottom screen
		auto scene3d = GfxCube();
		// rendered on top screen
		auto scene2d = Gfx2d();

		while (aptMainLoop())
		{
			hidScanInput();

			uint kDown = hidKeysDown();
			if (kDown & KEY_START)
				break; // return to hbmenu

			C3D_FrameBegin(C3D_FRAME_SYNCDRAW);
			scene3d.render();
			scene2d.render();
			C3D_FrameEnd(0);
		}
	}

	C2D_Fini();
	C3D_Fini();
	gfxExit();
}
