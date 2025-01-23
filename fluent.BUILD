load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

swift_library(
    name = "fluent",
    srcs = glob(["Sources/**/*.swift"]),
    module_name = "Fluent",
    visibility = ["//visibility:public"],
    deps = ["@vapor//:Vapor"],
)