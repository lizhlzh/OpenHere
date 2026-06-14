//
//  FinderToolbarGuideView.swift
//  OpenHere
//
//  Created by Codex on 2026/6/14.
//

import SwiftUI

struct FinderToolbarGuideView: View {
    let onRevealCurrentApp: () -> Void
    let onOpenApplicationsFolder: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text(L10n.tr("finderToolbarGuide.title"))
                    .font(.headline)

                Text(L10n.tr("finderToolbarGuide.description"))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if AppLocationHelper.isRunningFromApplications == false {
                Text(L10n.tr("settings.applicationsHint"))
                    .font(.footnote)
                    .foregroundStyle(.orange)
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(alignment: .leading, spacing: 10) {
                Text(L10n.tr("finderToolbarGuide.step1"))
                Text(L10n.tr("finderToolbarGuide.step2"))
                Text(L10n.tr("finderToolbarGuide.step3"))
                Text(L10n.tr("finderToolbarGuide.step4"))
                Text(L10n.tr("finderToolbarGuide.step5"))
                Text(L10n.tr("finderToolbarGuide.step6"))
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Text(L10n.tr("finderToolbarGuide.footer"))
                .font(.footnote)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            HStack {
                Button(L10n.tr("finderToolbarGuide.revealApp")) {
                    onRevealCurrentApp()
                }

                Button(L10n.tr("finderToolbarGuide.openApplications")) {
                    onOpenApplicationsFolder()
                }

                Spacer()

                Button(L10n.tr("common.gotIt")) {
                    onDismiss()
                }
            }
        }
        .padding(24)
        .frame(width: 560, height: 460, alignment: .topLeading)
    }
}

#Preview {
    FinderToolbarGuideView(
        onRevealCurrentApp: {},
        onOpenApplicationsFolder: {},
        onDismiss: {}
    )
}
