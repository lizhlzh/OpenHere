//
//  TerminalProfile.swift
//  OpenHere
//
//  Created by Codex on 2026/6/14.
//

import Foundation

enum TerminalProfile: String, CaseIterable, Identifiable, Sendable {
    case terminalApp
    case iTerm2
    case custom

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .terminalApp:
            L10n.tr("terminalProfile.terminalApp")
        case .iTerm2:
            L10n.tr("terminalProfile.iTerm2")
        case .custom:
            L10n.tr("terminalProfile.custom")
        }
    }
}
