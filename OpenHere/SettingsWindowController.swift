//
//  SettingsWindowController.swift
//  OpenHere
//
//  Created by Codex on 2026/6/14.
//

import AppKit
import SwiftUI

@MainActor
final class SettingsWindowController: NSObject, NSWindowDelegate {
    private let settings: AppSettings
    private let finderPathResolver: FinderPathResolver
    private let launcherFactory: TerminalLauncherFactory
    private let errorPresenter: ErrorPresenter

    private var windowController: NSWindowController?

    init(
        settings: AppSettings,
        finderPathResolver: FinderPathResolver,
        launcherFactory: TerminalLauncherFactory,
        errorPresenter: ErrorPresenter
    ) {
        self.settings = settings
        self.finderPathResolver = finderPathResolver
        self.launcherFactory = launcherFactory
        self.errorPresenter = errorPresenter
    }

    func show(onComplete: (() -> Void)? = nil) {
        if let window = windowController?.window {
            NSApp.activate(ignoringOtherApps: true)
            window.makeKeyAndOrderFront(nil)
            return
        }

        let view = SettingsView(
            configuration: settings.loadConfiguration(),
            onComplete: { [weak self] configuration in
                guard let self else { return }
                do {
                    try configuration.validate()
                } catch {
                    self.errorPresenter.present(error)
                    return
                }

                self.settings.save(configuration: configuration, hasCompletedSetup: true)
                Logger.info("Settings saved for profile: \(configuration.profile.rawValue)")
                self.close()
                onComplete?()
            },
            onTest: { [weak self] configuration in
                guard let self else { return }
                await self.test(configuration: configuration)
            }
        )

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 560, height: 420),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.title = "OpenHere 设置"
        window.contentViewController = NSHostingController(rootView: view)
        window.delegate = self
        window.isReleasedWhenClosed = false

        let controller = NSWindowController(window: window)
        windowController = controller

        NSApp.activate(ignoringOtherApps: true)
        controller.showWindow(nil)
    }

    func close() {
        windowController?.close()
        windowController = nil
    }

    func windowWillClose(_ notification: Notification) {
        windowController = nil
    }

    private func test(configuration: TerminalConfiguration) async {
        do {
            try configuration.validate()
            let directory = try finderPathResolver.resolveCurrentDirectory()
            let launcher = launcherFactory.makeLauncher(using: configuration)
            try await launcher.open(at: directory)
        } catch {
            Logger.error("Settings test failed: \(error.localizedDescription)")
            errorPresenter.present(error)
        }
    }
}
