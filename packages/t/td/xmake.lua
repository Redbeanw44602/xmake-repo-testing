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
        add_syslinks("ws2_32", "mswsock", "crypt32", "normaliz", "psapi")
    end
    if is_plat("android") then
        add_syslinks("log")
    end

    on_load(function(package)
        package:add("links", "tdjson", "tdjson_static", "tdjson_private", "tdclient", "tdcore", "tdcore_part1", "tdcore_part2", "tdmtproto", "tdapi", "tddb", "tdsqlite", "tdnet", "tdactor", "tde2e", "tdutils")
        if not package:config("shared") then
            package:add("defines", "TDJSON_STATIC_DEFINE")
        end
        if package:is_cross() then
            package:add("deps", "tdtl " .. package:version_str())
        end
    end)

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DTD_INSTALL_STATIC_LIBRARIES=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DTD_INSTALL_SHARED_LIBRARIES=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DTD_ENABLE_LTO=" .. (package:config("lto") and "ON" or "OFF"))
        if package:is_cross() then
            os.cd("td/generate")
            os.mkdir("auto")
            print("Generate TLO files")
            assert(os.exec("tl-parser -e auto/tlo/mtproto_api.tlo scheme/mtproto_api.tl"))
            assert(os.exec("tl-parser -e auto/tlo/secret_api.tlo scheme/secret_api.tl"))
            assert(os.exec("tl-parser -e auto/tlo/e2e_api.tlo scheme/e2e_api.tl"))
            assert(os.exec("tl-parser -e auto/tlo/td_api.tlo scheme/td_api.tl"))
            assert(os.exec("tl-parser -e auto/tlo/telegram_api.tlo scheme/telegram_api.tl"))
            os.cd("auto")
            print("Generate MTProto API source files")
            assert(os.exec("generate_mtproto"))
            print("Generate common TL source files")
            assert(os.exec("generate_common"))
            print("Generate JSON TL source files")
            assert(os.exec("generate_json"))
            print("Generate MIME Types source files")
            os.cd("..")
            assert(os.exec("generate_mime_types_gperf mime_types.txt auto/mime_type_to_extension.gperf auto/extension_to_mime_type.gperf"))
            assert(os.exec("gperf -m100 --output-file=auto/mime_type_to_extension.cpp auto/mime_type_to_extension.gperf"))
            assert(os.exec("gperf -m100 --output-file=auto/extension_to_mime_type.cpp auto/extension_to_mime_type.gperf"))
        end

        import("package.tools.cmake").install(package, configs, {target = package:config("shared") and "tdjson" or "tdjson_static"})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                td_json_client_create();
            }
        ]]}, {configs = {languages = "c++17"}, includes = "td/telegram/td_json_client.h"}))
    end)
