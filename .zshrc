# ============================================
# Dotfiles - .zshrc
# ============================================

# --------------------------------------------
# Powerlevel10k Instant Prompt (高速起動)
# --------------------------------------------
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# --------------------------------------------
# Homebrew (macOS / Linux)
# --------------------------------------------
if ! command -v brew &> /dev/null; then
    for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew "$HOME/.linuxbrew/bin/brew"; do
        if [[ -x "$brew_bin" ]]; then
            eval "$("$brew_bin" shellenv)"
            break
        fi
    done
fi

# --------------------------------------------
# Plugin Manager (sheldon)
# --------------------------------------------
if command -v sheldon &> /dev/null; then
    eval "$(sheldon source)"
fi

# Powerlevel10k 設定
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# --------------------------------------------
# History settings
# --------------------------------------------
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS       # 重複するコマンドは履歴に追加しない
setopt HIST_IGNORE_SPACE      # スペースで始まるコマンドは履歴に追加しない
setopt SHARE_HISTORY          # 履歴をセッション間で共有
setopt APPEND_HISTORY         # 履歴を追記

# --------------------------------------------
# General settings
# --------------------------------------------
setopt AUTO_CD                # ディレクトリ名だけで cd
setopt AUTO_PUSHD             # cd したら自動的に pushd
setopt PUSHD_IGNORE_DUPS      # 重複するディレクトリは pushd しない
setopt CORRECT                # コマンドのスペルミスを修正

# 単語区切り文字の設定（/._- などで区切る）
WORDCHARS='*?[]~=&;!#$%^(){}<>'

# --------------------------------------------
# Key bindings (Option + 矢印で単語移動)
# --------------------------------------------
bindkey '\e[1;3D' backward-word  # Option + Left
bindkey '\e[1;3C' forward-word   # Option + Right
bindkey '\e\e[D' backward-word   # Option + Left (alternative)
bindkey '\e\e[C' forward-word    # Option + Right (alternative)

# --------------------------------------------
# Completion
# --------------------------------------------
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'  # 大文字小文字を区別しない
zstyle ':completion:*' menu select                    # 補完候補をメニュー表示

# --------------------------------------------
# Aliases - General
# --------------------------------------------
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# eza (modern ls) or fallback to ls
if command -v eza &> /dev/null; then
    alias ls='eza'
    alias ll='eza -la --git'
    alias la='eza -a'
    alias l='eza -F'
    alias tree='eza --tree'
else
    if ls --color=auto / &> /dev/null; then
        alias ls='ls --color=auto'  # GNU ls (Linux)
    fi
    alias ll='ls -la'
    alias la='ls -A'
    alias l='ls -CF'
    export CLICOLOR=1
    export LSCOLORS=GxFxCxDxBxegedabagaced
fi

# bat (modern cat)
if command -v bat &> /dev/null; then
    alias cat='bat --paging=never'
    alias catp='bat'  # with pager
fi

# --------------------------------------------
# Aliases - Git
# --------------------------------------------
alias g='git'
alias gs='git status'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit'
alias gcm='git commit -m'
alias gp='git push'
alias gpl='git pull'
alias gco='git checkout'
alias gb='git branch'
alias gd='git diff'
alias gl='git log --oneline --graph --decorate'
alias gst='git stash'
alias gstp='git stash pop'

# --------------------------------------------
# Aliases - Development
# --------------------------------------------
alias v='vim'
alias c='code'
alias py='python3'
alias pip='pip3'

# mise経由でbundleを実行
alias bundle='mise exec -- bundle'

# --------------------------------------------
# Environment variables
# --------------------------------------------
export EDITOR='vim'
export VISUAL='vim'
# ロケールが存在する場合のみ ja_JP を使う (無い Linux 環境での警告を防ぐ)
if locale -a 2>/dev/null | grep -qiE '^ja_JP\.utf-?8$'; then
    export LANG='ja_JP.UTF-8'
elif locale -a 2>/dev/null | grep -qiE '^(c|en_US)\.utf-?8$'; then
    export LANG="$(locale -a | grep -iE '^(c|en_US)\.utf-?8$' | head -1)"
fi

# PATH
export PATH="$HOME/.local/bin:$PATH"

# --------------------------------------------
# Functions
# --------------------------------------------
# ディレクトリを作成して移動
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# ファイルを検索 (fd コマンドがあればそちらを使用)
ff() {
    if command -v fd &> /dev/null; then
        fd --type f "$1"
    else
        find . -type f -name "*$1*"
    fi
}

# ディレクトリを検索
fdir() {
    if command -v fd &> /dev/null; then
        fd --type d "$1"
    else
        find . -type d -name "*$1*"
    fi
}

# --------------------------------------------
# fzf (fuzzy finder)
# --------------------------------------------
if command -v fzf &> /dev/null; then
    source <(fzf --zsh)
    export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
    export FZF_CTRL_R_OPTS='--sort --exact'
fi

# --------------------------------------------
# zoxide (smarter cd)
# --------------------------------------------
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh)"
    alias cd='z'  # replace cd with zoxide
fi

# --------------------------------------------
# Codespaces の自動トークンは権限が限定的で gh のログインより優先されてしまうため外す
# --------------------------------------------
unset GITHUB_TOKEN

# --------------------------------------------
# Load local settings (if exists)
# --------------------------------------------
if [[ -f ~/.zshrc.local ]]; then
    source ~/.zshrc.local
fi
if command -v mise &> /dev/null; then
    eval "$(mise activate zsh)"
fi
