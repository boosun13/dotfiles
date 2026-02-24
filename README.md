# Dotfiles

My personal dotfiles managed with Git.

## Contents

- `.zshrc` - Zsh shell configuration
- `.gitconfig` - Git configuration
- `config/sheldon/plugins.toml` - Zsh plugin manager configuration

## Installation

```bash
# sheldon (plugin manager) をインストール
brew install sheldon

# dotfiles をセットアップ
cd ~/dotfiles
chmod +x install.sh
./install.sh

# プラグインをダウンロード
sheldon lock
```

### Options

```bash
./install.sh -f    # 確認なしで強制上書き
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
├── config/
│   └── sheldon/
│       └── plugins.toml    # Zsh plugins (syntax-highlighting, autosuggestions)
├── install.sh              # Symlink installer script
└── README.md
```

## Local Customization

For machine-specific settings, create `~/.zshrc.local`. This file is sourced by `.zshrc` if it exists.
