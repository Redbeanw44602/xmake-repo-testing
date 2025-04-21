package("lzma")

    set_homepage("https://www.7-zip.org/sdk.html")
    set_description("LZMA SDK")

    add_urls("https://www.7-zip.org/a/lzma$(version).7z", {version = function (version) return version:gsub("%.", "") end})
    add_versions("19.00", "00f569e624b3d9ed89cf8d40136662c4c5207eaceb92a70b1044c77f84234bad")
    add_versions("21.07", "833888f03c6628c8a062ce5844bb8012056e7ab7ba294c7ea232e20ddadf0d75")
    add_versions("22.01", "35b1689169efbc7c3c147387e5495130f371b4bad8ec24f049d28e126d52d9fe")
    add_versions("23.01", "317dd834d6bbfd95433488b832e823cd3d4d420101436422c03af88507dd1370")
    add_versions("24.09", "79b39f10b7b69eea293caa90c3e7ea07faf8f01f8ae9db1bb1b90c092375e5f3")

    add_links("lzma")
    on_install(function (package)
        os.cd("C")
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("lzma")
                set_kind("$(kind)")
                add_files("Alloc.c", "LzFind.c",  "Lzma2Dec.c", "Lzma2Enc.c", "LzmaDec.c", "LzmaEnc.c", "LzmaLib.c", "CpuArch.c")
                add_headerfiles("7zTypes.h", "Alloc.h", "LzFind.h", "LzHash.h", "Lzma2Dec.h", "Lzma2Enc.h", "LzmaDec.h", "LzmaEnc.h", "LzmaLib.h")
                if is_plat("windows") then
                    add_files("LzFindMt.c", "LzFindOpt.c", "MtCoder.c", "MtDec.c", "Threads.c", "DllSecur.c", "Lzma2DecMt.c")
                    add_headerfiles("LzFindMt.h", "Lzma2DecMt.h")
                else
                    add_defines("_7ZIP_ST")
                end
        ]])
        import("package.tools.xmake").install(package, {kind = package:config("shared") and "shared" or "static"})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("LzmaCompress", {includes = "LzmaLib.h"}))
    end)
