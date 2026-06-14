//
//  TerminalLaunching.swift
//  OpenHere
//
//  Created by Codex on 2026/6/14.
//

import Foundation

protocol TerminalLaunching {
    func open(at directory: URL) async throws
}

enum TerminalLaunchError: Error {
    case terminalAppNotFound
    case iTermNotFound
    case missingCustomExecutablePath
    case customExecutableNotFound
    case customExecutableNotExecutable
    case invalidDirectory
    case appleScriptFailed(message: String)
    case workspaceOpenFailed(message: String)
    case processLaunchFailed(message: String)
}

extension TerminalLaunchError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .terminalAppNotFound:
            "未找到 Terminal.app，请确认系统终端可用。"
        case .iTermNotFound:
            "未找到 iTerm2，请确认已经安装，或在设置中选择 Terminal.app。"
        case .missingCustomExecutablePath:
            "请先填写自定义终端的可执行文件路径。"
        case .customExecutableNotFound:
            "自定义终端路径不存在。"
        case .customExecutableNotExecutable:
            "自定义终端文件不可执行，请确认选择的是实际可执行文件。"
        case .invalidDirectory:
            "Finder 当前目录无效，无法启动终端。"
        case .appleScriptFailed(let message):
            "启动终端失败：\(message)"
        case .workspaceOpenFailed(let message):
            "启动终端失败：\(message)"
        case .processLaunchFailed(let message):
            "启动终端失败：\(message)"
        }
    }
}
