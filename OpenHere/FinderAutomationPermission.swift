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
            "无法定位 Finder，无法请求自动化权限。"
        case .permissionDenied:
            "无法读取 Finder 当前目录。请允许 OpenHere 控制 Finder。"
        }
    }

    var failureReason: String? {
        switch self {
        case .finderTargetUnavailable:
            "系统没有返回有效的 Finder Apple Events 目标。"
        case .permissionDenied(let status):
            "Finder 自动化权限请求失败，系统状态码：\(status)。"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .finderTargetUnavailable:
            "请确认 Finder 正常可用后重试。"
        case .permissionDenied:
            "请前往 系统设置 > 隐私与安全性 > 自动化，允许 OpenHere 控制 Finder，然后重试。若列表中尚未出现 OpenHere，请重新启动应用再试一次。"
        }
    }
}

struct FinderAutomationPermission {
    private let finderBundleIdentifier = "com.apple.finder"

    func requestIfNeeded() throws {
        let targetDescriptor = NSAppleEventDescriptor(bundleIdentifier: finderBundleIdentifier)

        guard let target = targetDescriptor.aeDesc else {
            throw FinderAutomationPermissionError.finderTargetUnavailable
        }

        let status = AEDeterminePermissionToAutomateTarget(
            target,
            AEEventClass(kCoreEventClass),
            AEEventID(kAEGetData),
            true
        )

        guard status == noErr else {
            throw FinderAutomationPermissionError.permissionDenied(status: status)
        }
    }
}
