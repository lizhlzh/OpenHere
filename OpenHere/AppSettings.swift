//
//  AppSettings.swift
//  OpenHere
//
//  Created by Codex on 2026/6/14.
//

import Foundation

struct TerminalConfiguration: Equatable, Sendable {
    var profile: TerminalProfile
    var customExecutablePath: String
    var customArgumentsTemplate: [String]

    static let `default` = TerminalConfiguration(
        profile: .terminalApp,
        customExecutablePath: "",
        customArgumentsTemplate: []
    )

    var normalizedArgumentsTemplate: [String] {
        customArgumentsTemplate
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty == false }
    }

    func validate() throws {
        guard profile == .custom else {
            return
        }

        let path = customExecutablePath.trimmingCharacters(in: .whitespacesAndNewlines)
        guard path.isEmpty == false else {
            throw TerminalLaunchError.missingCustomExecutablePath
        }

        var isDirectory = ObjCBool(false)
        guard FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory) else {
            throw TerminalLaunchError.customExecutableNotFound
        }

        if isDirectory.boolValue {
            let bundleURL = URL(fileURLWithPath: path)
            guard Bundle(url: bundleURL)?.executableURL != nil else {
                throw TerminalLaunchError.customExecutableNotExecutable
            }
        } else if FileManager.default.isExecutableFile(atPath: path) == false {
            throw TerminalLaunchError.customExecutableNotExecutable
        }
    }
}

@MainActor
final class AppSettings {
    static let shared = AppSettings()

    private enum Keys {
        static let hasCompletedSetup = "hasCompletedSetup"
        static let terminalProfile = "terminalProfile"
        static let customExecutablePath = "customExecutablePath"
        static let customArgumentsTemplate = "customArgumentsTemplate"
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var hasCompletedSetup: Bool {
        defaults.bool(forKey: Keys.hasCompletedSetup)
    }

    func loadConfiguration() -> TerminalConfiguration {
        let profile = TerminalProfile(
            rawValue: defaults.string(forKey: Keys.terminalProfile) ?? ""
        ) ?? .terminalApp

        return TerminalConfiguration(
            profile: profile,
            customExecutablePath: defaults.string(forKey: Keys.customExecutablePath) ?? "",
            customArgumentsTemplate: defaults.stringArray(forKey: Keys.customArgumentsTemplate) ?? []
        )
    }

    func save(configuration: TerminalConfiguration, hasCompletedSetup: Bool? = nil) {
        defaults.set(configuration.profile.rawValue, forKey: Keys.terminalProfile)
        defaults.set(configuration.customExecutablePath, forKey: Keys.customExecutablePath)
        defaults.set(configuration.normalizedArgumentsTemplate, forKey: Keys.customArgumentsTemplate)

        if let hasCompletedSetup {
            defaults.set(hasCompletedSetup, forKey: Keys.hasCompletedSetup)
        }
    }
}
