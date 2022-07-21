sshpass

Note: we can consider porting the build to Bazel, this is riddled with edge
cases and needs to done on Apple Silicon

This program is used to create a VM used either in an intenral network or
scenario prior to adding an pass.

You can re-create the program on Apple Silicon

Source URLS for sshpass:
https://sourceforge.net/projects/sshpass/files/sshpass/1.06/sshpass-1.06.tar.gz/download

```
"./configure", "--disable-debug", "--disable-dependency-tracking"
system "make install"
```
