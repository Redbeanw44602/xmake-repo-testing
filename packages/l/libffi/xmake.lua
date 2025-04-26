package("libffi")
    set_homepage("https://sourceware.org/libffi/")
    set_description("Portable Foreign Function Interface library.")
    set_license("MIT")

    set_urls("https://github.com/libffi/libffi/archive/refs/tags/$(version).tar.gz")
    add_versions("v3.2", "6c3fb7bb571cbb4bc92d9f256c9a339615df55b4177c853711b85420e1bbee84")
    add_versions("v3.2.1", "96d08dee6f262beea1a18ac9a3801f64018dc4521895e9198d029d6850febe23")
    add_versions("v3.3", "3f2f86094f5cf4c36cfe850d2fe029d01f5c2c2296619407c8ba0d8207da9a6b")
    add_versions("v3.4.0", "f6cf553720c7b7d901123acab8f3383778e51cd4da4cf0d0f88e54282422e58e")
    add_versions("v3.4.1", "d55328d89aae2c13439148a6102bcb66e272dffc0a8567475db52717ad290e6a")
    add_versions("v3.4.2", "0acbca9fd9c0eeed7e5d9460ae2ea945d3f1f3d48e13a4c54da12c7e0d23c313")
    add_versions("v3.4.3", "66fe321955762834b47efefc7935d96d14fb0ebeb86f7d31516691cbd3b09b29")
    add_versions("v3.4.4", "828639972716ed18833df7b659b32060591fe0eb625a8d34078920d33c2dc867")
    add_versions("v3.4.5", "0b942b74ed3ffc5e7670187a7ddb23ad5b51ed8d14317737f26e0431d1258f53")
    add_versions("v3.4.6", "9ac790464c1eb2f5ab5809e978a1683e9393131aede72d1b0a0703771d3c6cda")
    add_versions("v3.4.7", "f07c08c9c14977eafb9b5f9277713d91358ec18fc8aaa5607d6790cde90cba12")
    add_versions("v3.4.8", "cbb7f0b3b095dc506387ec1e35b891bfb4891d05b90a495bc69a10f2293f80ff")
    
    add_patches("<=3.4.4 >3.4.2", "patches/forward-declare-open_temp_exec_file.patch", "1c9809cc4fba7fc48e2f4261476581d7b72527c3b026c53e106718a039b1bed6")

    if is_plat("linux") then
        add_extsources("apt::libffi-dev", "pacman::libffi")
    elseif is_plat("macosx") then
        add_extsources("brew::libffi")
    end

    on_load("windows", function (package)
        if not package:config("shared") then
            package:add("defines", "FFI_STATIC_BUILD")
        end
    end)

    on_load("macosx", "linux", "bsd", "mingw", function (package)
        package:add("deps", "autoconf", "libtool")
        package:add("deps", "automake <1.17") -- https://github.com/libffi/libffi/issues/853#issuecomment-2306885792
    end)

    -- on_install("windows", "iphoneos", "cross", function (package)
    --     io.gsub("fficonfig.h.in", "# *undef (.-)\n", "${define %1}\n")
    --     os.cp(path.join(os.scriptdir(), "port", "xmake.lua"), "xmake.lua")
    --     import("package.tools.xmake").install(package, {
    --         vers = package:version_str()
    --     }) 
    -- end)

    on_install("macosx", "linux", "bsd", "mingw", function (package)
        -- https://github.com/libffi/libffi/issues/127
        local configs = {
            "--disable-docs",
            "--disable-silent-rules",
            "--disable-dependency-tracking",
            "--disable-multi-os-directory"
        }
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        table.insert(configs, "--enable-debug=" .. (package:config("debug") and "yes" or "no"))
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("ffi_closure_alloc", {includes = "ffi.h"}))
    end)
