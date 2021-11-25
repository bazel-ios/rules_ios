This is Bazel's Xcode autoconfigure with improvements for debugging

Adds a note to dump the Bazel error and retry if it fails. This is not a
measure to fix the problem, but to debug it and unblock CI. We don't have
access to SSH into the github CI so this atleast dumps the error so we can
further investigate.

Bazel puts this error in the build file which is a problem on the CI because it
swallows the error and it requires a user to clean --expunge. Bazel requires
the user to expunge because it thinks the repository was successfully written.
Probably a better pattern is to fail, but that won't shed light on the problem.

This is not just broken for CI but local developers. The plan is to use
rules_ios CI to reproduce this and gather more information then propose a fix
when we know more info.

