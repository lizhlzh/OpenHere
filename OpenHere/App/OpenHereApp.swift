//
//  OpenHereApp.swift
//  OpenHere
//
//  Created by lzh on 2026/6/14.
//

import SwiftUI

@main
struct OpenHereApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
        .commands {
            CommandGroup(replacing: .appSettings) {
                Button(L10n.tr("menu.settings")) {
                    appDelegate.showPreferencesWindow(nil)
                }
                .keyboardShortcut(",", modifiers: .command)

                Button(L10n.tr("menu.addToFinderToolbar")) {
                    appDelegate.showFinderToolbarGuide(nil)
                }
            }
        }
    }
}
