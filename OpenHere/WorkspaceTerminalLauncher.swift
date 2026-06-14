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

    func open(at directory: URL) async throws {
        guard directory.isFileURL else {
            throw TerminalLaunchError.invalidDirectory
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
}
