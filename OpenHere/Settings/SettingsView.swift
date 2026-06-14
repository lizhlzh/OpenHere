//
//  SettingsView.swift
//  OpenHere
//
//  Created by Codex on 2026/6/14.
//

import AppKit
import SwiftUI

struct SettingsView: View {
    @State private var profile: TerminalProfile
    @State private var customExecutablePath: String
    @State private var argumentsTemplateText: String
    @State private var shouldRunPostLaunchCommand: Bool
    @State private var postLaunchCommand: String
    @State private var isTesting = false

    let onComplete: (TerminalConfiguration) -> Void
    let onTest: (TerminalConfiguration) async -> Void
    let onShowFinderToolbarGuide: () -> Void

    init(
        configuration: TerminalConfiguration,
        onComplete: @escaping (TerminalConfiguration) -> Void,
        onTest: @escaping (TerminalConfiguration) async -> Void,
        onShowFinderToolbarGuide: @escaping () -> Void
    ) {
        _profile = State(initialValue: configuration.profile)
        _customExecutablePath = State(initialValue: configuration.customExecutablePath)
        _argumentsTemplateText = State(
            initialValue: configuration.customArgumentsTemplate.joined(separator: "\n")
        )
        _shouldRunPostLaunchCommand = State(initialValue: configuration.shouldRunPostLaunchCommand)
        _postLaunchCommand = State(initialValue: configuration.postLaunchCommand)
        self.onComplete = onComplete
        self.onTest = onTest
        self.onShowFinderToolbarGuide = onShowFinderToolbarGuide
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n.tr("settings.title"))
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text(L10n.tr("settings.description"))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(L10n.tr("settings.optionHint"))
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    if AppLocationHelper.isRunningFromApplications == false {
                        Text(L10n.tr("settings.applicationsHint"))
                            .font(.footnote)
                            .foregroundStyle(.orange)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Button(L10n.tr("settings.showFinderToolbarGuide")) {
                        onShowFinderToolbarGuide()
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text(L10n.tr("settings.defaultTerminal"))
                        .fontWeight(.medium)

                    Picker(L10n.tr("settings.defaultTerminal"), selection: $profile) {
                        ForEach(TerminalProfile.allCases) { option in
                            Text(option.displayName).tag(option)
                        }
                    }
                    .pickerStyle(.radioGroup)
                    .labelsHidden()
                }

                if profile == .custom {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(L10n.tr("settings.customTerminal"))
                            .fontWeight(.medium)

                        HStack(alignment: .center, spacing: 8) {
                            TextField(L10n.tr("settings.customExecutablePath"), text: $customExecutablePath)
                                .textFieldStyle(.roundedBorder)

                            Button(L10n.tr("settings.choose")) {
                                chooseExecutable()
                            }
                        }

                        if let customValidationMessage {
                            Text(customValidationMessage)
                                .font(.footnote)
                                .foregroundStyle(.red)
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text(L10n.tr("settings.argumentsTemplate"))
                            TextEditor(text: $argumentsTemplateText)
                                .font(.system(.body, design: .monospaced))
                                .frame(minHeight: 100)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                                }
                            Text(L10n.tr("settings.argumentsTemplateHint"))
                                .font(.footnote)
                                .foregroundStyle(.secondary)

                            Text(L10n.tr("settings.customCommandPlaceholderHint"))
                                .font(.footnote)
                                .foregroundStyle(.secondary)

                            Text(L10n.tr("settings.customTerminalExamples"))
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n.tr("settings.postLaunchCommand"))
                        .fontWeight(.medium)

                    Toggle(L10n.tr("settings.enablePostLaunchCommand"), isOn: $shouldRunPostLaunchCommand)

                    TextField(L10n.tr("settings.postLaunchCommandPlaceholder"), text: $postLaunchCommand)
                        .textFieldStyle(.roundedBorder)
                        .disabled(shouldRunPostLaunchCommand == false)

                    Text(L10n.tr("settings.postLaunchCommandHint"))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(L10n.tr("settings.postLaunchCommandSafetyHint"))
                        .font(.footnote)
                        .foregroundStyle(.orange)
                        .fixedSize(horizontal: false, vertical: true)
                }

                HStack {
                    Spacer()

                    Button(L10n.tr("settings.testOpenCurrentFinderDirectory")) {
                        let configuration = currentConfiguration()
                        isTesting = true

                        Task {
                            await onTest(configuration)
                            await MainActor.run {
                                isTesting = false
                            }
                        }
                    }
                    .disabled(isTesting || canSubmit == false)

                    Button(L10n.tr("settings.complete")) {
                        onComplete(currentConfiguration())
                    }
                    .disabled(canSubmit == false)
                    .keyboardShortcut(.defaultAction)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(24)
        }
        .frame(width: 560)
        .frame(minHeight: 460)
    }

    private var canSubmit: Bool {
        customValidationMessage == nil
    }

    private var customValidationMessage: String? {
        let configuration = currentConfiguration()

        do {
            try configuration.validate()
            return nil
        } catch {
            return error.localizedDescription
        }
    }

    private func currentConfiguration() -> TerminalConfiguration {
        TerminalConfiguration(
            profile: profile,
            customExecutablePath: customExecutablePath.trimmingCharacters(in: .whitespacesAndNewlines),
            customArgumentsTemplate: argumentsTemplateText
                .split(whereSeparator: \.isNewline)
                .map { String($0) },
            shouldRunPostLaunchCommand: shouldRunPostLaunchCommand,
            postLaunchCommand: postLaunchCommand
        )
    }

    private func chooseExecutable() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.resolvesAliases = true
        panel.prompt = L10n.tr("settings.choose")
        panel.message = L10n.tr("settings.chooseExecutableMessage")

        if panel.runModal() == .OK, let url = panel.url {
            if let executableURL = Bundle(url: url)?.executableURL {
                customExecutablePath = executableURL.path
            } else {
                customExecutablePath = url.path
            }
        }
    }
}

#Preview {
    SettingsView(
        configuration: .default,
        onComplete: { _ in },
        onTest: { _ in },
        onShowFinderToolbarGuide: {}
    )
}
