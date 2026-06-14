//
//  FinderAutomationPermission.swift
//  OpenHere
//
//  Created by Codex on 2026/6/14.
//

import CoreServices
import Foundation

enum FinderAutomationPermissionError: Error {
    case finderTargetUnavailable
    case permissionDenied(status: OSStatus)
}

extension FinderAutomationPermissionError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .finderTargetUnavailable:
            L10n.tr("error.finderAutomation.targetUnavailable")
        case .permissionDenied:
            L10n.tr("error.finderAutomation.permissionDenied")
        }
    }

    var failureReason: String? {
        switch self {
        case .finderTargetUnavailable:
            L10n.tr("error.finderAutomation.targetUnavailable.reason")
        case .permissionDenied(let status):
            L10n.tr("error.finderAutomation.permissionDenied.reason", status)
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .finderTargetUnavailable:
            L10n.tr("error.finderAutomation.targetUnavailable.recovery")
        case .permissionDenied:
            L10n.tr("error.finderAutomation.permissionDenied.recovery")
        }
    }
}

struct FinderAutomationPermission {
    private let finderBundleIdentifier = "com.apple.finder"

    func requestIfNeeded() throws {
        let targetDescriptor = NSAppleEventDescriptor(bundleIdentifier: finderBundleIdentifier)

        let status = AEDeterminePermissionToAutomateTarget(
            targetDescriptor.aeDesc,
            AEEventClass(kCoreEventClass),
            AEEventID(kAEGetData),
            true
        )

        guard status == noErr else {
            throw FinderAutomationPermissionError.permissionDenied(status: status)
        }
    }
}
