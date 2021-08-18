//
//  UserIntentFlow.swift
//  PlayCover
//

import Foundation

let uif = UserIntentFlow.shared

class UserIntentFlow: ObservableObject {
    
    static let shared = UserIntentFlow()
    
    @Published var showAppsDownloadView : Bool = false
    @Published var showTroubleshootView : Bool = false
    @Published var canUseApp : Bool = ProcessInfo.processInfo.isM1()
    
    required init() {}

}
