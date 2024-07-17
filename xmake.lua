add_repositories("3dskit git@github.com:ys-3dskit/3dskit-repo")

add_requires(
  "libctru ~2.3.1"
, "citro3d ~1.7.1"
, "citro2d ~1.6.0"
, "3dskit-dlang ~0.2.1"
)

includes("toolchain/*.lua")

add_rules("mode.debug", "mode.release")

target("3dskdemo")
	set_kind("binary")
	set_plat("3ds")

	set_arch("arm")
	add_rules("3ds")
	set_toolchains("devkitarm")

	set_values("3ds.name", "3dskdemo")
	set_values("3ds.description", "demo of 3dskit-dlang, ctru, citro2d, citro3d")
	set_values("3ds.author", "Hazel Atkinson")

	-- TODO: this does not belong here. xmake won't play without it. -- sink
	add_ldflags("-specs=3dsx.specs", "-g", "-march=armv6k", "-mtune=mpcore", "-mtp=soft", "-mfloat-abi=hard", {force = true})

	-- d is source, asm for compiled graphics and shaders
	add_files("src/**.d", "src/**.S", "gfx/**.S")

	add_packages("libctru", "citro2d", "citro3d", "3dskit-dlang")

  -- fix imports
	add_dcflags("-g", "-Isrc", "-Igfx", {force = true})

	set_strip("debug")
