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
    @State private var isTesting = false

    let onComplete: (TerminalConfiguration) -> Void
    let onTest: (TerminalConfiguration) async -> Void

    init(
        configuration: TerminalConfiguration,
        onComplete: @escaping (TerminalConfiguration) -> Void,
        onTest: @escaping (TerminalConfiguration) async -> Void
    ) {
        _profile = State(initialValue: configuration.profile)
        _customExecutablePath = State(initialValue: configuration.customExecutablePath)
        _argumentsTemplateText = State(
            initialValue: configuration.customArgumentsTemplate.joined(separator: "\n")
        )
        self.onComplete = onComplete
        self.onTest = onTest
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("OpenHere 设置")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("选择在 Finder 当前文件夹中打开的终端。完成后可将 OpenHere.app 拖到 Finder 工具栏使用。")
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("按住 Option 启动 OpenHere，可随时重新打开这个设置窗口。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("默认终端")
                    .fontWeight(.medium)

                Picker("默认终端", selection: $profile) {
                    ForEach(TerminalProfile.allCases) { option in
                        Text(option.displayName).tag(option)
                    }
                }
                .pickerStyle(.radioGroup)
                .labelsHidden()
            }

            if profile == .custom {
                VStack(alignment: .leading, spacing: 12) {
                    Text("自定义终端")
                        .fontWeight(.medium)

                    HStack(alignment: .center, spacing: 8) {
                        TextField("可执行文件路径", text: $customExecutablePath)
                            .textFieldStyle(.roundedBorder)

                        Button("选择...") {
                            chooseExecutable()
                        }
                    }

                    if let customValidationMessage {
                        Text(customValidationMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("参数模板")
                        TextEditor(text: $argumentsTemplateText)
                            .font(.system(.body, design: .monospaced))
                            .frame(minHeight: 100)
                            .overlay {
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                            }
                        Text("使用 {path} 表示 Finder 当前目录")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            HStack {
                Spacer()

                Button("测试打开当前 Finder 目录") {
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

                Button("完成设置") {
                    onComplete(currentConfiguration())
                }
                .disabled(canSubmit == false)
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(24)
        .frame(width: 560)
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
                .map { String($0) }
        )
    }

    private func chooseExecutable() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.resolvesAliases = true
        panel.prompt = "选择"

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
    SettingsView(configuration: .default, onComplete: { _ in }, onTest: { _ in })
}
