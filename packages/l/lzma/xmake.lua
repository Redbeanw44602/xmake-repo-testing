package("lzma")

    set_homepage("https://www.7-zip.org/sdk.html")
    set_description("LZMA SDK")

    add_urls("https://www.7-zip.org/a/lzma$(version).7z", {version = function (version) return version:gsub("%.", "") end})

    add_versions("24.09", "79b39f10b7b69eea293caa90c3e7ea07faf8f01f8ae9db1bb1b90c092375e5f3")

    add_links("lzma")
    on_install(function (package)
        os.cd("C")
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("lzma")
                set_kind("$(kind)")
                add_files("*.c")
                add_headerfiles("*.h")
        ]])
        import("package.tools.xmake").install(package, {kind = package:config("shared") and "shared" or "static"})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("LzmaCompress", {includes = "LzmaLib.h"}))
    end)
