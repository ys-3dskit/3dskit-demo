module gfx2d;

import core.stdc.math;

import ys3ds.ctru;
import ys3ds.citro2d;

import cpp_t3x : cpp_t3x, cpp_t3x_end, cpp_t3x_size;

import main : loadTextureFromMem;

@nogc nothrow:

private
{
	enum clrWhite = C2D_Color32(0xFF, 0xFF, 0xFF, 0xFF);
	enum clrGreen = C2D_Color32(0x00, 0xFF, 0x00, 0xFF);
	enum clrRed = C2D_Color32(0xFF, 0x00, 0x00, 0xFF);
	enum clrBlue = C2D_Color32(0x00, 0x00, 0xFF, 0xFF);

	enum clrClear = C2D_Color32(0, 0, 0, 0x68); //C2D_Color32(0xFF, 0xD8, 0xB0, 0x68);

	enum SCREEN_W = 400, SCREEN_H = 240;

	// https://stackoverflow.com/a/64090995
	uint hslToRgb(float h, float s, float l)
	{
		float a = s * fminf(l, 1-l);

		pragma(inline, true)
		float crunch(uint n)
		{
			float k = cast(float) ((n + h / 30) % 12);
			return l - a * fmaxf(fminf(fminf(k-3, 9-k), 1), -1);
		}

		return C2D_Color32f(crunch(0), crunch(8), crunch(4), 1);
	}
}


struct Gfx2d
{
@nogc nothrow:

	private enum sineText = "Writing your code in...";

	C3D_RenderTarget* targetL, targetR;

	C2D_TextBuf tbuf;
	C2D_Text textQ;
	C2D_Text[sineText.length] texts;
	float[sineText.length] textXOsets;
	float textTotalWidth;

	float sinOset = 0;

	C3D_Tex cppTex;
	C2D_Image cppImg;

	static Gfx2d opCall()
	{
		Gfx2d s;
		s.setup();
		return s;
	}

	private void setup()
	{
		targetL = C2D_CreateScreenTarget(gfxScreen_t.GFX_TOP, gfx3dSide_t.GFX_LEFT);
		targetR = C2D_CreateScreenTarget(gfxScreen_t.GFX_TOP, gfx3dSide_t.GFX_RIGHT);
		C2D_ViewRotateDegrees(90);
		C2D_ViewTranslate(0, -SCREEN_H);

		tbuf = C2D_TextBufNew(512);

		C2D_TextParse(&textQ, tbuf, "?".ptr);
		C2D_TextOptimize(&textQ);

		textTotalWidth = 0;
		for (auto i = 0; i < sineText.length; i++)
		{
			char[2] buf = [sineText[i], 0];
			C2D_TextParse(&texts[i], tbuf, buf.ptr);
			C2D_TextOptimize(&texts[i]);
			textXOsets[i] = textTotalWidth;
			textTotalWidth += texts[i].width;
		}

		auto cppt3x = loadTextureFromMem!true(&cppTex, null, cpp_t3x.ptr, cpp_t3x_size);
		if (!cppt3x)
			svcBreak(UserBreakType.USERBREAK_PANIC);

		cppImg = C2D_Image(&cppTex, Tex3DS_GetSubTexture(cppt3x, 0));
		Tex3DS_TextureFree(cppt3x);
	}

	void render()
	{
		float iod = osGet3DSliderState();
		C2D_Prepare();
		renderOn(+iod, targetL);
		renderOn(-iod, targetR);
		sinOset += 0.075;
	}

	private void renderOn(float iod, C3D_RenderTarget* targ)
	{
		C2D_TargetClear(targ, clrClear);
		C3D_FrameDrawOn(targ);
		// don't use scenebegin as we're also using c3d
		C2D_SceneTarget(targ);

		C2D_DrawText(&textQ, C2D_WithColor, 275, 80, 0, 4, 4, clrWhite);

		auto textsOset = 200 - (textTotalWidth / 2);
		for (auto i = 0; i < texts.length; i++)
		{
			auto x = textXOsets[i];
			auto sinInput = sinOset + M_TAU * x / textTotalWidth;
			while (sinInput > M_TAU)
			sinInput -= M_TAU;

			C2D_DrawText(
			&texts[i], C2D_WithColor,
			textsOset + (iod * 4) + x,
			30 + 10 * sinf(sinInput),
			0, 1, 1,
			hslToRgb((sinInput / 3) * 360, 1, .7)
			);
		}

		C2D_DrawImageAt(cppImg, 200 - ((256 * .5) / 2) + (iod * 6), 80, 0, null, 0.5, 0.5);

		C2D_Flush();
	}

	~this()
	{
		C2D_TextBufDelete(tbuf);
	}
}
