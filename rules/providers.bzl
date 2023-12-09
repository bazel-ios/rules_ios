FrameworkInfo = provider(
    fields = {
        "vfsoverlay_infos": "Merged VFS overlay infos, present when virtual frameworks enabled",
        "binary": "The binary of the framework",
        "headers": "Headers of the framework's public interface",
        "private_headers": "Private headers of the framework",
        "modulemap": "The module map of the framework",
        "swiftmodule": "The swiftmodule",
        "swiftdoc": " The Swift doc",
        "nodes": "nodes",
    },
)

AvoidDepsInfo = provider(
    fields = {
        "libraries": "Libraries to avoid",
        "link_dynamic": "Weather or not if this dep is dynamic",
    },
)

VFSOverlayInfo = provider(
    doc = "Propagates vfs overlays",
    fields = {
        "files": "depset with overlays",
        "vfs_info": "intneral obj",
        "nodes": "nodes",
    },
)

NewVFSInfo = provider(
    doc = "NewVFSInfo",
    fields = {
        "nodes": "nodes",
    },
)

PrivateHeadersInfo = provider(
    doc = "Propagates private headers, so they can be accessed if necessary",
    fields = {
        "headers": "Private headers",
    },
)
