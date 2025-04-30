package("lzma")

    set_homepage("https://www.7-zip.org/sdk.html")
    set_description("LZMA SDK")

    add_urls("https://www.7-zip.org/a/lzma$(version).7z", {version = function (version) return version:gsub("%.", "") end})
    add_versions("19.00", "00f569e624b3d9ed89cf8d40136662c4c5207eaceb92a70b1044c77f84234bad")

    add_links("lzma")
    if is_plat("bsd") then
        add_syslinks("pthread")
    end
    on_install(function (package) 
        os.cd("C")
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("lzma")
                set_kind("$(kind)")
                add_files("*.c")
                add_headerfiles("*.h")
                if is_plat("windows") then
                    add_files("Util/LzmaLib/LzmaLib.def")
                end
        ]])
        local flags = ""
        if not package:is_plat("windows") and package:is_arch("arm.*") then
            flags = "-march=armv8-a+crc+crypto"
        end
        import("package.tools.xmake").install(package, {
            cxflags = flags,
            kind = package:config("shared") and "shared" or "static"
        })
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            void test() {
                // we only test links...
                LzmaCompress(
                    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                );
            }
        ]]}, {configs = {languages = "c99"}, includes = "LzmaLib.h"}))
    end)
