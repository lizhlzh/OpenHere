//
//  TerminalLauncherFactory.swift
//  OpenHere
//
//  Created by Codex on 2026/6/14.
//

import Foundation

struct TerminalLauncherFactory {
    func makeLauncher(using configuration: TerminalConfiguration) -> TerminalLaunching {
        switch configuration.profile {
        case .terminalApp:
            return WorkspaceTerminalLauncher()
        case .iTerm2:
            return ITermLauncher()
        case .custom:
            let executableURL: URL?

            if configuration.customExecutablePath.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                executableURL = nil
            } else {
                executableURL = URL(fileURLWithPath: configuration.customExecutablePath)
            }

            return ProcessTerminalLauncher(
                executableURL: executableURL,
                argumentsTemplate: configuration.customArgumentsTemplate
            )
        }
    }
}
