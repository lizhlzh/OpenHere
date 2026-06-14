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
        alert.messageText = "OpenHere 执行失败"

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

        alert.addButton(withTitle: "好")

        NSApp.activate(ignoringOtherApps: true)
        alert.runModal()
    }
}
