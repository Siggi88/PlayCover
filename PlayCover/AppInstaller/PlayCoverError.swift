//
//  PlayCoverError.swift
//  PlayCover
//

import Foundation

enum PlayCoverError: Error {
    case cantCreateTemp
    case ipaCorrupted
    case cantDecryptIpa
    case infoPlistNotFound
    case sipDisabled
    case appInstalledNotProperly
    case improperSetup
}

extension PlayCoverError: LocalizedError {
    public var errorDescription: String? {
        
        switch self {
        case .cantDecryptIpa:
            return NSLocalizedString("This .IPA can't be decrypted on this Mac. Download .ipa from AppDb.to or our Discord. You can also try to use 'Alterntaive decrypt' checkbox", comment: "")
        case .infoPlistNotFound:
            return NSLocalizedString("This .IPA is courrupted. It doesn't contains Info.plist.", comment: "")
        case .sipDisabled:
            return NSLocalizedString("It it impossible to decrypt .IPA with SIP disabled. Please, enable it.", comment: "")
        case .appInstalledNotProperly:
            return NSLocalizedString("Please reinstall PlayCoverApp", comment: "")
        case .cantCreateTemp:
            return NSLocalizedString("Make sure you don't disallowed PlayCover to access files in Settings - Secuirity & Privacy", comment: "")
        case .ipaCorrupted:
            return NSLocalizedString("This .IPA is courrupted.Try to use another .ipa", comment: "")
        case .improperSetup:
            return NSLocalizedString("You not performed all instructions! Please, perform all instructions in 'Troubleshoot' or watch video in pinned messages.", comment: "")
        }
    }
}

