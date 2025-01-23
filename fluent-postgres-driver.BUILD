load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

swift_library(
    name = "fluent-postgres-driver",
    srcs = glob(["Sources/**/*.swift"]),
    module_name = "FluentPostgresDriver",
    visibility = ["//visibility:public"],
    deps = [
        "@vapor//:Vapor",
        "@fluent//:fluent",
    ],
)