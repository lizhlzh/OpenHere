//
//  WorkspaceTerminalLauncher.swift
//  OpenHere
//
//  Created by Codex on 2026/6/14.
//

import AppKit
import Foundation

struct WorkspaceTerminalLauncher: TerminalLaunching {
    private let bundleIdentifier = "com.apple.Terminal"
    let postLaunchCommand: String?

    func open(at directory: URL) async throws {
        guard directory.isFileURL else {
            throw TerminalLaunchError.invalidDirectory
        }

        if let postLaunchCommand {
            try runAppleScript(at: directory, command: postLaunchCommand)
            return
        }

        guard let applicationURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleIdentifier) else {
            throw TerminalLaunchError.terminalAppNotFound
        }

        let configuration = NSWorkspace.OpenConfiguration()
        configuration.activates = true
        configuration.promptsUserIfNeeded = true

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            NSWorkspace.shared.open(
                [directory],
                withApplicationAt: applicationURL,
                configuration: configuration
            ) { _, error in
                if let error {
                    continuation.resume(
                        throwing: TerminalLaunchError.workspaceOpenFailed(message: error.localizedDescription)
                    )
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }

    private func runAppleScript(at directory: URL, command: String) throws {
        let shellCommand = "cd \(shellQuoted(directory.path)); \(command)"
        let source = """
        tell application "Terminal"
            activate
            do script "\(appleScriptEscaped(shellCommand))"
        end tell
        """

        guard let script = NSAppleScript(source: source) else {
            throw TerminalLaunchError.appleScriptFailed(message: L10n.tr("error.terminal.scriptInitializationFailed"))
        }

        var executionError: NSDictionary?
        script.executeAndReturnError(&executionError)

        if let executionError {
            let message = [
                executionError[NSAppleScript.errorMessage] as? String,
                executionError[NSAppleScript.errorBriefMessage] as? String
            ]
            .compactMap { $0 }
            .joined(separator: " ")

            throw TerminalLaunchError.appleScriptFailed(message: message)
        }
    }

    private func shellQuoted(_ value: String) -> String {
        "'\(value.replacingOccurrences(of: "'", with: "'\"'\"'"))'"
    }

    private func appleScriptEscaped(_ value: String) -> String {
        value
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
    }
}
