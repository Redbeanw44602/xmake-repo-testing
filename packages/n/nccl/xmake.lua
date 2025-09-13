package("nccl")
    set_homepage("https://developer.nvidia.com/nccl")
    set_description("Optimized primitives for collective multi-GPU communication.")

    set_urls("https://github.com/NVIDIA/nccl.git")
    add_versions("2.27.7",  "593de54e52679b51428571c13271e2ea9f91b1b1")

    add_deps("cuda")
    on_install("linux", function (package)
        import("detect.sdks.find_cuda")

        local cuda = assert(find_cuda())
        local configs = {}
        table.insert(configs, ("CUDA_HOME=\"%s\""):format(cuda.sdkdir))

        import("package.tools.make").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cincludes("nccl.h"))
    end)
