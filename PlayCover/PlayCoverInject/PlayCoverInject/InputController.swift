import Foundation
import GameController
import UIKit

extension UIApplication{
    @objc open var applicationState: UIApplication.State { return UIApplication.State.active }
    @objc open var backgroundTimeRemaining: TimeInterval { return TimeInterval(100000000) }
}

@objc extension CALayer {
    @objc open var contentsScale: CGFloat {CGFloat(2.0)}
}

extension UIWindow {
    var nsWindow: NSObject? {
        var nsWindow = Dynamic.NSApplication.sharedApplication.delegate.hostWindowForUIWindow(self)
        if #available(macOS 11, *) {
            nsWindow = nsWindow.attachedWindow
        }
        return nsWindow.asObject
    }
}

@objc public class InputController: NSObject {

    static var screenWidth : CGFloat = Values.screenWidth
    static var screenHeight : CGFloat = Values.screenHeight
      
        @objc static public func initUI(){
            if #available(macOS 11, *) {
//                if let vals = root()?.getScreenValues(){
//                    screenWidth = CGFloat(vals[2]) * 1.3
//                    screenHeight = CGFloat(vals[3]) * 1.3
//                    window()?.frame = CGRect(x: CGFloat(vals[0]), y: CGFloat(vals[1]), width: screenWidth + CGFloat(vals[0]), height: screenHeight + CGFloat(vals[0]))
//                } else{
//                    window()?.frame = CGRect(x: 0, y: 0, width: screenWidth + CGFloat(0), height: screenHeight + CGFloat(0))
//                }
                
            }
            root()?.setup()
    }
    
    static public func updateControls(){
        KeyboardController.shared.setup()
        MouseController.shared.setupMouse()
    }
    
    static public func root() -> UIViewController?{
        return UIApplication.shared.windows.first?.rootViewController
    }
    
    static public func window() -> UIWindow?{
        return UIApplication.shared.keyWindow
    }
    
    static public func showAlert(){
        var msg = ""
        msg.append(NSHomeDirectory());
        msg.append("\n")
        
        let alert = UIAlertController(title: "Alert", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style{
                case .default:
                print("default")
                
                case .cancel:
                print("cancel")
                
                case .destructive:
                print("destructive")
                
            }
        }))
        root()?.present(alert, animated: true, completion: nil)
    }
    
}

extension UIViewController {
    
    func showToast(message : String, seconds: Double){
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alert.view.backgroundColor = .black
            alert.view.alpha = 0.5
            alert.view.layer.cornerRadius = 15
            self.present(alert, animated: true)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
                alert.dismiss(animated: true)
            }
        }
    
    open override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        OverlayController.shared.handlePress(presses: presses)
    }
    
    open override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        
    }
    
    func setup() {
       
        let centre = NotificationCenter.default
        let main = OperationQueue.main
        
        centre.addObserver(forName: NSNotification.Name.GCKeyboardDidConnect, object: nil, queue: main) { (note) in
            KeyboardController.shared.setup()
        }
        
        centre.addObserver(forName: NSNotification.Name.GCMouseDidConnect, object: nil, queue: main) { (note) in
            MouseController.shared.setupMouse()
        }
        
        centre.addObserver(forName: NSNotification.Name.GCControllerDidConnect, object: nil, queue: main) { (note) in
            self.showGameControllerAlert(GCController.current?.vendorName ?? "XBox One S")
        }
        
        InputController.updateControls()
        
    }
    
}



