# ============================================
# Dotfiles - .zshrc
# ============================================

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

# --------------------------------------------
# Completion
# --------------------------------------------
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'  # 大文字小文字を区別しない
zstyle ':completion:*' menu select                    # 補完候補をメニュー表示

# --------------------------------------------
# Prompt
# --------------------------------------------
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats '%F{green}(%b)%f '
setopt PROMPT_SUBST

# シンプルでカラフルなプロンプト
PROMPT='%F{cyan}%~%f ${vcs_info_msg_0_}%F{yellow}$%f '

# --------------------------------------------
# Aliases - General
# --------------------------------------------
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# ls colors (macOS)
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

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

# --------------------------------------------
# Environment variables
# --------------------------------------------
export EDITOR='vim'
export VISUAL='vim'
export LANG='ja_JP.UTF-8'

# PATH
export PATH="$HOME/.local/bin:$PATH"

# --------------------------------------------
# Functions
# --------------------------------------------
# ディレクトリを作成して移動
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# ファイルを検索
ff() {
    find . -type f -name "*$1*"
}

# ディレクトリを検索
fd() {
    find . -type d -name "*$1*"
}

# --------------------------------------------
# Load local settings (if exists)
# --------------------------------------------
if [[ -f ~/.zshrc.local ]]; then
    source ~/.zshrc.local
fi
