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
            "Terminal.app"
        case .iTerm2:
            "iTerm2"
        case .custom:
            "自定义终端"
        }
    }
}
