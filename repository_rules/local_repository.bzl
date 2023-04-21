def _local_repository_impl(repository_ctx):
    repository_ctx.file("BUILD.bazel", repository_ctx.attr.build_file_content)

local_repository = repository_rule(
    implementation = _local_repository_impl,
    attrs = {
        "build_file_content": attr.string(
            mandatory = True,
        ),
    },
)
