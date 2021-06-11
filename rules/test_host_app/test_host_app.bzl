"""
Generates test host ios_application targets for each supported version

A consumer of `rules_ios` can optionally load the `generate_test_host_apps` symbol
and pass in additional attributes to be set in all `ios_application` rules
"""

load("//rules:app.bzl", "ios_application")

def generate_test_host_apps(**kwargs):
    versions = [
        "9.3",
        "10.0",
        "11.0",
        "12.0",
        "12.2",
        "12.4",
        "13.0",
        "13.2",
        "13.6",
        "14.0",
        "14.1",
        "14.2",
        "14.3",
    ]
    for version in versions:
        ios_application(
            name = "iOS-{}-AppHost".format(version),
            srcs = ["main.m"],
            bundle_id = "com.example.ios-app-host-{}".format(version),
            entitlements = "ios.entitlements",
            families = [
                "iphone",
                "ipad",
            ],
            launch_storyboard = "LaunchScreen.storyboard",
            minimum_os_version = version,
            visibility = ["//visibility:public"],
            **kwargs
        )
