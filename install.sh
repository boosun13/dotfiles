#!/bin/bash

# ============================================
# Dotfiles Install Script
# ============================================

set -e

DOTFILES_DIR="$HOME/dotfiles"
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

    # .gitconfig
    if [[ -f "$DOTFILES_DIR/.gitconfig" ]]; then
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

    echo ""

    # Homebrew がある場合、必要なツールをインストール
    if command -v brew &> /dev/null; then
        # sheldon
        if ! command -v sheldon &> /dev/null; then
            info "Installing sheldon..."
            brew install sheldon
        fi

        # fzf
        if ! command -v fzf &> /dev/null; then
            info "Installing fzf..."
            brew install fzf
        fi

        # mise (version manager)
        if ! command -v mise &> /dev/null; then
            info "Installing mise..."
            brew install mise
        fi
    else
        warn "Homebrew がインストールされていません"
        warn "手動でインストールしてください:"
        warn "  - sheldon: https://sheldon.cli.rs"
        warn "  - mise: https://mise.jdx.dev"
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
