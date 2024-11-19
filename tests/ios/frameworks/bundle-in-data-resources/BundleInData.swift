import Foundation

private class BundleInDataBundleFinder {}

// Helper for finding the bundle named "BundleInDataResources"
public extension Bundle {
    static let bundleInDataResources: Bundle = {
        let container = Bundle(for: BundleInDataBundleFinder.self)
        let bundlePath = container.path(forResource: "BundleInDataResources", ofType: "bundle")!
        return Bundle(path: bundlePath)!
    }()
}

