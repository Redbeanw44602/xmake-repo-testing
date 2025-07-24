package("libusb-compat")
    set_homepage("https://github.com/libusb/libusb-compat-0.1")
    set_description("A compatibility layer allowing applications written for libusb-0.1 to work with libusb-1.0.")
    set_license("LGPL-2.1")

    add_urls("https://github.com/libusb/libusb-compat-0.1/archive/refs/tags/$(version).tar.gz",
             "https://github.com/libusb/libusb-compat-0.1.git")

    add_versions("v0.1.8", "73f8023b91a4359781c6f1046ae84156e06816aa5c2916ebd76f353d41e0c685")

    if is_plat("windows") then
        add_resources("*", "unistd_h", "https://github.com/win32ports/unistd_h.git", "0dfc48c1bc67fa27b02478eefe0443b8d2750cc2")
    end

    add_deps("libusb")
    on_install("!iphoneos and !bsd", function (package)
        if is_plat("windows") then
            local dir = package:resourcefile("unistd_h")
            os.cp(path.join(dir, "unistd.h"), os.curdir())
        end
        io.writefile("config.h", [[
            #define API_EXPORTED __attribute__((visibility("default")))
            #define ENABLE_DEBUG_LOGGING 0
            #define ENABLE_LOGGING 1
        ]])
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            add_requires("libusb")
            target("libusb-compat")
                set_kind("$(kind)")
                add_files("libusb/core.c")
                add_includedirs(".")
                add_headerfiles("libusb/usb.h")
                add_packages("libusb")
                if is_plat("wasm") then
                    add_defines("PATH_MAX=4096")
                end
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            void test() {
                usb_init();
            }
        ]]}, {configs = {languages = "c99"}, includes = "usb.h"}))
    end)
