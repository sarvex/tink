"""
Dependencies of C++ Tink.
"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def tink_cc_deps():
    """ Loads dependencies of C++ Tink.

    """

    if not native.existing_rule("com_google_absl"):
        # Commit from 2021-12-03
        http_archive(
            name = "com_google_absl",
            strip_prefix = "abseil-cpp-9336be04a242237cd41a525bedfcf3be1bb55377",
            url = "https://github.com/abseil/abseil-cpp/archive/9336be04a242237cd41a525bedfcf3be1bb55377.zip",
            sha256 = "368be019fc8d69a566ac2cf7a75262d5ba8f6409e3ef3cdbcf0106bdeb32e91c",
        )

    if not native.existing_rule("boringssl"):
        # Commit from 2021-07-02
        http_archive(
            name = "boringssl",
            strip_prefix = "boringssl-7686eb8ac9bc60198cbc8354fcba7f54c02792ec",
            url = "https://github.com/google/boringssl/archive/7686eb8ac9bc60198cbc8354fcba7f54c02792ec.zip",
            sha256 = "73a7bc71f95f3259ddedc6cb5ba45d02f2359c43e75af354928b0471a428bb84",
        )

    # GoogleTest/GoogleMock framework. Used by most C++ unit-tests.
    if not native.existing_rule("com_google_googletest"):
        # Release from 2019-10-03
        http_archive(
            name = "com_google_googletest",
            strip_prefix = "googletest-1.10.x",
            url = "https://github.com/google/googletest/archive/v1.10.x.zip",
            sha256 = "54a139559cc46a68cf79e55d5c22dc9d48e647a66827342520ce0441402430fe",
        )

    if not native.existing_rule("rapidjson"):
        # Release from 2016-08-25; still the latest release on 2019-10-18
        http_archive(
            name = "rapidjson",
            url = "https://github.com/Tencent/rapidjson/archive/v1.1.0.tar.gz",
            sha256 = "bf7ced29704a1e696fbccf2a2b4ea068e7774fa37f6d7dd4039d0787f8bed98e",
            strip_prefix = "rapidjson-1.1.0",
            build_file = "@tink_cc//:third_party/rapidjson.BUILD.bazel",
        )

    if not native.existing_rule("aws_cpp_sdk"):
        # Release from 2020-06-01
        http_archive(
            name = "aws_cpp_sdk",
            # Must be in sync with defines in third_party/aws_sdk_cpp.BUILD.bazel.
            url = "https://github.com/aws/aws-sdk-cpp/archive/1.7.345.tar.gz",
            sha256 = "7df6491e6e0fac726c00b5e6298d5749b131b25a3dd8b905eb311dc7dcc97aaf",
            strip_prefix = "aws-sdk-cpp-1.7.345",
            build_file = "@tink_cc//:third_party/aws_sdk_cpp.BUILD.bazel",
        )

    if not native.existing_rule("aws_c_common"):
        http_archive(
            name = "aws_c_common",
            url = "https://github.com/awslabs/aws-c-common/archive/v0.4.29.tar.gz",
            sha256 = "01c2a58553a37b3aa5914d9e0bf7bf14507ff4937bc5872a678892ca20fcae1f",
            strip_prefix = "aws-c-common-0.4.29",
            build_file = "@tink_cc//:third_party/aws_c_common.BUILD.bazel",
        )

    if not native.existing_rule("aws_c_event_stream"):
        http_archive(
            name = "aws_c_event_stream",
            url = "https://github.com/awslabs/aws-c-event-stream/archive/v0.1.4.tar.gz",
            sha256 = "31d880d1c868d3f3df1e1f4b45e56ac73724a4dc3449d04d47fc0746f6f077b6",
            strip_prefix = "aws-c-event-stream-0.1.4",
            build_file = "@tink_cc//:third_party/aws_c_event_stream.BUILD.bazel",
        )

    if not native.existing_rule("aws_checksums"):
        http_archive(
            name = "aws_checksums",
            url = "https://github.com/awslabs/aws-checksums/archive/v0.1.5.tar.gz",
            sha256 = "6e6bed6f75cf54006b6bafb01b3b96df19605572131a2260fddaf0e87949ced0",
            strip_prefix = "aws-checksums-0.1.5",
            build_file = "@tink_cc//:third_party/aws_checksums.BUILD.bazel",
        )

    # gRPC needs rules_apple, which in turn needs rules_swift and apple_support
    if not native.existing_rule("build_bazel_rules_apple"):
        # Last commit available at 2020-04-28
        http_archive(
            name = "build_bazel_rules_apple",
            strip_prefix = "rules_apple-3043ed832213cb979b6580d19f95ab8473814fb5",
            url = "https://github.com/bazelbuild/rules_apple/archive/3043ed832213cb979b6580d19f95ab8473814fb5.zip",
            sha256 = "ff18125271214a4e3633241bf3f9a8a0c6b4f4b208f9fee4b360e9fa15538f8a",
        )
    if not native.existing_rule("build_bazel_rules_swift"):
        # Last commit available at 2020-04-28
        http_archive(
            name = "build_bazel_rules_swift",
            strip_prefix = "rules_swift-8767e70f1a8b500f5f3683cb23258964737a3888",
            url = "https://github.com/bazelbuild/rules_swift/archive/8767e70f1a8b500f5f3683cb23258964737a3888.zip",
            sha256 = "cc9d87e67afa75c936eed4725e29ed05ba9a542bc586f943d3333cc6406d6bfc",
        )
    if not native.existing_rule("build_bazel_apple_support"):
        # Last commit available at 2020-04-28
        http_archive(
            name = "build_bazel_apple_support",
            strip_prefix = "apple_support-501b4afb27745c4813a88ffa28acd901408014e4",
            url = "https://github.com/bazelbuild/apple_support/archive/501b4afb27745c4813a88ffa28acd901408014e4.zip",
            sha256 = "8aa07a6388e121763c0164624feac9b20841afa2dd87bac0ba0c3ed1d56feb70",
        )

    # Needed for Cloud KMS API via gRPC.
    if not native.existing_rule("com_google_googleapis"):
        # Commit from 2020-04-09
        http_archive(
            name = "com_google_googleapis",
            url = "https://github.com/googleapis/googleapis/archive/ee4ea76504aa60c2bff9b7c11269c155d8c21e0d.zip",
            sha256 = "687e5b241d365a59d4b95c60d63df07931476c7d14b0c261202ae2aceb44d119",
            strip_prefix = "googleapis-ee4ea76504aa60c2bff9b7c11269c155d8c21e0d",
        )

    if "upb" not in native.existing_rules():
        # Commit from 2020-12-18; matches version embedded in com_github_grpc_grpc
        http_archive(
            name = "upb",
            sha256 = "c0b97bf91dfea7e8d7579c24e2ecdd02d10b00f3c5defc3dce23d95100d0e664",
            strip_prefix = "upb-60607da72e89ba0c84c84054d2e562d8b6b61177",
            url = "https://github.com/protocolbuffers/upb/archive/60607da72e89ba0c84c84054d2e562d8b6b61177.tar.gz",
        )

    if "envoy_api" not in native.existing_rules():
        # Commit from 2021-05-05
        http_archive(
            name = "envoy_api",
            sha256 = "47429de51618f9b247c0ef44e23a06e8a9165efd1b1d6e35c86978b4f69adeba",
            strip_prefix = "data-plane-api-1e94aaf06de0dbfee295f785bf49fcc61fb2fb14",
            url = "https://github.com/envoyproxy/data-plane-api/archive/1e94aaf06de0dbfee295f785bf49fcc61fb2fb14.tar.gz",
        )

    # gRPC.
    if not native.existing_rule("com_github_grpc_grpc"):
        # Release from 2021-04-29
        http_archive(
            name = "com_github_grpc_grpc",
            url = "https://github.com/grpc/grpc/archive/refs/tags/v1.37.1.zip",
            sha256 = "2a0aef1d60660d4c4ff2bc7f43708e5df561e41c9f98d0351f9672f965a8461f",
            strip_prefix = "grpc-1.37.1",
        )

    # Not used by Java Tink, but apparently needed for C++ gRPC library.
    if not native.existing_rule("io_grpc_grpc_java"):
        # Release from 2021-04-08
        http_archive(
            name = "io_grpc_grpc_java",
            strip_prefix = "grpc-java-1.37.0",
            url = "https://github.com/grpc/grpc-java/archive/v1.37.0.tar.gz",
            sha256 = "4796b6e434545ecc9e827f9ba52c0604a3c84e175c54f0882121965b1ee5c367",
        )

    if not native.existing_rule("curl"):
        # Release from 2016-05-30
        http_archive(
            name = "curl",
            url = "https://mirror.bazel.build/curl.haxx.se/download/curl-7.49.1.tar.gz",
            sha256 = "ff3e80c1ca6a068428726cd7dd19037a47cc538ce58ef61c59587191039b2ca6",
            strip_prefix = "curl-7.49.1",
            build_file = "@tink_cc//:third_party/curl.BUILD.bazel",
        )

    if not native.existing_rule("zlib"):
        # Releaes from 2017-01-15; still most recent release on 2019-10-18
        http_archive(
            name = "zlib",
            url = "https://mirror.bazel.build/zlib.net/zlib-1.2.11.tar.gz",
            sha256 = "c3e5e9fdd5004dcb542feda5ee4f0ff0744628baf8ed2dd5d66f8ca1197cb1a1",
            strip_prefix = "zlib-1.2.11",
            build_file = "@tink_cc//:third_party/zlib.BUILD.bazel",
        )

    # wycheproof, for JSON test vectors
    if not native.existing_rule("wycheproof"):
        # Commit from 2019-12-17
        http_archive(
            name = "wycheproof",
            strip_prefix = "wycheproof-d8ed1ba95ac4c551db67f410c06131c3bc00a97c",
            url = "https://github.com/google/wycheproof/archive/d8ed1ba95ac4c551db67f410c06131c3bc00a97c.zip",
            sha256 = "eb1d558071acf1aa6d677d7f1cabec2328d1cf8381496c17185bd92b52ce7545",
        )
