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
    private var finderToolbarGuideWindowController: NSWindowController?

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
                let wasCompleted = self.settings.hasCompletedSetup

                do {
                    try configuration.validate()
                } catch {
                    self.errorPresenter.present(error)
                    return
                }

                self.settings.save(configuration: configuration, hasCompletedSetup: true)
                Logger.info("Settings saved for profile: \(configuration.profile.rawValue)")
                self.close()
                if wasCompleted == false {
                    self.showFinderToolbarGuide()
                }
                onComplete?()
            },
            onTest: { [weak self] configuration in
                guard let self else { return }
                await self.test(configuration: configuration)
            },
            onShowFinderToolbarGuide: { [weak self] in
                self?.showFinderToolbarGuide()
            }
        )

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 560, height: 520),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.title = L10n.tr("settings.windowTitle")
        window.minSize = NSSize(width: 560, height: 420)
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

    func showFinderToolbarGuide() {
        if let window = finderToolbarGuideWindowController?.window {
            NSApp.activate(ignoringOtherApps: true)
            window.makeKeyAndOrderFront(nil)
            return
        }

        let view = FinderToolbarGuideView(
            onRevealCurrentApp: {
                AppLocationHelper.revealCurrentAppInFinder()
            },
            onOpenApplicationsFolder: {
                AppLocationHelper.openApplicationsFolder()
            },
            onDismiss: { [weak self] in
                self?.closeFinderToolbarGuide()
            }
        )

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 560, height: 460),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.title = L10n.tr("finderToolbarGuide.windowTitle")
        window.contentViewController = NSHostingController(rootView: view)
        window.delegate = self
        window.isReleasedWhenClosed = false

        let controller = NSWindowController(window: window)
        finderToolbarGuideWindowController = controller

        NSApp.activate(ignoringOtherApps: true)
        controller.showWindow(nil)
    }

    func windowWillClose(_ notification: Notification) {
        guard let closedWindow = notification.object as? NSWindow else {
            return
        }

        if closedWindow === windowController?.window {
            windowController = nil
        }

        if closedWindow === finderToolbarGuideWindowController?.window {
            finderToolbarGuideWindowController = nil
        }
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

    private func closeFinderToolbarGuide() {
        finderToolbarGuideWindowController?.close()
        finderToolbarGuideWindowController = nil
    }
}
