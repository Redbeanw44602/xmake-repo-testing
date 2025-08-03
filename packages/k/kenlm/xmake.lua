package("kenlm")
    set_homepage("https://kheafield.com/code/kenlm/")
    set_description("Faster and Smaller Language Model Queries.")
    set_license("LGPL-2.1-or-later")

    add_urls("https://github.com/kpu/kenlm.git")
    add_versions("2025.03.31", "4cb443e60b7bf2c0ddf3c745378f76cb59e254e5")

    add_configs("max_order", {description = "Maximum supported ngram order.", default = 6, type = "number"})

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    add_deps("cmake")
    add_deps("boost", {configs = {program_options = true, system = true, thread = true, test = true}})
    add_deps("zlib", "bzip2", "xz")
    add_includedirs("include/kenlm")
    on_load(function (package)
        package:add("defines", "KENLM_MAX_ORDER=" .. tostring(package:config("max_order")))
    end)

    on_install(function (package)
        local configs = {
            "BUILD_TESTING=OFF"
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DKENLM_MAX_ORDER=" .. tostring(package:config("max_order")))

        io.replace("cmake/KenLMFunctions.cmake", "function(AddExes)", "function(AddExes)\nreturn()", {plain = true})

        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                lm::ngram::Model model("hello");
            }
        ]]}, {configs = {languages = "c++11"}, includes = "lm/model.hh"}))
    end)
