import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let buildInfoChannel = "project_gtg/app_build_info"
  private let getBuildInfoMethod = "getBuildInfo"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)

    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: buildInfoChannel,
        binaryMessenger: controller.binaryMessenger
      )

      channel.setMethodCallHandler { [weak self] call, callback in
        guard call.method == self?.getBuildInfoMethod else {
          callback(FlutterMethodNotImplemented)
          return
        }

        let bundle = Bundle.main
        let versionName = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
        let versionCodeString = bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "0"
        let versionCode = Int(versionCodeString) ?? 0
        let packageName = bundle.bundleIdentifier ?? "project_gtg"

        callback([
          "versionName": versionName,
          "versionCode": versionCode,
          "packageName": packageName,
        ])
      }
    }

    return result
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
