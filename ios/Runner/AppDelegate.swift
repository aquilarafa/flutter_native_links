import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
  private var methodChannel: FlutterMethodChannel?
  private var eventChannel: FlutterEventChannel?
  private let linkStreamHandler = LinkStreamHandler()

  override func application(
    _ application: UIApplication,
    
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?

  ) -> Bool {
    let controller = window.rootViewController as! FlutterViewController
        methodChannel = FlutterMethodChannel(name: "link_channel", binaryMessenger: controller.binaryMessenger)
        eventChannel = FlutterEventChannel(name: "link_events", binaryMessenger: controller.binaryMessenger)

    
    methodChannel?.setMethodCallHandler({ (call: FlutterMethodCall, result: FlutterResult) in
          guard call.method == "initialLink" else {
            result(FlutterMethodNotImplemented)
            return
          }
        })
    
    GeneratedPluginRegistrant.register(with: self)
    eventChannel?.setStreamHandler(linkStreamHandler)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    
    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        eventChannel?.setStreamHandler(linkStreamHandler)
        let nativeLink = NativeLink(path: url.path, isFile: url.isFileURL)
        return linkStreamHandler.handleLink(nativeLink);
      }
    
    class LinkStreamHandler:NSObject, FlutterStreamHandler {
      
      var eventSink: FlutterEventSink?
      
      var queuedLinks = [[String:Any]]()
      
      func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        queuedLinks.forEach({ events($0) })
        queuedLinks.removeAll()
        return nil
      }
      
      func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
      }
      
      func handleLink(_ link: NativeLink) -> Bool {
        guard let eventSink = eventSink else {
            queuedLinks.append(link.toMap())
          return false
        }
        eventSink(link.toMap())
        return true
      }
    }
    
    
    struct NativeLink{
        let path: String
        let isFile: Bool
        
         func toMap() -> [String:Any]{
            ["path": self.path,
             "isFile": self.isFile,
            ]
        }
        
    }
    
    
    
    
    
}
