package("openmpi")
    set_homepage("https://www.open-mpi.org/")
    set_description("Open MPI main development repository.")

    set_urls("https://download.open-mpi.org/release/open-mpi/$(version).tar.gz", {version = function(version)
        -- 5.0.8 -> v5.0/openmpi-5.0.8
        local semver = version:split(".", {plain = true})
        return ("v%s.%s/openmpi-%s"):format(semver[1], semver[2], version)
    end})

    add_versions("5.0.8", "f891ddf2dab3b604f2521d0569615bc1c07a1ac86a295ac543e059aecb303621")

    add_deps("hwloc", "libevent", "zlib-ng")
    if not is_plat("windows") then
        add_syslinks("z")
    end
    on_install(function (package)
        local configs = {
            "--disable-dependency-tracking"
        }
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            int main(int argc, char** argv) {
                MPI_Init(&argc, &argv);
            }
        ]]}, {configs = {languages = "c99"}, includes = "mpi.h"}))
    end)
