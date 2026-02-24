#!/bin/bash

# ============================================
# macOS Defaults Script
# ============================================
# Usage: ./macos.sh
# 注意: 一部の設定は再起動またはログアウトが必要です

set -e

echo "=================================="
echo "  macOS Settings Configuration"
echo "=================================="
echo ""

# 管理者権限の確認
if [[ $EUID -ne 0 ]]; then
    echo "一部の設定には管理者権限が必要です"
    echo "必要に応じて sudo ./macos.sh で実行してください"
    echo ""
fi

# ============================================
# Dock
# ============================================
echo "[Dock]"

# Dock のサイズ
defaults write com.apple.dock tilesize -int 48

# Dock を自動的に隠す
defaults write com.apple.dock autohide -bool true

# Dock の表示/非表示の遅延をなくす
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.3

# 最近使ったアプリを Dock に表示しない
defaults write com.apple.dock show-recents -bool false

# アプリケーションの起動時にアニメーションを無効化
defaults write com.apple.dock launchanim -bool false

echo "  - Dock の設定を完了"

# ============================================
# Finder
# ============================================
echo "[Finder]"

# 隠しファイルを表示
defaults write com.apple.finder AppleShowAllFiles -bool true

# 拡張子を常に表示
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# パスバーを表示
defaults write com.apple.finder ShowPathbar -bool true

# ステータスバーを表示
defaults write com.apple.finder ShowStatusBar -bool true

# 新しいウィンドウでホームフォルダを開く
defaults write com.apple.finder NewWindowTarget -string "PfHm"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"

# リスト表示をデフォルトに
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# 検索時にデフォルトで現在のフォルダを検索
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# 拡張子変更時の警告を無効化
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# .DS_Store ファイルをネットワークボリュームに作成しない
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

echo "  - Finder の設定を完了"

# ============================================
# Keyboard
# ============================================
echo "[Keyboard]"

# キーリピートを速く
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# 自動大文字を無効化
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

# スペルの自動修正を無効化
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# ピリオドの自動挿入を無効化
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# スマートクォートを無効化
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# スマートダッシュを無効化
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

echo "  - キーボードの設定を完了"

# ============================================
# Trackpad
# ============================================
echo "[Trackpad]"

# タップでクリック
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true

# 3本指ドラッグを有効化
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true

echo "  - トラックパッドの設定を完了"

# ============================================
# Screen
# ============================================
echo "[Screen]"

# スクリーンショットの保存先
mkdir -p "${HOME}/Pictures/Screenshots"
defaults write com.apple.screencapture location -string "${HOME}/Pictures/Screenshots"

# スクリーンショットの形式を PNG に
defaults write com.apple.screencapture type -string "png"

# スクリーンショットに影を含めない
defaults write com.apple.screencapture disable-shadow -bool true

echo "  - スクリーンショットの設定を完了"

# ============================================
# Safari (開発者向け)
# ============================================
echo "[Safari]"

# 開発メニューを表示
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true

echo "  - Safari の設定を完了"

# ============================================
# その他
# ============================================
echo "[Other]"

# クラッシュレポーターを無効化
defaults write com.apple.CrashReporter DialogType -string "none"

# 起動音を無効化
# sudo nvram SystemAudioVolume=" "

echo "  - その他の設定を完了"

# ============================================
# 設定の適用
# ============================================
echo ""
echo "設定を適用しています..."

# Dock を再起動
killall Dock 2>/dev/null || true

# Finder を再起動
killall Finder 2>/dev/null || true

# SystemUIServer を再起動
killall SystemUIServer 2>/dev/null || true

echo ""
echo "=================================="
echo "  完了!"
echo "=================================="
echo ""
echo "一部の設定は再起動後に有効になります。"
echo ""
