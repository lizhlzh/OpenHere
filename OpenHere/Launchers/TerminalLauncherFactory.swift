//
//  TerminalLauncherFactory.swift
//  OpenHere
//
//  Created by Codex on 2026/6/14.
//

import Foundation

struct TerminalLauncherFactory {
    func makeLauncher(using configuration: TerminalConfiguration) -> TerminalLaunching {
        let postLaunchCommand = normalizedPostLaunchCommand(from: configuration)

        switch configuration.profile {
        case .terminalApp:
            return WorkspaceTerminalLauncher(postLaunchCommand: postLaunchCommand)
        case .iTerm2:
            return ITermLauncher(postLaunchCommand: postLaunchCommand)
        case .custom:
            let executableURL: URL?

            if configuration.customExecutablePath.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                executableURL = nil
            } else {
                executableURL = URL(fileURLWithPath: configuration.customExecutablePath)
            }

            return ProcessTerminalLauncher(
                executableURL: executableURL,
                argumentsTemplate: configuration.customArgumentsTemplate,
                postLaunchCommand: postLaunchCommand
            )
        }
    }

    private func normalizedPostLaunchCommand(from configuration: TerminalConfiguration) -> String? {
        guard configuration.shouldRunPostLaunchCommand else {
            return nil
        }

        let command = configuration.postLaunchCommand.trimmingCharacters(in: .whitespacesAndNewlines)
        return command.isEmpty ? nil : command
    }
}
