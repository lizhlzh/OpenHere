//
//  FinderPathResolver.swift
//  OpenHere
//
//  Created by Codex on 2026/6/14.
//

import AppKit
import Foundation

enum FinderPathError: Error {
    case permissionDenied(underlying: Error)
    case scriptCompilationFailed
    case scriptExecutionFailed(message: String)
    case invalidPath
}

extension FinderPathError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            "无法读取 Finder 当前目录。请允许 OpenHere 控制 Finder。"
        case .scriptCompilationFailed:
            "无法初始化 Finder 路径脚本。"
        case .scriptExecutionFailed:
            "无法读取 Finder 当前目录。请在系统设置中允许 OpenHere 控制 Finder。"
        case .invalidPath:
            "Finder 返回的目录无效。"
        }
    }

    var failureReason: String? {
        switch self {
        case .permissionDenied(let underlying):
            underlying.localizedDescription
        case .scriptCompilationFailed:
            "内置的 Finder AppleScript 无法编译。"
        case .scriptExecutionFailed(let message):
            message
        case .invalidPath:
            "Finder 返回的路径不存在，或不是文件夹。"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .permissionDenied:
            "如果系统尚未弹出授权框，请确认已在 Hardened Runtime 中启用 Apple Events，然后重新运行 OpenHere。"
        case .scriptCompilationFailed:
            nil
        case .scriptExecutionFailed:
            "请前往 系统设置 > 隐私与安全性 > 自动化，允许 OpenHere 控制 Finder，然后重试。"
        case .invalidPath:
            "请切换到一个有效的 Finder 目录后重试。"
        }
    }
}

struct FinderPathResolver {
    private let permission = FinderAutomationPermission()

    private let scriptSource = """
    tell application "Finder"
        if (count of Finder windows) > 0 then
            set theTarget to target of front Finder window
            return POSIX path of (theTarget as alias)
        else
            set theSelection to selection
            if theSelection is not {} then
                set theItem to item 1 of theSelection
                if class of theItem is folder then
                    return POSIX path of (theItem as alias)
                else
                    set parentFolder to container of theItem
                    return POSIX path of (parentFolder as alias)
                end if
            else
                return POSIX path of (path to desktop folder)
            end if
        end if
    end tell
    """

    func resolveCurrentDirectory() throws -> URL {
        do {
            try permission.requestIfNeeded()
        } catch {
            throw FinderPathError.permissionDenied(underlying: error)
        }

        guard let script = NSAppleScript(source: scriptSource) else {
            throw FinderPathError.scriptCompilationFailed
        }

        var executionError: NSDictionary?
        let descriptor = script.executeAndReturnError(&executionError)

        if let executionError {
            let message = [
                executionError[NSAppleScript.errorMessage] as? String,
                executionError[NSAppleScript.errorBriefMessage] as? String
            ]
            .compactMap { $0 }
            .joined(separator: " ")

            throw FinderPathError.scriptExecutionFailed(message: message)
        }

        guard
            let path = descriptor.stringValue?.trimmingCharacters(in: .whitespacesAndNewlines),
            path.isEmpty == false
        else {
            throw FinderPathError.invalidPath
        }

        var isDirectory = ObjCBool(false)
        guard FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory), isDirectory.boolValue else {
            throw FinderPathError.invalidPath
        }

        return URL(fileURLWithPath: path, isDirectory: true)
    }
}
