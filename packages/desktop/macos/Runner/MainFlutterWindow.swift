import Cocoa
import Darwin
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    signal(SIGPIPE, SIG_IGN)

    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
