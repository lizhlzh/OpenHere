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
            L10n.tr("error.finderPath.permissionDenied")
        case .scriptCompilationFailed:
            L10n.tr("error.finderPath.scriptCompilationFailed")
        case .scriptExecutionFailed:
            L10n.tr("error.finderPath.scriptExecutionFailed")
        case .invalidPath:
            L10n.tr("error.finderPath.invalidPath")
        }
    }

    var failureReason: String? {
        switch self {
        case .permissionDenied(let underlying):
            underlying.localizedDescription
        case .scriptCompilationFailed:
            L10n.tr("error.finderPath.scriptCompilationFailed.reason")
        case .scriptExecutionFailed(let message):
            message
        case .invalidPath:
            L10n.tr("error.finderPath.invalidPath.reason")
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .permissionDenied:
            L10n.tr("error.finderPath.permissionDenied.recovery")
        case .scriptCompilationFailed:
            nil
        case .scriptExecutionFailed:
            L10n.tr("error.finderPath.scriptExecutionFailed.recovery")
        case .invalidPath:
            L10n.tr("error.finderPath.invalidPath.recovery")
        }
    }
}

struct FinderPathResolver {
    private let permission = FinderAutomationPermission()

    private let scriptSource = """
    tell application "Finder"
        try
            if (count of Finder windows) > 0 then
                try
                    set theTarget to target of front Finder window
                    return POSIX path of (theTarget as alias)
                on error
                end try
            end if

            try
                set theSelection to selection
                if theSelection is not {} then
                    set theItem to item 1 of theSelection
                    if class of theItem is folder then
                        return POSIX path of (theItem as alias)
                    else
                        set parentFolder to container of theItem
                        return POSIX path of (parentFolder as alias)
                    end if
                end if
            on error
            end try

            return POSIX path of (path to desktop folder)
        on error
            return POSIX path of (path to desktop folder)
        end try
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
