//
//  PlayCoverApp.swift
//  PlayCover
//

import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationWillTerminate(_ aNotification: Notification) {
        fm.clearCache()
    }
    
}

@main
struct PlayCoverApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            if UserIntentFlow.shared.canUseApp{
                AppInstallView()
                    .environmentObject(InstallAppViewModel.shared)
                    .environmentObject(UserIntentFlow.shared)
                    .environmentObject(ErrorViewModel.shared)
                    .environmentObject(PasswordViewModel.shared)
                    .environmentObject(Logger.shared).accentColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
            } else{
                Text("PlayCover currently doesn't support Intel macs. Please, wait new version.")
            }
        }.windowStyle(HiddenTitleBarWindowStyle())
    }
    
}
