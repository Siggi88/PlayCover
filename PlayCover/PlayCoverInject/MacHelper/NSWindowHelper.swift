//
//  NSWindowHelper.swift
//  MacHelper
//

import Foundation
import AppKit

@objc public class NSWindowHelper : NSObject {
    
    @objc static public func initUI(){
        let window = NSApplication.shared.windows.first
        
        let centre = NotificationCenter.default
        let main = OperationQueue.main
        
        centre.addObserver(forName: NSWindow.willEnterFullScreenNotification, object: nil, queue: main) { (note) in
            NSApplication.shared.presentationOptions = [NSApplication.PresentationOptions.hideMenuBar, NSApplication.PresentationOptions.hideDock]
            NSCursor.hide()
        }
        
        centre.addObserver(forName: NSWindow.willExitFullScreenNotification, object: nil, queue: main) { (note) in
           NSApplication.shared.presentationOptions = []
            NSCursor.unhide()
        }
        
    }
}
