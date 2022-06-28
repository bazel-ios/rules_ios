# Plaid Link for iOS [![version][link-sdk-version]][link-sdk-url]

📱 This repository contains a sample application for [Swift](LinkDemo-Swift) (requiring Xcode 11) that demonstrates integration and use of Plaid Link for iOS.

📚 Detailed instructions on how to integrate with Plaid Link for iOS can be found in our main documentation at [plaid.com/docs/link/ios][link-ios-docs]. For details on how to migrate from LinkKit 1.x to LinkKit 2.x please review the [Link Migration Guide][link-1-2-migration].

1️⃣  The previous major version of LinkKit can be found on the [main-v1][link-main-v1] branch.

## About the LinkDemo Xcode projects

Plaid Link can be used for different use-cases and the sample applications demonstrate how to use Plaid Link for iOS for each use-case.
For clarity between the different use cases each use case specific example showing how to integrate Plaid Link for iOS is implemented in a Swift extension.

Before building and running the sample application replace any Xcode placeholder strings (like `<#GENERATED_LINK_TOKEN#>`) in the code with the appropriate value so that Plaid Link is configured properly. For convenience the Xcode placeholder strings are also marked as compile-time warnings.

Select your desired use-case in [`ViewController.didTapButton`](https://github.com/plaid/plaid-link-ios/search?q=didtapbutton) then build and run the demo application to experience the particular Link flow for yourself.

[link-ios-docs]: https://plaid.com/docs/link/ios
[link-sdk-version]: https://img.shields.io/cocoapods/v/Plaid
[link-sdk-url]: https://cocoapods.org/pods/Plaid
[link-1-2-migration]: https://plaid.com/docs/link/ios/ios-v2-migration
[link-main-v1]: https://github.com/plaid/plaid-link-ios/tree/main-v1
