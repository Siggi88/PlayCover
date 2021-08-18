import SwiftUI
import Cocoa

struct AppInstallView: View {
    
    @EnvironmentObject var flow : UserIntentFlow
    @EnvironmentObject var installData: InstallAppViewModel
    @EnvironmentObject var logger: Logger
    @EnvironmentObject var error: ErrorViewModel
    @EnvironmentObject var pwd: PasswordViewModel
    
    @State var isLoading : Bool = false
    @State var showWrongfileTypeAlert : Bool = false
    
    private func insertApp(url : URL){
        isLoading = true
        logger.logs = ""
        
        pwd.promptForReply("Please, input your admin password", "App needs it for xattr command", completion: {(strCommitMsg:String, bResponse:Bool) in
            if bResponse {
                pwd.password = strCommitMsg
                AppInstaller.shared.installApp(url : url, returnCompletion: { (app) in
                    DispatchQueue.main.async {
                        isLoading = false
                        if let pathToApp = app {
                            pathToApp.showInFinder()
                        }
                    }
                })
            } else{
                isLoading = false
            }
        })

    }
    
    private func selectFile() {
        NSOpenPanel.selectIPA { (result) in
            if case let .success(url) = result {
                insertApp(url: url)
            }
        }
    }
    
    var body: some View {
            VStack{
                Text("PlayCover 0.6.0b5")
                    .fontWeight(.bold)
                    .font(.system(.largeTitle, design: .rounded)).padding().frame(minHeight: 50)
                VStack {
                    if !isLoading {
                        ZStack {
                            Text("Drag .ipa file here")
                                .fontWeight(.bold)
                                .font(.system(.title, design: .rounded)).padding().background( Rectangle().frame(minWidth: 600.0, minHeight: 150.0).foregroundColor(Color(NSColor.gridColor))
                                                .cornerRadius(16)
                                                .shadow(radius: 1).padding()).padding()
                        }.frame(minWidth: 600).padding().onDrop(of: ["public.url","public.file-url"], isTargeted: nil) { (items) -> Bool in
                      
                            if let item = items.first {
                                if let identifier = item.registeredTypeIdentifiers.first {
                                    if identifier == "public.url" || identifier == "public.file-url" {
                                        item.loadItem(forTypeIdentifier: identifier, options: nil) { (urlData, error) in
                                            DispatchQueue.main.async {
                                                if let urlData = urlData as? Data {
                                                    let urll = NSURL(absoluteURLWithDataRepresentation: urlData, relativeTo: nil) as URL
                                                    if urll.pathExtension == "ipa"{
                                                        insertApp(url: urll)
                                                    } else{
                                                        showWrongfileTypeAlert = true
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                return true
                            } else {
                                return false
                            }
                        }.padding()
                        Button("Add .ipa"){
                            selectFile()
                        }.alert(isPresented: $showWrongfileTypeAlert) {
                            Alert(title: Text("Wrong file type"), message: Text("You should use .ipa file"), dismissButton: .default(Text("OK")))
                        }
                        InstallSettings().environmentObject(installData)
                        Text("Advanced settings")
                            .fontWeight(.bold)
                            .font(.system(.callout, design: .rounded))
                        AdvancedInstallSettings().environmentObject(installData)
                        Button("Download app"){
                            flow.showAppsDownloadView = true
                        }.popover(isPresented: $flow.showAppsDownloadView) {
                            AppsDownloadView().environmentObject(AppsViewModel.shared)
                        }
                        Button("Troubleshoot"){
                            flow.showTroubleshootView = true
                        }.popover(isPresented: $flow.showTroubleshootView) {
                            TroubleshootView()
                        }
                    } else{
                        ProgressView("Installing...")
                    }
                   
                }
                LogView()
                    .environmentObject(InstallAppViewModel.shared)
                    .environmentObject(Logger.shared)
            }.padding().frame(minWidth: 600).alert(isPresented: error.showError) {
                Alert(title: Text("Error!"), message: Text(error.error), dismissButton: .default(Text("OK")){
                    error.error = ""
                })
            }
    }
}

struct LogView : View {
    @EnvironmentObject var userData: InstallAppViewModel
    @EnvironmentObject var logger: Logger
    var body: some View {
        VStack{
            if !logger.logs.isEmpty {
                Button("Copy log"){
                    logger.logs.copyToClipBoard()
                }
            }
            ScrollView {
                VStack(alignment: .leading) {
                    Text(logger.logs).padding().lineLimit(nil).frame(alignment: .leading)
                }
            }.frame(maxHeight: 100).padding()
        }.padding()
    }
}

struct InstallSettings : View {
    @EnvironmentObject var installData: InstallAppViewModel
    
    @State private var toggle: Bool = ProcessInfo.processInfo.isM1()
    
    var body: some View {
            ZStack(alignment: .leading){
                Rectangle().frame(width: 320.0, height: 50.0).foregroundColor(Color(NSColor.windowBackgroundColor))
                                .cornerRadius(16).padding()
                VStack(alignment: .leading){
                    Toggle("Fullscreen & Keymapping", isOn: $installData.makeFullscreen).frame(alignment: .leading)
                    Toggle("Fix login in games", isOn: $installData.fixLogin).frame(alignment: .leading)
                }.padding(.init(top: 0, leading: 20, bottom: 0, trailing: 0))
            }
    }
}

struct AdvancedInstallSettings : View {
    @EnvironmentObject var installData: InstallAppViewModel
    
    @State private var toggle: Bool = true
    
    var body: some View {
            ZStack(alignment: .leading){
                Rectangle().frame(width: 320.0, height: 100.0).foregroundColor(Color(NSColor.windowBackgroundColor))
                                .cornerRadius(16).padding()
                VStack(alignment: .leading){
                    Toggle("Alternative convert method", isOn: $installData.useAlternativePatch).frame(alignment: .leading)
                    Toggle("Alternative decrypt method", isOn: $installData.useAlternativeDecrypt).frame(alignment: .leading)
                    Toggle("Clear app cache", isOn: $installData.clearAppCaches).frame(alignment: .leading)
                    Toggle("Export for iOS, Mac (Sideloadly, AltStore)", isOn: $installData.exportForSideloadly).frame(alignment: .leading)
                }.padding(.init(top: 0, leading: 20, bottom: 0, trailing: 0))
            }
    }
}


