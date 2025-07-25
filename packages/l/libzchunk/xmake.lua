package("libzchunk")
    set_homepage("https://github.com/zchunk/zchunk")
    set_description("A file format designed for highly efficient deltas while maintaining good compression.")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/zchunk/zchunk/archive/refs/tags/$(version).tar.gz",
             "https://github.com/zchunk/zchunk.git")

    add_versions("1.5.1", "2c187055e2206e62cef4559845e7c2ec6ec5a07ce1e0a6044e4342e0c5d7771d")

    add_configs("with_zstd", {description = "Enable compression support.", default = false, type = "boolean"})
    add_configs("with_openssl", {description = "Use openssl or bundled sha libraries.", default = false, type = "boolean"})

    add_deps("meson", "ninja")
    on_load(function(package)
        if package:config("with_zstd") then
            package:add("deps", "zstd")
        end
        if package:config("with_openssl") then
            package:add("deps", "openssl3")
        end
    end)

    on_install(function (package)
        local configs = {
            '-Ddocs=false',
            '-Dtests=false',
            '-Dwith-curl=disabled'
        }
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        table.insert(configs, "-Dwith-zstd=" .. (package:config("with_zstd") and "enabled" or "disabled"))
        table.insert(configs, "-Dwith-openssl=" .. (package:config("with_openssl") and "enabled" or "disabled"))

        io.replace("meson.build", "subdir('src')", "subdir('src/lib')", {plain = true})

        import("package.tools.meson").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            void test() {
                zck_create();
            }
        ]]}, {configs = {languages = "c99"}, includes = "zck.h"}))
    end)