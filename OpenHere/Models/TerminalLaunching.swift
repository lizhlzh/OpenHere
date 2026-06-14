//
//  TerminalLaunching.swift
//  OpenHere
//
//  Created by Codex on 2026/6/14.
//

import Foundation

protocol TerminalLaunching {
    func open(at directory: URL) async throws
}

enum TerminalLaunchError: Error {
    case terminalAppNotFound
    case iTermNotFound
    case missingCustomExecutablePath
    case customExecutableNotFound
    case customExecutableNotExecutable
    case invalidDirectory
    case appleScriptFailed(message: String)
    case workspaceOpenFailed(message: String)
    case processLaunchFailed(message: String)
}

extension TerminalLaunchError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .terminalAppNotFound:
            L10n.tr("error.terminal.appNotFound")
        case .iTermNotFound:
            L10n.tr("error.terminal.iTermNotFound")
        case .missingCustomExecutablePath:
            L10n.tr("error.terminal.missingCustomExecutablePath")
        case .customExecutableNotFound:
            L10n.tr("error.terminal.customExecutableNotFound")
        case .customExecutableNotExecutable:
            L10n.tr("error.terminal.customExecutableNotExecutable")
        case .invalidDirectory:
            L10n.tr("error.terminal.invalidDirectory")
        case .appleScriptFailed(let message) where message.isEmpty:
            L10n.tr("error.terminal.launchFailedGeneric")
        case .appleScriptFailed(let message):
            L10n.tr("error.terminal.launchFailed", message)
        case .workspaceOpenFailed(let message):
            L10n.tr("error.terminal.launchFailed", message)
        case .processLaunchFailed(let message):
            L10n.tr("error.terminal.launchFailed", message)
        }
    }
}
