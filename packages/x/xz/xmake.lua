package("xz")
    set_homepage("https://tukaani.org/xz/")
    set_description("General-purpose data compression with high compression ratio.")

    set_urls("https://github.com/tukaani-project/xz/releases/download/v$(version)/xz-$(version).tar.gz",
             "https://downloads.sourceforge.net/project/lzmautils/xz-$(version).tar.gz")
    add_versions("5.8.1", "507825b599356c10dca1cd720c9d0d0c9d5400b9de300af00e4d1ea150795543")

    add_deps("cmake")
    on_load(function (package)
        if package:is_plat("windows") and not package:config("shared") then
            package:add("defines", "LZMA_API_STATIC")
        end
    end)

    on_install(function (package)
        local configs = {
            "-DXZ_TOOL_XZDEC=OFF",
            "-DXZ_TOOL_LZMADEC=OFF",
            "-DXZ_TOOL_LZMAINFO=OFF",
            "-DXZ_TOOL_XZ=OFF",
            "-DXZ_TOOL_SYMLINKS=OFF",
            "-DXZ_TOOL_SYMLINKS_LZMA=OFF",
            "-DXZ_TOOL_SCRIPTS=OFF",
            "-DXZ_DOXYGEN=OFF",
            "-DXZ_DOC=OFF"
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))

        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                lzma_version_string();
            }
        ]]}, {configs = {languages = "c11"}, includes = "lzma.h"}))
    end)
