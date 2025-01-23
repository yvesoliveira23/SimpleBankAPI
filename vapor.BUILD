load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

swift_library(
    name = "Vapor",
    srcs = glob(
        ["Sources/Vapor/**/*.swift"],
        exclude = [
            "Sources/XCTVapor/**/*",
            "Tests/**/*",
        ],
    ),
    module_name = "Vapor",
    visibility = ["//visibility:public"],
)