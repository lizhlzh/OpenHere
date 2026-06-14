//
//  LaunchChoiceView.swift
//  OpenHere
//
//  Created by Codex on 2026/6/14.
//

import SwiftUI

struct LaunchChoiceView: View {
    @State private var shouldRememberDirectLaunch = false

    let onOpenTerminal: (_ rememberDirectLaunch: Bool) -> Void
    let onOpenSettings: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text(L10n.tr("launchChoice.title"))
                    .font(.title2)
                    .fontWeight(.semibold)

                Text(L10n.tr("launchChoice.description"))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Toggle(L10n.tr("launchChoice.rememberDirectLaunch"), isOn: $shouldRememberDirectLaunch)

            Text(L10n.tr("launchChoice.hint"))
                .font(.footnote)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            HStack {
                Button(L10n.tr("common.cancel")) {
                    onCancel()
                }

                Spacer()

                Button(L10n.tr("launchChoice.openSettings")) {
                    onOpenSettings()
                }

                Button(L10n.tr("launchChoice.openCurrentFinderDirectory")) {
                    onOpenTerminal(shouldRememberDirectLaunch)
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(24)
        .frame(width: 420)
    }
}

#Preview {
    LaunchChoiceView(
        onOpenTerminal: { _ in },
        onOpenSettings: {},
        onCancel: {}
    )
}
