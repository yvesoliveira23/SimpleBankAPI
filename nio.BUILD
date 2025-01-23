load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

swift_library(
    name = "NIOCore",
    srcs = glob(["Sources/NIOCore/**/*.swift"]),
    module_name = "NIOCore",
    visibility = ["//visibility:public"],
)

swift_library(
    name = "NIO",
    srcs = glob(["Sources/NIO/**/*.swift"]),
    module_name = "NIO",
    visibility = ["//visibility:public"],
    deps = [":NIOCore"],
)

swift_library(
    name = "NIOConcurrencyHelpers",
    srcs = glob(["Sources/NIOConcurrencyHelpers/**/*.swift"]),
    module_name = "NIOConcurrencyHelpers",
    visibility = ["//visibility:public"],
    deps = [":NIOCore"],
)