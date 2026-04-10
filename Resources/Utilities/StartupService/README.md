# StartupService

Global configuration without making `AppDelegate` look like a mess.

## Problem

`AppDelegate`'s `application(_ application:, didFinishLaunchingWithOptions:)` method is a place where we usually do some app configuration, apply default UI settings, initialize outside dependencies and so on.
The code might look something like this:

```swift
import UIKit
import FBSDKCoreKit
import TwitterKit
import Fabric
import Crashlytics

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
  // UI configuration
  UIScrollView.appearance().showsVerticalScrollIndicator = false
  UIScrollView.appearance().showsHorizontalScrollIndicator = false
  UINavigationBar.appearance().barTintColor = UIColor.white
  UINavigationBar.appearance().titleTextAttributes = [
  NSAttributedString.Key.font: UIFont.custom(type: .bold, size: 18),
  NSAttributedString.Key.foregroundColor: UIColor.white
  ]

  // FBSDK & TwitterKit setup
  FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
  TWTRTwitter.sharedInstance().start(withConsumerKey: "8e27389ej728e372dd", consumerSecret: "e238928d90283d908239d8239dn82093e8d923")

  // Fabric setup
  Fabric.with([Crashlytics.self])
  
  ...
  
  return true
}
```

There are two main issues with the code above:
First of all, the method is doing too many things at the same time, violating single responsibility principle. The second code smell is that we have to import a great number of dependencies. By using `StartupProcessService` we can refactor the code:

```swift
import Foundation

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
  StartupProcessService()
    .execute(process: AppearanceCustomisationProcess())
    .execute(process: FacebookSetupProcess(application: application, launchOptions: launchOptions))
    .execute(process: TwitterStartupProcess(application: application, launchOptions: launchOptions))
    .execute(process: FabricConfigurationStartupProcess())
  return true
}
```

The resulting code is much easier to understand, the method is now doing just one thing, that is, executing different startup processes, and there is no need to import other modules.
A startup process' code looks something like:

```swift
import FBSDKCoreKit

public final class FacebookSetupProcess: StartupProcess {
  private let launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  private let application: UIApplication

  init(application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
    self.application = application
    self.launchOptions = launchOptions
  }

  public func run(completion: @escaping (Bool) -> Void) {
    FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    completion(true)
  }
}
```

## Source code
You can find source code here:
- [StartupProcess](/Sources/Utilities/StartupService/StartupProcess.swift)
- [StartupProcessService](/Sources/Utilities/StartupService/StartupProcessService.swift)
