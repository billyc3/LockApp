import WatchKit

class ExtensionDelegate: NSObject, WKExtensionDelegate {
    private let connectivityManager = WatchConnectivityManager.shared

    func applicationDidFinishLaunching() {}
    func applicationDidBecomeActive() {}
    func applicationWillResignActive() {}
}
