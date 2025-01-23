workspace(name = "SimpleBankAPI")

# Load the correct repository rules
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

# Configure CC toolchain
http_archive(
    name = "rules_cc",
    sha256 = "35f2fb4ea0b3e61ad64a369de284e4fbbdcdba71836a5555abb5e194cf119509",
    strip_prefix = "rules_cc-624b5d59dfb45672d4239422fa1e3de1822ee110",
    urls = [
        "https://github.com/bazelbuild/rules_cc/archive/624b5d59dfb45672d4239422fa1e3de1822ee110.tar.gz",
    ],
)

# Swift rules
http_archive(
    name = "build_bazel_rules_swift",
    sha256 = "abbc41234c37031bc2c561a80fe8a2f8d95efcbbf2a2cb61be0b7201b5dd01a9",
    url = "https://github.com/bazelbuild/rules_swift/releases/download/1.12.0/rules_swift.1.12.0.tar.gz",
)

# Load Swift dependencies
load("@build_bazel_rules_swift//swift:repositories.bzl", "swift_rules_dependencies")
swift_rules_dependencies()

# Vapor dependencies with module mapping
git_repository(
    name = "vapor",
    remote = "https://github.com/vapor/vapor.git",
    tag = "4.76.0",
    build_file = "//:vapor.BUILD",
)

git_repository(
    name = "fluent",
    remote = "https://github.com/vapor/fluent.git",
    tag = "4.8.0",
    build_file = "//:fluent.BUILD",
)

git_repository(
    name = "fluent-postgres-driver",
    remote = "https://github.com/vapor/fluent-postgres-driver.git",
    tag = "2.7.2",
    build_file = "//:fluent-postgres-driver.BUILD",
)

load(
    "@build_bazel_rules_swift//swift:extras.bzl",
    "swift_rules_extra_dependencies",
)
swift_rules_extra_dependencies()