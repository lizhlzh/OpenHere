//
//  ErrorPresenter.swift
//  OpenHere
//
//  Created by Codex on 2026/6/14.
//

import AppKit
import Foundation

@MainActor
final class ErrorPresenter {
    func present(_ error: Error) {
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = L10n.tr("error.alert.title")

        if let localizedError = error as? LocalizedError {
            alert.informativeText = [
                localizedError.errorDescription,
                localizedError.failureReason,
                localizedError.recoverySuggestion
            ]
            .compactMap { $0 }
            .joined(separator: "\n\n")
        } else {
            alert.informativeText = error.localizedDescription
        }

        alert.addButton(withTitle: L10n.tr("common.ok"))

        NSApp.activate(ignoringOtherApps: true)
        alert.runModal()
    }
}
