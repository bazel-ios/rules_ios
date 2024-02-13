FrameworkInfo = provider(
    fields = {
        "binary": "The binary of the framework",
        "headers": "Headers of the framework's public interface",
        "modulemap": "The module map of the framework",
        "private_headers": "Private headers of the framework",
        "swiftdoc": " The Swift doc",
        "swiftmodule": "The swiftmodule",
        "vfsoverlay_infos": "Merged VFS overlay infos, present when virtual frameworks enabled",
    },
)

AvoidDepsInfo = provider(
    fields = {
        "libraries": "Libraries to avoid",
        "link_dynamic": "Weather or not if this dep is dynamic",
    },
)
