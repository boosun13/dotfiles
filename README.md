# Dotfiles

My personal dotfiles managed with Git.

## Contents

- `.zshrc` - Zsh shell configuration
- `.gitconfig` - Git configuration
- `.p10k.zsh` - Powerlevel10k prompt configuration
- `.zshrc.local.example` - Local settings template (mise, pnpm)
- `Brewfile` - Homebrew package manifest
- `config/sheldon/plugins.toml` - Zsh plugin manager configuration

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
