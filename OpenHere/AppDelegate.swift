//
//  AppDelegate.swift
//  OpenHere
//
//  Created by Codex on 2026/6/14.
//

import AppKit
import Foundation

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let settings = AppSettings.shared
    private let finderPathResolver = FinderPathResolver()
    private let launcherFactory = TerminalLauncherFactory()
    private let errorPresenter = ErrorPresenter()

    private lazy var settingsWindowController = SettingsWindowController(
        settings: settings,
        finderPathResolver: finderPathResolver,
        launcherFactory: launcherFactory,
        errorPresenter: errorPresenter
    )

    func applicationDidFinishLaunching(_ notification: Notification) {
        Logger.info("Application launched")

        if shouldOpenSettings {
            Logger.info("Opening settings window")
            settingsWindowController.show()
            return
        }

        Logger.info("Executing quick action")
        Task {
            await performQuickAction()
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }

    @objc func showPreferencesWindow(_ sender: Any?) {
        settingsWindowController.show()
    }

    private var shouldOpenSettings: Bool {
        shouldForceSettingsWindow || settings.hasCompletedSetup == false
    }

    private var shouldForceSettingsWindow: Bool {
        let flags = CGEventSource.flagsState(.combinedSessionState)
        return flags.contains(.maskAlternate)
    }

    private func performQuickAction() async {
        do {
            let directory = try finderPathResolver.resolveCurrentDirectory()
            let configuration = settings.loadConfiguration()
            let launcher = launcherFactory.makeLauncher(using: configuration)
            try await launcher.open(at: directory)
            Logger.info("Opened terminal at \(directory.path)")
            NSApp.terminate(nil)
        } catch {
            Logger.error("Quick action failed: \(error.localizedDescription)")
            errorPresenter.present(error)
        }
    }
}
