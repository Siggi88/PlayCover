//
//  Decryptor.swift
//  PlayCover
//

import Foundation

class BinaryPatcher {
    
    static let shared = BinaryPatcher()
    
    private var extracted : [String] = []
    
    static let possibleHeaders : [Array<UInt8>] = [
        [202, 254, 186, 190],
        [207, 250, 237, 254]
    ]
    
    func extractMachosFrom(_ app: URL) throws {
        extracted = []
        if vm.makeFullscreen {
            extracted.append("/PlayCoverInject")
            extracted.append("/MacHelper")
        }
        if let enumerator = fm.enumerator(at: app, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
            for case let fileURL as URL in enumerator {
                do {
                    let fileAttributes = try fileURL.resourceValues(forKeys:[.isRegularFileKey])
                    if fileAttributes.isRegularFile! {
                        if BinaryPatcher.isMacho(fileUrl: fileURL){
                            extracted.append(fileURL.path.replacingOccurrences(of: app.path, with: ""))
                        }
                    }
                }
            }
        }
    }
    
    func decryptMachos(_ target: URL, installed : URL, name : String, app : URL) throws {
        try fm.delete(at: target)
        sh.appdecrypt(installed, target: target)
        try fm.delete(at: app)
        try fm.moveItem(at: target.appendingPathComponent("Wrapper").appendingPathComponent("\(name).app"), to: app.deletingLastPathComponent().appendingPathComponent("\(name).app"))
        for macho in extracted {
            let trgt = URL(fileURLWithPath: app.deletingLastPathComponent().appendingPathComponent("\(name).app").path.appending(macho))
            let src = URL(fileURLWithPath: installed.path.appending(macho))
            if sh.isMachoEncrypted(exec: trgt){
                sh.machodecrypt(src, target: trgt)
                if sh.isMachoEncrypted(exec: trgt){
                    throw PlayCoverError.cantDecryptIpa
                }
            }
        }
    }
    
    private static func isMacho(fileUrl : URL) -> Bool {
        if !fileUrl.pathExtension.isEmpty && fileUrl.pathExtension != "dylib" {
            return false
        }
        if let bts = fileUrl.bytesFromFile(){
            if bts.count > 4{
                let header = bts[...3]
                if header.count == 4{
                    if(BinaryPatcher.possibleHeaders.contains(Array(header))){
                        return true
                    }
                }
            }
        }
        return false
    }
    
     func patchApp(_ app : URL) throws {
        ulog("Patching app\n")
        for macho in extracted{
            try BinaryPatcher.patchBinary(URL(fileURLWithPath: app.path.appending(macho)))
        }
    }
    
    private static func patchBinary(_ macho : URL) throws {
        ulog("Patching \(macho.lastPathComponent)\n")
        
        if vm.useAlternativePatch {
            try internalWay()
        } else{
            vtoolWay()
        }
        
        sh.codesign(macho)
        
        func vtoolWay(){
            sh.vtoolPatch(macho)
        }
        
        func internalWay() throws {
            convert(macho.path.esc)
            let newUrl = macho.path.appending("_sim")
            try fm.delete(at: macho)
            try fm.moveItem(atPath: newUrl, toPath: macho.path)
        }
        
    }
    
}
