package("libnfc")
    set_homepage("https://github.com/nfc-tools/libnfc")
    set_description("Header-only binary fuse and xor filter library.")
    set_license("LGPL-3.0")

    add_urls("https://github.com/nfc-tools/libnfc/archive/refs/tags/libnfc-$(version).tar.gz", {alias = "tarball"})
    add_urls("https://github.com/nfc-tools/libnfc.git", {alias = "git"})
    add_versions("tarball:1.8.0", "0ab7d9b41442e7edc2af7c54630396edc73ce51128aa28a5c6e4135dc5595495")
    add_versions("tarball:1.7.1", "30de35b4f1af3f57dab40d91ffb2275664a35859ff2b014ba7b226aa3f5465f5")
    add_versions("git:1.8.0", "libnfc-1.8.0")
    add_versions("git:1.7.1", "libnfc-1.7.1")

    add_configs("logging",      {description = "Enable log facility. (errors, warning, info and debug messages)", default = true, type = "boolean"})
    add_configs("envvars",      {description = "Enable envvars facility.", default = true, type = "boolean"})
    add_configs("configurable", {description = "Enable configuration files.", default = true, type = "boolean"})

    -- drivers
    add_configs("pcsc",         {description = "Enable PC/SC reader support (Depends on PC/SC)", default = false, type = "boolean"})
    add_configs("acr122_pcsc",  {description = "Enable ACR122 support (Depends on PC/SC)", default = false, type = "boolean"})
    add_configs("acr122_usb",   {description = "Enable ACR122 support (Direct USB connection)", default = true, type = "boolean"})
    add_configs("acr122s",      {description = "Enable ACR122S support (Use serial port)", default = true, type = "boolean"})
    add_configs("arygon",       {description = "Enable ARYGON support (Use serial port)", default = true, type = "boolean"})
    add_configs("pn532_i2c",    {description = "Enable PN532 I2C support (Use I2C bus)", default = is_plat("linux"), type = "boolean"})
    add_configs("pn532_spi",    {description = "Enable PN532 SPI support (Use SPI bus)", default = is_plat("linux"), type = "boolean"})
    add_configs("pn532_uart",   {description = "Enable PN532 UART support (Use serial port)", default = true, type = "boolean"})
    add_configs("pn53x_usb",    {description = "Enable PN531 and PN531 USB support (Depends on libusb)", default = true, type = "boolean"})

    add_deps("cmake")
    add_deps("libusb")
    -- TODO: xrepo missing deps.
    -- add_deps("pcsc")
    on_install(function (package)
        local configs = {
            "-DBUILD_EXAMPLES=OFF"
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))

        table.insert(configs, "-DLIBNFC_LOG=" .. (package:config("logging") and "ON" or "OFF"))
        table.insert(configs, "-DLIBNFC_ENVVARS=" .. (package:config("envvars") and "ON" or "OFF"))
        table.insert(configs, "-DLIBNFC_CONFFILES_MODE=" .. (package:config("configurable") and "ON" or "OFF"))

        table.insert(configs, "-DLIBNFC_DRIVER_PCSC=" .. (package:config("pcsc") and "ON" or "OFF"))
        table.insert(configs, "-DLIBNFC_DRIVER_ACR122_PCSC=" .. (package:config("acr122_pcsc") and "ON" or "OFF"))
        table.insert(configs, "-DLIBNFC_DRIVER_ACR122_USB=" .. (package:config("acr122_usb") and "ON" or "OFF"))
        table.insert(configs, "-DLIBNFC_DRIVER_ACR122S=" .. (package:config("acr122s") and "ON" or "OFF"))
        table.insert(configs, "-DLIBNFC_DRIVER_ARYGON=" .. (package:config("arygon") and "ON" or "OFF"))
        table.insert(configs, "-DLIBNFC_DRIVER_PN532_I2C=" .. (package:config("pn532_i2c") and "ON" or "OFF"))
        table.insert(configs, "-DLIBNFC_DRIVER_PN532_SPI=" .. (package:config("pn532_spi") and "ON" or "OFF"))
        table.insert(configs, "-DLIBNFC_DRIVER_PN532_UART=" .. (package:config("pn532_uart") and "ON" or "OFF"))
        table.insert(configs, "-DLIBNFC_DRIVER_PN53X_USB=" .. (package:config("pn53x_usb") and "ON" or "OFF"))

        io.replace("CMakeLists.txt", "INCLUDE(UseDoxygen)", "", {plain = true})
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            void test() {
                nfc_version();
            }
        ]]}, {configs = {languages = "c99"}, includes = "nfc/nfc.h"}))
    end)