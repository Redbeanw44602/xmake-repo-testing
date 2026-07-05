package("mdns_cpp")
    set_homepage("https://github.com/gocarlos/mdns_cpp")
    set_description("A simple mDNS service with C++ interface.")
    set_license("MIT")

    add_urls("https://github.com/gocarlos/mdns_cpp.git")
    add_versions("2022.9.7", "05b181ca2b3920b787287a291fae326ecd0ef019")

    add_deps("cmake")

    -- add_deps("mdns") -- we cannot unbundle mdns currently because mdns_cpp is designed for mdns <= 1.3.

    if is_plat("windows", "mingw") then
        add_syslinks("iphlpapi", "ws2_32")
    end
    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    on_check("android", function (package)
        local ndk = package:toolchain("ndk")
        local ndk_sdkver = ndk:config("ndk_sdkver")
        assert(ndk_sdkver and tonumber(ndk_sdkver) >= 24, "package(mdns_cpp): need ndk api level >= 24")
    end)

    on_install("!wasm", function (package)
        -- os.rm("src/mdns.h")
        -- io.replace("CMakeLists.txt", "src/mdns.h", "", {plain = true})
        if package:is_plat("windows") then
            io.replace("CMakeLists.txt", "target_link_libraries(${PROJECT_NAME} INTERFACE iphlpapi ws2_32)", "target_link_libraries(${PROJECT_NAME} PUBLIC iphlpapi ws2_32)")
        end
        if package:is_plat("mingw") then
            -- @see https://github.com/gocarlos/mdns_cpp/issues/8
            io.replace("src/mdns.cpp", "sock_addr.sin_addr = in4addr_any;", "sock_addr.sin_addr.s_addr = INADDR_ANY;", {plain = true})
        end
        if package:is_plat("bsd") then
            -- To fix incomplete type sockaddr error.
            io.insert("src/utils.cpp", 0, [[#include "mdns.h"]])
        end

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