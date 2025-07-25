package("libpcsclite")
    set_homepage("https://github.com/LudovicRousseau/PCSC")
    set_description("Middleware to access a smart card using SCard API (PC/SC).")

    add_urls("https://github.com/LudovicRousseau/PCSC/archive/refs/tags/$(version).tar.gz",
             "https://github.com/LudovicRousseau/PCSC.git")

    add_versions("2.3.3", "00b667aa71504ed1d39a48ad377de048c70dbe47229e8c48a3239ab62979c70f")

    add_configs("embedded", {description = "For embedded systems [limit RAM and CPU resources by disabling features (log)].", default = false, type = "boolean"})

    add_deps("meson")
    add_includedirs("include/PCSC")
    on_install(function (package)
        io.replace("meson.build", "executable%s*%b()", "")
        io.replace("meson.build", "library%('pcscspy'.-%)", "")
        io.replace("meson.build", "doxygen.found()", "false", {plain = true})

        local configs = {
            '-Dlibsystemd=false',
            '-Dpolkit=false'
        }
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))

        import("package.tools.meson").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            void test() {
                SCARDCONTEXT hSC;
                SCardEstablishContext(SCARD_SCOPE_USER, 0, 0, &hSC);
            }
        ]]}, {configs = {languages = "c99"}, includes = "winscard.h"}))
    end)
