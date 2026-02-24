-- ============================================
-- Neovim Configuration
-- ============================================

-- リーダーキーの設定（プラグインより先に設定）
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- 基本設定
require("options")
require("keymaps")

-- プラグインマネージャー (lazy.nvim)
require("plugins")
