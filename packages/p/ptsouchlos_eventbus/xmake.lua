package("ptsouchlos_eventbus")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/ptsouchlos/eventbus")
    set_description("A simple, header only event bus library written in modern C++17.")
    set_license("Apache-2.0")

    add_urls("https://github.com/ptsouchlos/eventbus.git")
    add_versions("2026.1.18", "8e7e922ea8c205471450cca36dbab80add742fe3")

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    on_install(function (package)
        os.cp("eventbus/include", package:installdir())
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("dp::event_bus<>", {includes = "eventbus/event_bus.hpp", configs = {languages = "c++17"}}))
    end)