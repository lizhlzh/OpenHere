//
//  ProcessTerminalLauncher.swift
//  OpenHere
//
//  Created by Codex on 2026/6/14.
//

import Foundation

struct ProcessTerminalLauncher: TerminalLaunching {
    let executableURL: URL?
    let argumentsTemplate: [String]
    let postLaunchCommand: String?

    func open(at directory: URL) async throws {
        guard directory.isFileURL else {
            throw TerminalLaunchError.invalidDirectory
        }

        guard let executableURL else {
            throw TerminalLaunchError.missingCustomExecutablePath
        }

        let resolvedExecutableURL = resolveExecutableURL(from: executableURL)
        let executablePath = resolvedExecutableURL.path
        guard FileManager.default.fileExists(atPath: executablePath) else {
            throw TerminalLaunchError.customExecutableNotFound
        }

        guard FileManager.default.isExecutableFile(atPath: executablePath) else {
            throw TerminalLaunchError.customExecutableNotExecutable
        }

        let process = Process()
        process.executableURL = resolvedExecutableURL
        process.currentDirectoryURL = directory
        process.arguments = argumentsTemplate.map {
            $0
                .replacingOccurrences(of: "{path}", with: directory.path)
                .replacingOccurrences(of: "{command}", with: postLaunchCommand ?? "")
        }

        do {
            try process.run()
        } catch {
            throw TerminalLaunchError.processLaunchFailed(message: error.localizedDescription)
        }
    }

    private func resolveExecutableURL(from url: URL) -> URL {
        var isDirectory = ObjCBool(false)
        let exists = FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory)

        if exists, isDirectory.boolValue, let bundleExecutableURL = Bundle(url: url)?.executableURL {
            return bundleExecutableURL
        }

        return url
    }
}
