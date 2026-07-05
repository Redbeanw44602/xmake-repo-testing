package("mdns_cpp")
    set_kind("library")
    set_homepage("https://github.com/gocarlos/mdns_cpp")
    set_description("A simple mDNS service with C++ interface.")
    set_license("MIT")

    add_urls("https://github.com/gocarlos/mdns_cpp.git")
    add_versions("v2022.9.7", "05b181ca2b3920b787287a291fae326ecd0ef019")

    add_deps("cmake")

    -- add_deps("mdns") -- we cannot unbundle mdns currently because mdns_cpp is designed for mdns <= 1.3.

    if is_plat("windows", "mingw") then
        add_syslinks("iphlpapi", "ws2_3")
    end
    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    on_check("android", function (package)
        local ndk = package:toolchain("ndk")
        local ndk_sdkver = ndk:config("ndk_sdkver")
        assert(ndk_sdkver and tonumber(ndk_sdkver) >= 24, "package(mdns_cpp): need ndk api level >= 24")
    end)

    on_install(function (package)
        -- os.rm("src/mdns.h")
        -- io.replace("CMakeLists.txt", "src/mdns.h", "", {plain = true})

        local configs = {
            "-DMDNS_CPP_BUILD_EXAMPLE=OFF"
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs, {packagedeps = "mdns"})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "mdns_cpp/mdns.hpp"
            void test() {
                mdns_cpp::mDNS mdns;
                mdns.executeDiscovery();
            }
        ]]}, {configs = {languages = "c++20"}}))
    end)