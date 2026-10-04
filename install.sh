#!/bin/bash

# ============================================
# Dotfiles Install Script
# ============================================

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
BACKUP_DIR="$HOME/dotfiles_backup/$(date +%Y%m%d_%H%M%S)"
FORCE=false
UNINSTALL=false

# 色付き出力
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -f, --force      確認をスキップして強制実行"
    echo "  -u, --uninstall  dotfiles をアンインストール"
    echo "  -h, --help       このヘルプを表示"
    echo ""
}

# 引数の解析
while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--force)
            FORCE=true
            shift
            ;;
        -u|--uninstall)
            UNINSTALL=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            error "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Codespaces など対話できない環境では確認をスキップ（dotfiles 自動実行時は stdin が TTY でない）
if [[ "$FORCE" != true ]] && { [[ "${CODESPACES:-}" == "true" ]] || [[ ! -t 0 ]]; }; then
    FORCE=true
fi

# OS 判定
case "$(uname -s)" in
    Darwin) OS="macos" ;;
    Linux)  OS="linux" ;;
    *)      OS="other" ;;
esac

# VSCode のユーザー設定ディレクトリ
vscode_user_dir() {
    if [[ "$OS" == "macos" ]]; then
        echo "$HOME/Library/Application Support/Code/User"
    else
        echo "${XDG_CONFIG_HOME:-$HOME/.config}/Code/User"
    fi
}

# 確認プロンプト
confirm() {
    local message=$1
    if [[ "$FORCE" == true ]]; then
        return 0
    fi
    echo -en "${CYAN}[CONFIRM]${NC} $message [y/N]: "
    read -r response
    case "$response" in
        [yY][eE][sS]|[yY])
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# シンボリックリンクを削除する関数
unlink_file() {
    local dst=$1
    local filename=$(basename "$dst")

    if [[ -L "$dst" ]]; then
        local target=$(readlink "$dst")
        if [[ "$target" == "$DOTFILES_DIR"* ]]; then
            if ! confirm "$filename: シンボリックリンクを削除しますか？"; then
                warn "Skipped: $dst"
                return 0
            fi
            rm "$dst"
            info "Removed symlink: $dst"

            # 最新のバックアップから復元を試みる
            local latest_backup=$(ls -td "$HOME/dotfiles_backup"/*/ 2>/dev/null | head -1)
            if [[ -n "$latest_backup" && -f "${latest_backup}${filename}" ]]; then
                if confirm "$filename: バックアップから復元しますか？ (${latest_backup})"; then
                    cp "${latest_backup}${filename}" "$dst"
                    info "Restored from backup: $dst"
                fi
            fi
        else
            warn "Not a dotfiles symlink: $dst -> $target"
        fi
    elif [[ -e "$dst" ]]; then
        warn "Not a symlink: $dst"
    else
        info "Not found: $dst"
    fi
}

# シンボリックリンクを作成する関数
link_file() {
    local src=$1
    local dst=$2
    local filename=$(basename "$dst")

    if [[ -e "$dst" ]] || [[ -L "$dst" ]]; then
        if [[ -L "$dst" ]]; then
            local current_target=$(readlink "$dst")
            if [[ "$current_target" == "$src" ]]; then
                info "Already linked: $dst -> $src"
                return 0
            fi
            # 既存のシンボリックリンクを上書きするか確認
            if ! confirm "$filename: 既存のシンボリックリンク ($current_target) を上書きしますか？"; then
                warn "Skipped: $dst"
                return 0
            fi
            rm "$dst"
            info "Removed existing symlink: $dst"
        else
            # 既存の実ファイルを上書きするか確認
            if ! confirm "$filename: 既存のファイルをバックアップして上書きしますか？"; then
                warn "Skipped: $dst"
                return 0
            fi
            mkdir -p "$BACKUP_DIR"
            mv "$dst" "$BACKUP_DIR/"
            warn "Backed up existing file: $dst -> $BACKUP_DIR/"
        fi
    fi

    ln -s "$src" "$dst"
    info "Created symlink: $dst -> $src"
}

# アンインストール処理
uninstall() {
    echo ""
    echo "=================================="
    echo "  Dotfiles Uninstall Script"
    echo "=================================="
    echo ""

    if [[ "$FORCE" == true ]]; then
        warn "Force mode enabled - 確認なしで削除します"
    fi

    info "Starting dotfiles uninstallation..."
    echo ""

    unlink_file "$HOME/.zshrc"
    unlink_file "$HOME/.gitconfig"
    unlink_file "$HOME/.p10k.zsh"
    unlink_file "$HOME/.config/sheldon"
    unlink_file "$HOME/.config/nvim"
    unlink_file "$HOME/.gitconfig.delta"
    unlink_file "$HOME/.claude/settings.json"
    unlink_file "$HOME/.claude/CLAUDE.md"
    for f in "$DOTFILES_DIR"/config/claude/agents/*.md; do
        unlink_file "$HOME/.claude/agents/$(basename "$f")"
    done
    unlink_file "$HOME/.claude/skills/engineering-harness"
    unlink_file "$HOME/.codex/config.toml"
    unlink_file "$HOME/.codex/AGENTS.md"
    unlink_file "$(vscode_user_dir)/settings.json"
    unlink_file "$(vscode_user_dir)/keybindings.json"

    echo ""
    info "Uninstallation completed!"
    echo ""
}

# メイン処理
main() {
    echo ""
    echo "=================================="
    echo "  Dotfiles Installation Script"
    echo "=================================="
    echo ""

    # dotfiles ディレクトリの確認
    if [[ ! -d "$DOTFILES_DIR" ]]; then
        error "Dotfiles directory not found: $DOTFILES_DIR"
        exit 1
    fi

    if [[ "$FORCE" == true ]]; then
        warn "Force mode enabled - 確認なしで上書きします"
    fi

    info "Starting dotfiles installation..."
    echo ""

    # .zshrc
    if [[ -f "$DOTFILES_DIR/.zshrc" ]]; then
        link_file "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
    fi

    # .gitconfig (Codespaces は認証用の credential helper を .gitconfig に持つため上書きしない)
    if [[ "${CODESPACES:-}" == "true" ]]; then
        warn "Codespaces のため .gitconfig はスキップします"
    elif [[ -f "$DOTFILES_DIR/.gitconfig" ]]; then
        link_file "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
    fi

    # .p10k.zsh (powerlevel10k config)
    if [[ -f "$DOTFILES_DIR/.p10k.zsh" ]]; then
        link_file "$DOTFILES_DIR/.p10k.zsh" "$HOME/.p10k.zsh"
    fi

    # sheldon (plugin manager)
    if [[ -d "$DOTFILES_DIR/config/sheldon" ]]; then
        mkdir -p "$HOME/.config"
        link_file "$DOTFILES_DIR/config/sheldon" "$HOME/.config/sheldon"
    fi

    # neovim
    if [[ -d "$DOTFILES_DIR/config/nvim" ]]; then
        mkdir -p "$HOME/.config"
        link_file "$DOTFILES_DIR/config/nvim" "$HOME/.config/nvim"
    fi

    # VSCode
    local VSCODE_USER_DIR="$(vscode_user_dir)"
    if [[ -d "$DOTFILES_DIR/config/vscode" ]]; then
        mkdir -p "$VSCODE_USER_DIR"
        if [[ -f "$DOTFILES_DIR/config/vscode/settings.json" ]]; then
            link_file "$DOTFILES_DIR/config/vscode/settings.json" "$VSCODE_USER_DIR/settings.json"
        fi
        if [[ -f "$DOTFILES_DIR/config/vscode/keybindings.json" ]]; then
            link_file "$DOTFILES_DIR/config/vscode/keybindings.json" "$VSCODE_USER_DIR/keybindings.json"
        fi
    fi

    # Claude Code (認証情報やセッションは管理せず、設定ファイルのみリンク)
    if [[ -d "$DOTFILES_DIR/config/claude" ]]; then
        mkdir -p "$HOME/.claude"
        link_file "$DOTFILES_DIR/config/claude/settings.json" "$HOME/.claude/settings.json"
        link_file "$DOTFILES_DIR/config/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
        # エージェントチーム用ハーネス (サブエージェント定義 + /engineering-harness スキル)
        if [[ -d "$DOTFILES_DIR/config/claude/agents" ]]; then
            mkdir -p "$HOME/.claude/agents"
            for f in "$DOTFILES_DIR"/config/claude/agents/*.md; do
                link_file "$f" "$HOME/.claude/agents/$(basename "$f")"
            done
        fi
        if [[ -d "$DOTFILES_DIR/config/claude/skills/engineering-harness" ]]; then
            mkdir -p "$HOME/.claude/skills"
            # 旧名 (harness) のリンクが dotfiles を指していれば削除
            old="$HOME/.claude/skills/harness"
            if [[ -L "$old" && "$(readlink "$old")" == "$DOTFILES_DIR"* ]]; then
                rm "$old" && info "Removed old symlink: $old"
            fi
            link_file "$DOTFILES_DIR/config/claude/skills/engineering-harness" "$HOME/.claude/skills/engineering-harness"
        fi
    fi

    # Codex CLI
    if [[ -d "$DOTFILES_DIR/config/codex" ]]; then
        mkdir -p "$HOME/.codex"
        link_file "$DOTFILES_DIR/config/codex/config.toml" "$HOME/.codex/config.toml"
        link_file "$DOTFILES_DIR/config/codex/AGENTS.md" "$HOME/.codex/AGENTS.md"
    fi

    echo ""

    # ツールのインストール（Homebrew があれば brew、なければ公式インストーラ）
    mkdir -p "$HOME/.local/bin"
    export PATH="$HOME/.local/bin:$PATH"

    # PATH に無くても既知の場所に Homebrew があれば使う
    if ! command -v brew &> /dev/null; then
        for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew "$HOME/.linuxbrew/bin/brew"; do
            if [[ -x "$brew_bin" ]]; then
                eval "$("$brew_bin" shellenv)"
                break
            fi
        done
    fi

    # 必須コマンドの確認
    for cmd in git curl zsh; do
        if ! command -v "$cmd" &> /dev/null; then
            warn "$cmd が見つかりません。パッケージマネージャーでインストールしてください (例: sudo apt install $cmd)"
        fi
    done

    install_tool() {
        local name=$1
        local installer=$2
        if command -v "$name" &> /dev/null; then
            return 0
        fi
        info "Installing $name..."
        if command -v brew &> /dev/null; then
            brew install "$name"
        elif ! eval "$installer"; then
            warn "$name のインストールに失敗しました。手動でインストールしてください"
        fi
    }

    install_tool sheldon 'curl --proto "=https" -fLsS https://rossmacarthur.github.io/install/crate.sh | bash -s -- --repo rossmacarthur/sheldon --to "$HOME/.local/bin"'
    install_tool mise 'curl -fsSL https://mise.run | sh'
    install_tool fzf 'git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf" && "$HOME/.fzf/install" --bin && ln -sf "$HOME/.fzf/bin/fzf" "$HOME/.local/bin/fzf"'

    # Claude Code / Codex CLI (npm を優先、無ければ代替手段)
    if ! command -v claude &> /dev/null; then
        info "Installing claude..."
        if command -v npm &> /dev/null; then
            npm install -g @anthropic-ai/claude-code || warn "claude のインストールに失敗しました"
        else
            curl -fsSL https://claude.ai/install.sh | bash || warn "claude のインストールに失敗しました"
        fi
    fi

    if ! command -v codex &> /dev/null; then
        info "Installing codex..."
        if command -v npm &> /dev/null; then
            npm install -g @openai/codex || warn "codex のインストールに失敗しました"
        elif command -v brew &> /dev/null; then
            brew install codex || warn "codex のインストールに失敗しました"
        else
            warn "codex には npm か brew が必要です。mise で node を入れてから再実行してください"
        fi
    fi

    # agy (Antigravity CLI): 公式インストーラが無いため未導入なら案内のみ
    if ! command -v agy &> /dev/null; then
        warn "agy が見つかりません。/engineering-harness の gemini 系エージェントを使うには agy を導入してください"
    fi

    # delta (git pager): 入っている場合のみ git 設定を有効化
    if ! command -v delta &> /dev/null && command -v brew &> /dev/null; then
        info "Installing delta..."
        brew install git-delta || warn "delta のインストールに失敗しました"
    fi
    if command -v delta &> /dev/null; then
        link_file "$DOTFILES_DIR/config/git/delta.gitconfig" "$HOME/.gitconfig.delta"
    else
        warn "delta が無いため git の pager 設定はスキップします"
    fi

    # sheldon プラグインのダウンロード
    if command -v sheldon &> /dev/null; then
        info "Downloading sheldon plugins..."
        sheldon lock
    fi

    # .zshrc.local のテンプレートコピー（存在しない場合のみ）
    if [[ ! -f "$HOME/.zshrc.local" ]] && [[ -f "$DOTFILES_DIR/.zshrc.local.example" ]]; then
        cp "$DOTFILES_DIR/.zshrc.local.example" "$HOME/.zshrc.local"
        info "Created ~/.zshrc.local from template"
    fi

    echo ""
    info "Installation completed!"
    echo ""

    if [[ -d "$BACKUP_DIR" ]]; then
        warn "Backup files are stored in: $BACKUP_DIR"
    fi

    echo ""
    echo "Next steps:"
    echo "  1. Edit ~/.gitconfig to set your name and email"
    echo "  2. Run 'source ~/.zshrc' or restart your terminal"
    echo ""
}

# 実行
if [[ "$UNINSTALL" == true ]]; then
    uninstall
else
    main
fi
