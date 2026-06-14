//
//  AppDelegate.swift
//  OpenHere
//
//  Created by Codex on 2026/6/14.
//

import AppKit
import Foundation
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let settings = AppSettings.shared
    private let finderPathResolver = FinderPathResolver()
    private let launcherFactory = TerminalLauncherFactory()
    private let errorPresenter = ErrorPresenter()
    private var launchChoiceWindowController: NSWindowController?

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

        if settings.launchBehavior == .askAtLaunch {
            Logger.info("Opening launch choice window")
            showLaunchChoiceWindow()
            return
        }

        Logger.info("Executing quick action")
        Task {
            await performQuickAction()
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    @objc func showPreferencesWindow(_ sender: Any?) {
        settingsWindowController.show()
    }

    @objc func showFinderToolbarGuide(_ sender: Any?) {
        settingsWindowController.showFinderToolbarGuide()
    }

    func applicationDockMenu(_ sender: NSApplication) -> NSMenu? {
        let menu = NSMenu()

        let openHereItem = NSMenuItem(
            title: L10n.tr("dock.openCurrentFinderDirectory"),
            action: #selector(openCurrentFinderDirectoryFromDock(_:)),
            keyEquivalent: ""
        )
        openHereItem.target = self
        menu.addItem(openHereItem)

        menu.addItem(.separator())

        let settingsItem = NSMenuItem(
            title: L10n.tr("menu.settings"),
            action: #selector(showPreferencesWindow(_:)),
            keyEquivalent: ""
        )
        settingsItem.target = self
        menu.addItem(settingsItem)

        let guideItem = NSMenuItem(
            title: L10n.tr("menu.addToFinderToolbar"),
            action: #selector(showFinderToolbarGuide(_:)),
            keyEquivalent: ""
        )
        guideItem.target = self
        menu.addItem(guideItem)

        return menu
    }

    private var shouldOpenSettings: Bool {
        shouldForceSettingsWindow || settings.hasCompletedSetup == false
    }

    private var shouldForceSettingsWindow: Bool {
        let flags = CGEventSource.flagsState(.combinedSessionState)
        return flags.contains(.maskAlternate)
    }

    @objc private func openCurrentFinderDirectoryFromDock(_ sender: Any?) {
        closeLaunchChoiceWindow()

        Task {
            await performQuickAction()
        }
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

    private func showLaunchChoiceWindow() {
        if let window = launchChoiceWindowController?.window {
            NSApp.activate(ignoringOtherApps: true)
            window.makeKeyAndOrderFront(nil)
            return
        }

        let view = LaunchChoiceView(
            onOpenTerminal: { [weak self] rememberDirectLaunch in
                guard let self else { return }

                if rememberDirectLaunch {
                    self.settings.launchBehavior = .directAction
                }

                self.closeLaunchChoiceWindow()
                Task {
                    await self.performQuickAction()
                }
            },
            onOpenSettings: { [weak self] in
                guard let self else { return }
                self.closeLaunchChoiceWindow()
                self.settingsWindowController.show()
            },
            onCancel: { [weak self] in
                self?.closeLaunchChoiceWindow()
                NSApp.terminate(nil)
            }
        )

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 420, height: 220),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.title = L10n.tr("launchChoice.windowTitle")
        window.contentViewController = NSHostingController(rootView: view)
        window.delegate = self
        window.isReleasedWhenClosed = false

        let controller = NSWindowController(window: window)
        launchChoiceWindowController = controller

        NSApp.activate(ignoringOtherApps: true)
        controller.showWindow(nil)
    }

    private func closeLaunchChoiceWindow() {
        launchChoiceWindowController?.close()
        launchChoiceWindowController = nil
    }
}

extension AppDelegate: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        guard let closedWindow = notification.object as? NSWindow else {
            return
        }

        if closedWindow === launchChoiceWindowController?.window {
            launchChoiceWindowController = nil
            NSApp.terminate(nil)
        }
    }
}
