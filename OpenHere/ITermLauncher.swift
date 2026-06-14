//
//  ITermLauncher.swift
//  OpenHere
//
//  Created by Codex on 2026/6/14.
//

import AppKit
import Foundation

struct ITermLauncher: TerminalLaunching {
    private let bundleIdentifier = "com.googlecode.iterm2"

    func open(at directory: URL) async throws {
        guard directory.isFileURL else {
            throw TerminalLaunchError.invalidDirectory
        }

        guard NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleIdentifier) != nil else {
            throw TerminalLaunchError.iTermNotFound
        }

        let command = "cd \(shellQuoted(directory.path))"
        let source = """
        tell application "iTerm2"
            activate
            set newWindow to (create window with default profile)
            tell current session of newWindow
                write text "\(appleScriptEscaped(command))"
            end tell
        end tell
        """

        try runAppleScript(source)
    }

    private func runAppleScript(_ source: String) throws {
        guard let script = NSAppleScript(source: source) else {
            throw TerminalLaunchError.appleScriptFailed(message: "无法初始化 iTerm2 脚本。")
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
