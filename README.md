# Dotfiles

My personal dotfiles managed with Git.

## Contents

- `.zshrc` - Zsh shell configuration
- `.gitconfig` - Git configuration
- `.p10k.zsh` - Powerlevel10k prompt configuration
- `.zshrc.local.example` - Local settings template (mise, pnpm)
- `Brewfile` - Homebrew package manifest
- `config/sheldon/plugins.toml` - Zsh plugin manager configuration
- `config/claude/` - Claude Code 設定 (`settings.json`, `CLAUDE.md`) → `~/.claude/`
- `config/claude/agents/` - エージェントチーム用サブエージェント10体 → `~/.claude/agents/`
- `config/claude/skills/engineering-harness/` - エンジニアリングハーネス `/engineering-harness` スキル（教訓 `lessons.md` を含む。オーケストレーター指示・手札名鑑・`codex-run` / `agy-run` ラッパー）→ `~/.claude/skills/engineering-harness`。codex / agy が必要
- `config/codex/` - Codex CLI 設定 (`config.toml`, `AGENTS.md`) → `~/.codex/`。`AGENTS.md` は `CLAUDE.md` と共通

## Supported OS

macOS / Linux (Debian・Ubuntu・Codespaces など) / WSL に対応しています。Windows ネイティブは非対応です（WSL を使用してください）。

- 事前に `git` `curl` `zsh` が必要です
- リポジトリはどこに clone しても動作します（`~/dotfiles` 固定ではありません）
- Homebrew があれば brew、無ければ公式インストーラで `sheldon` `mise` `fzf` を `~/.local/bin` に入れます
- `delta` は Homebrew がある場合のみ導入し、入っている環境だけ git の pager 設定 (`config/git/delta.gitconfig`) を有効化します
- VSCode 設定のリンク先は OS ごとに切り替わります（macOS: `~/Library/Application Support/Code/User`、Linux: `~/.config/Code/User`）
- `macos.sh` は macOS 専用です
- Claude Code と Codex は npm を優先して導入します（npm が無ければ Claude Code は公式インストーラ、Codex は brew）。認証情報やセッションは管理せず、設定ファイルのみリンクします（初回は `claude` / `codex` を起動してログインしてください）

## Installation

```bash
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

これだけで sheldon のインストールとプラグインのダウンロードも自動で行われます。

### Options

```bash
./install.sh -f    # 確認なしで強制インストール
./install.sh -u    # アンインストール（バックアップから復元可能）
./install.sh -h    # ヘルプを表示
```

通常実行時は既存ファイルがある場合に確認プロンプトが表示されます。
`-f` オプションで確認をスキップして即座に上書きできます（既存ファイルはバックアップされます）。

## Codespaces

`.devcontainer/devcontainer.json` で、同一アカウント(`boosun13/*`)の全リポジトリへ `contents: write` を付与しています。Codespace 作成時に権限の承認が求められ、変更は**新しく作る Codespace** から有効になります。

GitHub の dotfiles 機能に対応しており、Codespace 作成時に `install.sh` が自動実行されます。
対話できない環境（`CODESPACES=true` または stdin が TTY でない場合）では自動的に `-f` 相当で動作し、既存ファイルはバックアップされます。
Codespaces が認証設定を持つ `~/.gitconfig` は上書きしません。

## Manual Setup

After installation, edit `.gitconfig` to set your Git user:

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

## Structure

```
~/dotfiles/
├── .gitconfig              # Git settings & aliases
├── .zshrc                  # Zsh config (prompt, aliases, functions)
├── .p10k.zsh               # Powerlevel10k prompt config
├── .zshrc.local.example    # Local settings template
├── Brewfile                # Homebrew packages
├── config/
│   └── sheldon/
│       └── plugins.toml    # Zsh plugins (powerlevel10k, syntax-highlighting, etc.)
├── install.sh              # Symlink installer script
└── README.md
```

## Local Customization

マシン固有の設定は `~/.zshrc.local` に記述します（dotfiles 管理外）。

```bash
cp ~/dotfiles/.zshrc.local.example ~/.zshrc.local
```

テンプレートには以下が含まれています:
- mise (Node.js, Python, Ruby などの統一バージョンマネージャー)
- pnpm

## Homebrew Packages

```bash
brew bundle --file=~/dotfiles/Brewfile
```

Brewfile には開発に必要なツールが含まれています。
