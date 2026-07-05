package("nanors")
    set_homepage("https://github.com/sleepybishop/nanors")
    set_description("Fast reed solomon codes in GF2^8.")
    set_license("MIT")

    add_urls("https://github.com/sleepybishop/nanors.git")
    add_versions("2026.7.5", "c3529fda520f53cd007328ba30b6ad3f89947722")

    on_check(function (package)
        if package:is_arch("arm.*") and package:check_sizeof("void*") ~= "8" then
            raise("package(nanors): unsupported arch!")
        end
    end)

    on_install("!wasm and !windows", function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            set_languages("c11")
            target("nanors")
                set_kind("$(kind)")
                set_optimize("fastest")
                add_cflags("-march=native", "-funroll-loops", "-ftree-vectorize")
                add_files("*.c", "deps/obl/*.c")
                add_includedirs(".", "deps/obl")
                add_headerfiles("*.h", "deps/obl/oblas_common.h")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("reed_solomon_init", {includes = "rs.h"}))
    end)
