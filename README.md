# OpenHere

中文 | [English](#english)

OpenHere 是一个轻量的 macOS 小工具，用来从 Finder 当前目录一键打开终端，适合作为 Finder 工具栏按钮使用，体验类似 Go2Shell。

## 功能特性

- 在 Finder 当前目录中快速打开终端
- 支持 `Terminal.app`
- 支持 `iTerm2`
- 支持自定义终端可执行文件
- 支持可选的“打开后执行一行命令”
- 支持中英文界面
- 支持 Finder 工具栏添加引导

## 系统要求

- macOS 15.0 或更高版本
- 首次使用时需要允许 OpenHere 控制 Finder

## 安装

1. 构建或下载 `OpenHere.app`
2. 将 `OpenHere.app` 放入 `/Applications`
3. 首次运行时完成终端配置

## 添加到 Finder 工具栏

1. 打开 Finder
2. 在“应用程序”中找到 `OpenHere.app`
3. 按住 `Command`
4. 将 `OpenHere.app` 拖到 Finder 窗口顶部工具栏
5. 看到绿色加号后松开

之后在任意 Finder 文件夹中点击 OpenHere 图标，即可打开终端到当前目录。

## 使用方式

### 快速打开

- 正常启动 OpenHere，可在 Finder 当前目录中打开终端
- 如果启用了启动询问，会先显示一个小型启动选择窗口

### 打开设置

可以通过以下方式进入设置：

- App 菜单中的 `设置...`
- Dock 图标右键菜单中的 `设置...`
- 按住 `Option` 启动 OpenHere

## 支持的终端

### Terminal.app

- 使用系统默认终端打开 Finder 当前目录

### iTerm2

- 通过 AppleScript 控制 iTerm2 新建窗口并进入目标目录

### 自定义终端

- 支持选择 `.app` 或实际可执行文件
- 支持参数模板
- 支持 `{path}` 占位符
- 支持 `{command}` 占位符

示例：

```text
--working-directory {path}
```

```text
-e "cd {path}; {command}"
```

## 打开后执行命令

可以在设置中启用“打开终端后执行这条命令”：

- OpenHere 会先进入 Finder 当前目录
- 然后执行你填写的一行命令
- `Terminal.app` 和 `iTerm2` 直接支持
- 自定义终端可通过 `{command}` 占位符接入

注意：这条命令会原样交给终端执行，请只填写你确认安全的命令。

## 权限说明

OpenHere 需要 Finder 自动化权限，用来读取 Finder 当前窗口或选中项对应的目录。

如果权限被拒绝，可以前往：

`系统设置 > 隐私与安全性 > 自动化`

允许 OpenHere 控制 Finder。

## 项目结构

```text
OpenHere/
├── App/
├── Finder/
├── Launchers/
├── Models/
├── Settings/
├── Shared/
├── Assets.xcassets
├── InfoPlist.strings/
└── Localizable.strings/
```

## 开发

### 构建

在 Xcode 中打开项目后直接构建，或使用：

```bash
xcodebuild -scheme OpenHere -configuration Debug build
```

### 代码组织

- `App/`：应用入口与全局流程
- `Finder/`：Finder 权限和路径解析
- `Launchers/`：不同终端的启动实现
- `Models/`：配置和协议模型
- `Settings/`：设置界面与相关窗口
- `Shared/`：通用工具与共享逻辑

---

## English

OpenHere is a small macOS utility that opens a terminal in the current Finder folder with one click. It is designed to work well as a Finder toolbar button, with a workflow similar to Go2Shell.

## Features

- Open a terminal in the current Finder folder
- Supports `Terminal.app`
- Supports `iTerm2`
- Supports custom terminal executables
- Optional “run a command after opening”
- Bilingual UI: English and Simplified Chinese
- Built-in Finder toolbar setup guide

## Requirements

- macOS 15.0 or later
- Finder automation permission on first use

## Installation

1. Build or download `OpenHere.app`
2. Move `OpenHere.app` to `/Applications`
3. Launch it once and finish setup

## Add to Finder Toolbar

1. Open Finder
2. Locate `OpenHere.app` in Applications
3. Hold the `Command` key
4. Drag `OpenHere.app` to the Finder toolbar
5. Release when the green plus badge appears

After that, click the OpenHere icon in any Finder folder to open a terminal at the current directory.

## Usage

### Quick Action

- Launch OpenHere normally to open a terminal in the current Finder folder
- If launch choice is enabled, a small chooser window appears first

### Open Settings

You can reopen settings from:

- `Settings...` in the app menu
- `Settings...` in the Dock menu
- Launching OpenHere while holding `Option`

## Supported Terminals

### Terminal.app

- Opens the current Finder folder in the system terminal

### iTerm2

- Uses AppleScript to create a new iTerm2 window and switch to the target directory

### Custom Terminal

- Supports `.app` bundles and executable paths
- Supports argument templates
- Supports the `{path}` placeholder
- Supports the `{command}` placeholder

Examples:

```text
--working-directory {path}
```

```text
-e "cd {path}; {command}"
```

## Run a Command After Opening

You can enable an optional post-launch command in settings:

- OpenHere enters the Finder directory first
- Then it runs your single-line command
- `Terminal.app` and `iTerm2` support this directly
- Custom terminals can receive it through the `{command}` placeholder

Note: the command is passed to the terminal as-is. Only use commands you trust.

## Permissions

OpenHere needs Finder automation permission to read the current Finder window or selection.

If permission was denied, go to:

`System Settings > Privacy & Security > Automation`

and allow OpenHere to control Finder.

## Project Layout

```text
OpenHere/
├── App/
├── Finder/
├── Launchers/
├── Models/
├── Settings/
├── Shared/
├── Assets.xcassets
├── InfoPlist.strings/
└── Localizable.strings/
```

## Development

### Build

Open the project in Xcode and build it, or run:

```bash
xcodebuild -scheme OpenHere -configuration Debug build
```

### Code Organization

- `App/`: app entry and top-level flow
- `Finder/`: Finder permissions and path resolution
- `Launchers/`: terminal launch implementations
- `Models/`: configuration and protocol models
- `Settings/`: settings UI and related windows
- `Shared/`: shared utilities and helpers
