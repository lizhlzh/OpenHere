//
//  AppLocationHelper.swift
//  OpenHere
//
//  Created by Codex on 2026/6/14.
//

import AppKit
import Foundation

struct AppLocationHelper {
    static var currentAppURL: URL {
        Bundle.main.bundleURL.resolvingSymlinksInPath()
    }

    static var applicationsDirectoryURL: URL {
        URL(fileURLWithPath: "/Applications", isDirectory: true)
    }

    static var isRunningFromApplications: Bool {
        let applicationsPath = applicationsDirectoryURL.path
        let appPath = currentAppURL.path
        return appPath == applicationsPath || appPath.hasPrefix(applicationsPath + "/")
    }

    static func revealCurrentAppInFinder() {
        NSWorkspace.shared.activateFileViewerSelecting([currentAppURL])
    }

    static func openApplicationsFolder() {
        NSWorkspace.shared.open(applicationsDirectoryURL)
    }
}
