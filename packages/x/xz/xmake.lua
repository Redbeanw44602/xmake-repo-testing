package("xz")
    set_homepage("https://tukaani.org/xz/")
    set_description("General-purpose data compression with high compression ratio.")

    set_urls("https://github.com/tukaani-project/xz/releases/download/v$(version)/xz-$(version).tar.gz",
             "https://downloads.sourceforge.net/project/lzmautils/xz-$(version).tar.gz")
    add_versions("5.2.5", "f6f4910fd033078738bd82bfba4f49219d03b17eb0794eb91efbae419f4aba10")
    add_versions("5.2.10", "eb7a3b2623c9d0135da70ca12808a214be9c019132baaa61c9e1d198d1d9ded3")
    add_versions("5.2.13", "2942a1a8397cd37688f79df9584947d484dd658db088d51b790317eb3184827b")
    add_versions("5.4.1", "e4b0f81582efa155ccf27bb88275254a429d44968e488fc94b806f2a61cd3e22")
    add_versions("5.4.6", "aeba3e03bf8140ddedf62a0a367158340520f6b384f75ca6045ccc6c0d43fd5c")
    add_versions("5.4.7", "8db6664c48ca07908b92baedcfe7f3ba23f49ef2476864518ab5db6723836e71")
    add_versions("5.6.4", "269e3f2e512cbd3314849982014dc199a7b2148cf5c91cedc6db629acdf5e09b")
    add_versions("5.8.1", "507825b599356c10dca1cd720c9d0d0c9d5400b9de300af00e4d1ea150795543")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = is_plat("wasm")})

    add_deps("cmake")
    on_load(function (package)
        if package:is_plat("windows") and not package:config("shared") then
            package:add("defines", "LZMA_API_STATIC")
        end
    end)

    on_install(function (package)
        local configs = {
            "-DXZ_NLS=OFF",
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
