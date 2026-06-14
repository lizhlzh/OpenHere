//
//  Logger.swift
//  OpenHere
//
//  Created by Codex on 2026/6/14.
//

import Foundation

enum Logger {
    static func info(_ message: String) {
        print("[OpenHere][INFO] \(message)")
    }

    static func error(_ message: String) {
        print("[OpenHere][ERROR] \(message)")
    }
}
