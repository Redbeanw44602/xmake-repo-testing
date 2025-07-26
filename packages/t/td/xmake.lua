package("td")
    set_homepage("https://core.telegram.org/tdlib/")
    set_description("Cross-platform library for building Telegram clients.")
    set_license("BSL-1.0")

    -- td doesn't seem to like tags, so we go directly to commit id.
    -- @see https://github.com/tdlib/td/commits/HEAD/example/web/tdweb/package.json
    add_urls("https://github.com/tdlib/td.git")
    add_versions("1.8.51", "bb474a201baa798784d696d2d9d762a9d2807f96")

    add_deps("cmake")
    add_deps("openssl3", "zlib", "gperf")
    if is_plat("linux", "android", "bsd") then
        add_syslinks("pthread", "dl")
    end
    if is_plat("windows", "mingw", "msys", "cygwin") then
        add_syslinks("ws2_32", "mswsock", "crypt32")
    end

    on_load(function(package)
        package:add("links", "tdjson", "tdjson_static", "tdjson_private", "tdclient", "tdcore", "tdcore_part1", "tdcore_part2", "tdmtproto", "tdapi", "tddb", "tdsqlite", "tdnet", "tdactor", "tde2e", "tdutils")
        if not package:config("shared") then
            package:add("defines", "TDJSON_STATIC_DEFINE")
        end
    end)

    on_install(function (package)
        local configs = {
            "-DBUILD_TESTING=OFF"
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DTD_INSTALL_STATIC_LIBRARIES=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DTD_INSTALL_SHARED_LIBRARIES=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DTD_ENABLE_LTO=" .. (package:config("lto") and "ON" or "OFF"))

        io.replace("CMakeLists.txt", "add_subdirectory(benchmark)", "", {plain = true})
        io.replace("CMakeLists.txt", "# EXECUTABLES\nif (EMSCRIPTEN)", "if (0)", {plain = true})
        io.replace("CMakeLists.txt", "if (NOT CMAKE_CROSSCOMPILING)\n  add_executable(tg_cli", "if (0)\n#", {plain = true})
        io.replace("tdutils/CMakeLists.txt", "TD_TEST_FOLLY AND ABSL_FOUND AND TDUTILS_USE_EXTERNAL_DEPENDENCIES", "0", {plain = true})
        io.replace("tddb/CMakeLists.txt", "add_executable%(binlog_dump.-%)", "")
        io.replace("tddb/CMakeLists.txt", "target_link_libraries%(binlog_dump.-%)", "")
        io.replace("tde2e/CMakeLists.txt", "add_executable%(test%-e2e.-%)", "")
        io.replace("tde2e/CMakeLists.txt", "target_link_libraries%(test%-e2e.-%)", "")
        io.replace("tde2e/CMakeLists.txt", "target_include_directories%(test%-e2e.-%)", "")
        io.replace("tdactor/CMakeLists.txt", "add_executable%(example.-%)", "")
        io.replace("tdactor/CMakeLists.txt", "target_link_libraries%(example.-%)", "")

        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                td_json_client_create();
            }
        ]]}, {configs = {languages = "c++17"}, includes = "td/telegram/td_json_client.h"}))
    end)
