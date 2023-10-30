"Bazel version parsing"

def get_bazel_version(bazel_version = getattr(native, "bazel_version", "")):
    """
    Parse the Bazel version into a `struct`.

    Args:
        bazel_version: String representing the Bazel version.

    Returns:
        Bazel version represented as a `struct` with the major, minor, and path
        attributes.
    """
    if bazel_version:
        parts = bazel_version.split(".")
        if len(parts) > 2:
            return struct(major = parts[0], minor = parts[1], patch = parts[2])

    # Unknown, but don't crash
    return struct(major = 0, minor = 0, patch = 0)
